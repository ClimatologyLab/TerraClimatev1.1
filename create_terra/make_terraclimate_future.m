% set global warming level
delta_temp=4;
var=1;
targetyear=2015;
% load scalefactors from netCDF
switch var
case 1, Y=ncread('scalefactor_tasmax.nc','lat');X=ncread('scalefactor_tasmax.nc','lon');scalefactor=ncread('scalefactor_tasmax.nc','ps_mean');scalefactors=ncread('scalefactor_tasmax.nc','ps_std');
case 2, Y=ncread('scalefactor_tasmin.nc','lat');X=ncread('scalefactor_tasmin.nc','lon');scalefactor=ncread('scalefactor_tasmin.nc','ps_mean');scalefactors=ncread('scalefactor_tasmin.nc','ps_std');
case 3, Y=ncread('scalefactor_was.nc','lat');X=ncread('scalefactor_was.nc','lon');scalefactor=ncread('scalefactor_was.nc','ps_mean');scalefactors=ncread('scalefactor_was.nc','ps_std');
case 4, Y=ncread('scalefactor_rsds.nc','lat');X=ncread('scalefactor_rsds.nc','lon');scalefactor=ncread('scalefactor_rsds.nc','ps_mean');scalefactors=ncread('scalefactor_rsds.nc','ps_std');
case 5, Y=ncread('scalefactor_pr.nc','lat');X=ncread('scalefactor_pr.nc','lon');scalefactor=ncread('scalefactor_pr.nc','ps_mean');scalefactors=ncread('scalefactor_pr.nc','ps_std');
case 6, Y=ncread('scalefactor_tdmean.nc','lat');X=ncread('scalefactor_tdmean.nc','lon');scalefactor=ncread('scalefactor_tdmean.nc','ps_mean');scalefactors=ncread('scalefactor_tdmean.nc','ps_std');
end

% remove the 11-year moving mean GMT from the observed part as well relative to base period, NASA GISS is adjusted to be relative to a 1850-1900 base reference
c=readtable('NASAGISS.csv');
GMT=c(:,3);
% loess 5-year filter of GMT relative to 1850-1900 baseline
GMT=movmean(GMT,5);
[x,y]=meshgrid(X,Y);

% historical TerraClimate data and climatologies need to be acquired from
% http://thredds.northwestknowledge.net:8080/thredds/catalog/TERRACLIMATE_ALL/climatology/catalog.html
% http://thredds.northwestknowledge.net:8080/thredds/catalog/TERRACLIMATE_ALL/data/catalog.html

d2=delta_temp-GMT(targetyear-1879);
lat=ncread('TerraClimate_tmax_',num2str(targetyear),'.nc'],'lat');
lon=ncread('TerraClimate_tmax_',num2str(targetyear),'.nc'],'lat');
switch var,
case 1, data=ncread('TerraClimate_tmax_',num2str(targetyear),'.nc'],'tmax');refdata=ncread('TerraClimate_19912020_tmax.nc','tmax');
case 2, data=ncread('TerraClimate_tmin_',num2str(targetyear),'.nc'],'tmin');refdata=ncread('TerraClimate_19912020_tmin.nc','tmin');
case 3, data=ncread('TerraClimate_ws_',num2str(targetyear),'.nc'],'ws');refdata=ncread('TerraClimate_19912020_ws.nc','ws');
case 4, data=ncread('TerraClimate_srad_',num2str(targetyear),'.nc'],'srad');refdata=ncread('TerraClimate_19912020_srad.nc','srad');
case 5, data=ncread('TerraClimate_ppt_',num2str(targetyear),'.nc'],'ppt');refdata=ncread('TerraClimate_19912020_ppt.nc','ppt');
case 6, data=ncread('TerraClimate_vap_',num2str(targetyear),'.nc'],'vap');refdata=ncread('TerraClimate_19912020_vap.nc','vap');
end


if var<=4 % simple additive approach

data=data-refdata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j),lon,lat);
end
%get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
data=data+refdata;
for j=1:12
   data(:,:,j)=data(:,:,j)+d2*interp2(x,y,scalefactor(:,:,j),lon,lat);
end
elseif var==6
% minimum bounds for ref data to 0.1 to avoid dividing by zero
refdata(refdata<.1)=.1;
data=data./refdata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j),lon,lat);
end
data=data.*refdata;
%get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
for j=1:12
   data(:,:,j)=data(:,:,j).*(1+d2*interp2(x,y,scalefactor(:,:,j,5),lon,lat));
end
% cast any data that goes below 0 to 0
data(data<0)=0;
elseif var==5
% covert from vapor pressure to dewpoint temperature
data=data*10;refdata=refdata*10;
% set minimum bounds
refdata(refdata==0)=1e-4;data(data==0)=1e-4;
data=(243.5*log(data/6.112))./(17.67-log(data/6.112));
refdata=(243.5*log(refdata/6.112))./(17.67-log(refdata/6.112));
data=data-refdata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j),lon,lat);
end
data=data+refdata;
%get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
for j=1:12
 data(:,:,j)=data(:,:,j)+d2*interp2(x,y,scalefactor(:,:,j,8),lon,lat);
end
data=6.112*exp(17.67*data./(243.5+data));
% convert dewpoint to vap
data=data/10;
end

% need monthly summarized ERA5 data and WorldClim v2.0 climatologies for 1970-2000
% these are not provided here, but WorlClim v2.0 is widely available and ERA5 summaries can be calculated

calcterraclimate(myr,year,mclimo,mbase,lon,lat,mlon,mlat,var);

function calcterraclimate(myr,year,mclimo,mbase,lon,lat,mlon,mlat,var);
dirr='/data/obs/obs/gridded/terraclim/MAT/';

if var~=5 % for all but precipitation anomalies are difference from mean
anom=myr-mclimo;
else
anom=myr./mclimo;
end

% swap longitudes given ERA5 goes 0-360, but TerraClimate is -180 to 180

k=anom(:,1:720,:);anom(:,1:720,:)=anom(:,721:1440,:);anom(:,721:1440,:)=k;
% add padding for interpolation assistance
anom(:,1441,:)=anom(:,1,:);


if var<=4 % additive

for mo=1:12
data(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat)+mbase(:,:,mo); end 
elseif var==5
% be sure there are not wild anomalies due to very low climatological precipitaiton
anom(isinf(anom))=1;anom(anom>10)=10;
anom(isnan(anom))=1;anom(anom<0)=0;
zz=mbase;
% restrict any month with 0 precipitation to 0.1mm
zz(zz<.1)=.1;
for mo=1:12
data(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat).*zz(:,:,mo);
end
else if var==6
climovap=mbase*10;
climovap(climovap<.01)=.01;
% convert from vapor pressure to dewpoint using inverted Magnus formula
e1=log(climovap/6.112);
Td=243.5*e1./(17.67-e1);
for mo=1:12
tddata(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat)+Td(:,:,mo);
end
% convert back to vapor pressure w/Magnus
data=6.112*exp((17.67*tddata)./(tddata+243.5));
data=reshape(data/10,size(tddata));
f=find(data<0);data(f)=0;
end
clear anom
end

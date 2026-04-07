% historical TerraClimate data need to be acquired from
% http://thredds.northwestknowledge.net:8080/thredds/catalog/TERRACLIMATE_ALL/data/catalog.html
% GCM counterfactuals available at https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/

var=1;
targetyear=2015;

x=ncread('counterfactual_tmax.nc','lon');
y=ncread('counterfactual_tmax.nc','lat');
[x,y]=meshgrid(x,y);
lon=ncread('TerraClimate_tmax_',num2str(targetyear),'.nc'],'lon');
lat=ncread('TerraClimate_tmax_',num2str(targetyear),'.nc'],'lat');
[lon,lat]=meshgrid(lon,lat);

switch var,
case 1, delta=ncread('counterfactual_tmax.nc','counterfactual_tmax');data=ncread('TerraClimate_tmax_',num2str(targetyear),'.nc'],'tmax');
case 2, delta=ncread('counterfactual_tmin.nc','counterfactual_tmin');data=ncread('TerraClimate_tmin_',num2str(targetyear),'.nc'],'tmin');
case 3, delta=ncread('counterfactual_srad.nc','counterfactual_srad');data=ncread('TerraClimate_srad_',num2str(targetyear),'.nc'],'srad');
case 4, delta=ncread('counterfactual_ws.nc','counterfactual_ws');data=ncread('TerraClimate_ws_',num2str(targetyear),'.nc'],'ws');
case 5, delta=ncread('counterfactual_pr.nc','counterfactual_pr');data=ncread('TerraClimate_ppt_',num2str(targetyear),'.nc'],'ppt');
case 6, delta=ncread('counterfactual_vap.nc','counterfactual_vap');data=ncread('TerraClimate_vap_',num2str(targetyear),'.nc'],'vap');
end

delta=reshape(delta,181,91,12,251);
delta=permute(delta,[2 1 3 4]);
data=permute(data,[2 1 3]);

if var<=4 % subtract from historical data
 for j=1:12
  data(:,:,j)=data(:,:,j)-interp2(x,y,delta(:,:,j,targetyear-1849),lon,lat);
 end
else
 for j=1:12
  data(:,:,j)=data(:,:,j)./interp2(x,y,delta(:,:,j,targetyear-1849),lon,lat);
 end
end

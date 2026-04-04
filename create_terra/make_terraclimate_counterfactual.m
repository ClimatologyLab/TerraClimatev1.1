% historical TerraClimate data need to be acquired from
% http://thredds.northwestknowledge.net:8080/thredds/catalog/TERRACLIMATE_ALL/data/catalog.html
var=1;
targetyear=2015;

x=ncread('counterfactual_tmax.nc','lon');
y=ncread('counterfactual_tmax.nc','lat');
[x,y]=meshgrid(x,y);

switch var,
case 1, delta=ncread('counterfactual_tmax.nc','counterfactual_tmax');
case 2, delta=ncread('counterfactual_tmin.nc','counterfactual_tmin');
case 3, delta=ncread('counterfactual_srad.nc','counterfactual_srad');
case 4, delta=ncread('counterfactual_ws.nc','counterfactual_ws');
case 5, delta=ncread('counterfactual_pr.nc','counterfactual_pr');
case 6, delta=ncread('counterfactual_vap.nc','counterfactual_vap');
end

delta=reshape(delta,181,91,12,251);
delta=permute(delta,[2 1 3 4]);

if var<=4 % subtract from historical data



for i=1:76
 for j=2:6
switch j,
case 1, 
 m=matfile([d,'tmax_',num2str(1949+i)]);data=m.tmaxdata;%(f,f2,:);
 for j=1:12
  data(:,:,j)=data(:,:,j)-interp2(x,y,txdata(:,:,j,100+i),lon,lat);
 end
 data=single(round(data,1));save(['terra_tmax_',num2str(1949+i)],'-v7.3','data');clear data
case 2, 
 m=matfile([d,'tmin_',num2str(1949+i)]);data=m.tmindata;%(f,f2,:);
 for j=1:12
  data(:,:,j)=data(:,:,j)-interp2(x,y,tndata(:,:,j,108+i),lon,lat);
 end
 data=single(round(data,1));save(['terra_tmin_',num2str(1949+i)],'-v7.3','data');clear data
case 3, 
 m=matfile([d,'vap_',num2str(1949+i)]);data=m.vapdata;%(f,f2,:);
 for j=1:12
  data(:,:,j)=data(:,:,j)./interp2(x,y,hdata(:,:,j,108+i),lon,lat);
 end
 data=single(round(data,3));save(['terra_vap_',num2str(1949+i)],'-v7.3','data');clear data
case 4,
 m=matfile([d,'ppt_',num2str(1949+i)]);data=m.pptdata;%(f,f2,:);
 for j=1:12
  data(:,:,j)=data(:,:,j)./interp2(x,y,prdata(:,:,j,108+i),lon,lat);
 end
 data=single(round(data,1));save(['terra_ppt_',num2str(1949+i)],'-v7.3','data');clear data
case 5,
 m=matfile([d,'ws_',num2str(1949+i)]);data=m.winddata;%(f,f2,:);
 for j=1:12
  data(:,:,j)=data(:,:,j)-interp2(x,y,wdata(:,:,j,108+i),lon,lat);
 end
 data=single(round(data,1));save(['terra_ws_',num2str(1949+i)],'-v7.3','data');clear data
case 6,
 m=matfile([d,'srad_',num2str(1949+i)]);data=m.sraddata;%(f,f2,:);
 for j=1:12
  data(:,:,j)=data(:,:,j)-interp2(x,y,rdata(:,:,j,108+i),lon,lat);
 end
 data=single(round(data,1));save(['terra_srad_',num2str(1949+i)],'-v7.3','data');clear data
end
end
end

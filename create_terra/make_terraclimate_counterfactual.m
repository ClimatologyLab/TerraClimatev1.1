
load global_smooth2.mat
x=x';y=y';x=x-360;
clear rmaxdata rmindata
wdata=permute(wdata,[2 1 3 4]);
rdata=permute(rdata,[2 1 3 4]);
hdata=permute(hdata,[2 1 3 4]);
tndata=permute(tndata,[2 1 3 4]);
txdata=permute(txdata,[2 1 3 4]);
prdata=permute(squeeze(nanmean(prdata,4)),[2 1 3 4]);

wdata=wdata-repmat(nanmean(wdata(:,:,:,1:50),4),[1 1 1 251]);
rdata=rdata-repmat(nanmean(rdata(:,:,:,1:50),4),[1 1 1 251]);
hdata=hdata./repmat(nanmean(hdata(:,:,:,1:50),4),[1 1 1 251]);
tndata=tndata-repmat(nanmean(tndata(:,:,:,1:50),4),[1 1 1 251]);
txdata=txdata-repmat(nanmean(txdata(:,:,:,1:50),4),[1 1 1 251]);
prdata=prdata./repmat(nanmean(prdata(:,:,:,1:50),4),[1 1 1 251]);

% shift GCM data to span lon of terraclimate
z=wdata(:,1:91,:,:);wdata=wdata(:,91:180,:,:);wdata(:,91:181,:,:)=z;wdata(:,91,:,:)=nanmean(wdata(:,90:92,:,:),2);
z=rdata(:,1:91,:,:);rdata=rdata(:,91:180,:,:);rdata(:,91:181,:,:)=z;rdata(:,91,:,:)=nanmean(rdata(:,90:92,:,:),2);
z=hdata(:,1:91,:,:);hdata=hdata(:,91:180,:,:);hdata(:,91:181,:,:)=z;hdata(:,91,:,:)=nanmean(hdata(:,90:92,:,:),2);
z=txdata(:,1:91,:,:);txdata=txdata(:,91:180,:,:);txdata(:,91:181,:,:)=z;txdata(:,91,:,:)=nanmean(txdata(:,90:92,:,:),2);
z=tndata(:,1:91,:,:);tndata=tndata(:,91:180,:,:);tndata(:,91:181,:,:)=z;tndata(:,91,:,:)=nanmean(tndata(:,90:92,:,:),2);
z=prdata(:,1:91,:,:);prdata=prdata(:,91:180,:,:);prdata(:,91:181,:,:)=z;prdata(:,91,:,:)=nanmean(prdata(:,90:92,:,:),2);

x=-180:2:180;y=y(:,1);
[x,y]=meshgrid(x,y);
d='/data/obs/obs/gridded/terraclim/MAT/';
% loop through years 1950-2025
% ppt
%l={'ppt';'vap';'tmax';'tmin';'srad';'ws'};
%pptdata;vapdata;tmaxdata;tmindata;sraddad;winddata
load([d,'/lonlatel']);
clear el
%lon=lon(f,f2);
%lat=lat(f,f2);
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

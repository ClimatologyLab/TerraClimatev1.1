delta=4;

load scalefactorCMIP6.mat
% use median and correct end points
scalefactor=nanmedian(scalefactor,5);
scalefactor(1,:,:,:)=scalefactor(2,:,:,:);
scalefactor(end,:,:,:)=scalefactor(end-1,:,:,:);
scalefactor(:,1,:,:)=scalefactor(:,2,:,:);
scalefactor(:,end,:,:)=scalefactor(:,end-1,:,:);

scalefactors=nanmedian(scalefactors,5);
scalefactors(1,:,:,:)=scalefactors(2,:,:,:);
scalefactors(end,:,:,:)=scalefactors(end-1,:,:,:);
scalefactors(:,1,:,:)=scalefactors(:,2,:,:);
scalefactors(:,end,:,:)=scalefactors(:,end-1,:,:);

t=scalefactor(:,1:180,:,:);scalefactor=scalefactor(:,181:end,:,:);scalefactor(:,182:361,:,:)=t;scalefactor(:,180,:,:)=scalefactor(:,179,:,:);scalefactor(:,181,:,:)=scalefactor(:,182,:,:);
t=scalefactors(:,1:180,:,:);scalefactors=scalefactors(:,181:end,:,:);scalefactors(:,182:361,:,:)=t;scalefactors(:,180,:,:)=scalefactors(:,179,:,:);scalefactors(:,181,:,:)=scalefactors(:,182,:,:);

%cap scalefactors for precipitation
s=scalefactors(:,:,:,5);s(s>.5)=.5;scalefactors(:,:,:,5)=s;scalefactors(:,:,:,5)=0;
s=scalefactor(:,:,:,5);s(s>.5)=.5;scalefactor(:,:,:,5)=s;

%cap scalefactors for srad
s=scalefactor(:,:,:,6);s(s<-15)=-15;scalefactor(:,:,:,6)=s;

%cap scalefactors for dew
s=scalefactor(:,:,:,8);s(s<0)=0;scalefactor(:,:,:,8)=s;

% remove the 11-year moving mean GMT from the observed part as well relative to base period
load GMT_NASA
GMT=GMT(:,3)+.19;
% loess 5-year filter of GMT relative to 1850-1900 baseline

[x,y]=meshgrid(X,Y);
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

d2=delta-GMT(1949+i-1879);

 for j=1:6
switch j,
case 1, 

m=matfile([d,'tmax_',num2str(1949+i)]);data=m.tmaxdata;%(f,f2,:);
load /data/obs/obs/gridded/terraclim/MAT/climo_19702000.mat tmaxdata
data=data-tmaxdata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j,1),lon,lat);
end
  data=data+tmaxdata;
  %get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
  for j=1:12
   data(:,:,j)=data(:,:,j)+d2*interp2(x,y,scalefactor(:,:,j,1),lon,lat);
 end
data=single(round(data,1));save(['terra_',num2str(delta),'_tmax_',num2str(1949+i)],'-v7.3','data');clear data
case 2, 
m=matfile([d,'tmin_',num2str(1949+i)]);data=m.tmindata;%(f,f2,:);
load /data/obs/obs/gridded/terraclim/MAT/climo_19702000.mat tmindata
data=data-tmindata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j,2),lon,lat);
end
  data=data+tmindata;
  %get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
  for j=1:12
   data(:,:,j)=data(:,:,j)+d2*interp2(x,y,scalefactor(:,:,j,2),lon,lat);
 end
data=single(round(data,1));save(['terra_',num2str(delta),'_tmin_',num2str(1949+i)],'-v7.3','data');clear data

case 3, 
m=matfile([d,'vap_',num2str(1949+i)]);data=m.vapdata;%(f,f2,:);
load /data/obs/obs/gridded/terraclim/MAT/climo_19702000.mat vapdata
% covert to dewpoint
data=data*10;vapdata=vapdata*10;
vapdata(vapdata==0)=1e-4;data(data==0)=1e-4;
data=(243.5*log(data/6.112))./(17.67-log(data/6.112));
vapdata=(243.5*log(vapdata/6.112))./(17.67-log(vapdata/6.112));
data=data-vapdata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j,8),lon,lat);
end
  data=data+vapdata;
  %get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
  for j=1:12
   data(:,:,j)=data(:,:,j)+d2*interp2(x,y,scalefactor(:,:,j,8),lon,lat);
 end
data=6.112*exp(17.67*data./(243.5+data));
% convert dewpoint to vap
data=data/10;
data=single(round(data,4));save(['terra_',num2str(delta),'_vap_',num2str(1949+i)],'-v7.3','data');clear data

case 4,
m=matfile([d,'ppt_',num2str(1949+i)]);data=m.pptdata;%(f,f2,:);
load /data/obs/obs/gridded/terraclim/MAT/climo_19702000.mat pptdata;pptdata(pptdata<.1)=.1;
data=data./pptdata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j,5),lon,lat);
end
  data=data.*pptdata;
  %get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
  for j=1:12
   data(:,:,j)=data(:,:,j).*(1+d2*interp2(x,y,scalefactor(:,:,j,5),lon,lat));
 end
data(data<0)=0;
data=single(round(data,1));save(['terra_',num2str(delta),'_ppt_',num2str(1949+i)],'-v7.3','data');clear data

case 5,
m=matfile([d,'ws_',num2str(1949+i)]);data=m.winddata;%(f,f2,:);
load /data/obs/obs/gridded/terraclim/MAT/climo_19702000.mat winddata
data=data-winddata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j,7),lon,lat);
end
  data=data+winddata;
  %get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
  for j=1:12
   data(:,:,j)=data(:,:,j)+d2*interp2(x,y,scalefactor(:,:,j,7),lon,lat);
 end
data(data<0)=0;
data=single(round(data,1));save(['terra_',num2str(delta),'_wind_',num2str(1949+i)],'-v7.3','data');clear data

case 6,
m=matfile([d,'srad_',num2str(1949+i)]);data=m.sraddata;%(f,f2,:);
load /data/obs/obs/gridded/terraclim/MAT/climo_19702000.mat sraddata
data=data-sraddata;
for j=1:12
 data(:,:,j)=data(:,:,j).*interp2(x,y,1+d2.*scalefactors(:,:,j,6),lon,lat);
end
  data=data+sraddata;
  %get anomaly; then multiply anomaly by the scalefactors; finally add scalefactor to data  
  for j=1:12
   data(:,:,j)=data(:,:,j)+d2*interp2(x,y,scalefactor(:,:,j,6),lon,lat);
 end
data(data<0)=0;
data=single(round(data,1));save(['terra_',num2str(delta),'_srad_',num2str(1949+i)],'-v7.3','data');clear data
end
end
end

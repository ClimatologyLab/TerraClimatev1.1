mbase=matfile('/data/obs/obs/gridded/terraclim/MAT/climo_19702000.mat');
for year=1950:1950

myr=matfile(['/data/obs/reanalysis/ecmwf/era5/SFC/monthly_era5summary.mat']);
mclimo=matfile('/data/obs/reanalysis/ecmwf/era5/SFC/climo_19712000_era5summary.mat');
lon=myr.lon;lat=myr.lat;
[mlon,mlat]=meshgrid(lon,lat);
k=mlon(:,1:720);mlon(:,1:720)=mlon(:,721:1440);mlon(:,721:1440)=k;
mlat(:,1441)=mlat(:,1440);
mlon(:,1441)=180;
mlon(:,1:720)=mlon(:,1:720)-360;

load /data/obs/obs/gridded/terraclim/MAT/lonlatel.mat
for var=1:7
calcterraclimate(myr,year,mclimo,mbase,lon,lat,mlon,mlat,var);
end
calcterraclimate(myr,year,mclimo,mbase,lon,lat,mlon,mlat,7);
run_pet3(year);
end


function calcterraclimate(myr,year,mclimo,mbase,lon,lat,mlon,mlat,var);
dirr='/data/obs/obs/gridded/terraclim/MAT/';

switch var,
case 1, anom=myr.was(:,:,:,year-1949)-mclimo.wasc;
case 2, anom=myr.rsds(:,:,:,year-1949)-mclimo.rsdsc;
case 4, anom=myr.tmax(:,:,:,year-1949)-mclimo.tmaxc;
case 5, anom=myr.tmin(:,:,:,year-1949)-mclimo.tminc;
case 6, anom=myr.dew(:,:,:,year-1949)-mclimo.dewc;
case 3, anom=myr.tp(:,:,:,year-1949)./mclimo.tpc;whos
end
if var<=6
anom=permute(anom,[2 1 3]);
k=anom(:,1:720,:);anom(:,1:720,:)=anom(:,721:1440,:);anom(:,721:1440,:)=k;
anom(:,1441,:)=anom(:,1,:);
end

switch var

case 1 % wind 
for mo=1:12
winddata(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat)+mbase.winddata(:,:,mo); end 
winddata=single(winddata); f=find(winddata<0);winddata(f)=0; 
winddata=round(winddata,1); 
save([dirr,'ws_',num2str(year)],'-v7.3','winddata'); clear winddata

case 2 % srad
for mo=1:12
sraddata(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat)+mbase.sraddata(:,:,mo);
end
sraddata=single(sraddata);
f=find(sraddata<0);sraddata(f)=0;
sraddata=round(sraddata,1);
save([dirr,'srad_',num2str(year)],'-v7.3','sraddata');
clear sraddata

case 3, %ppt
anom(isinf(anom))=1;anom(anom>10)=10;
anom(isnan(anom))=1;anom(anom<0)=0;
zz=mbase.pptdata;
zz(zz<.1)=.1;
for mo=1:12
pptdata(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat).*zz(:,:,mo);
end
pptdata=single(pptdata);
f=find(pptdata<0);pptdata(f)=0;
pptdata=round(pptdata,1);
save([dirr,'ppt_',num2str(year)],'-v7.3','pptdata');
clear pptdata

case 6, 
zz=mbase.vapdata;
climovap=zz*10;clear zz
climovap(climovap<.01)=.01;
% convert from vapor pressure to dewpoint
e1=log(climovap/6.112);
Td=243.5*e1./(17.67-e1);
for mo=1:12
tddata(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat)+Td(:,:,mo);
end
% convert back to vapor pressure
vapdata=6.112*exp((17.67*tddata)./(tddata+243.5));
%vapdata=6.1078*exp(17.27*tddata./(tddata+237.3));
%.^((7.5*tddata)./(237.3+tddata));
vapdata=reshape(vapdata/10,size(tddata));
f=find(vapdata<0);vapdata(f)=0;
vapdata=round(vapdata,4);
save([dirr,'vap_',num2str(year)],'-v7.3','vapdata');
clear vapdata

case 4, 
for mo=1:12
tmaxdata(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat)+mbase.tmaxdata(:,:,mo);
end
tmaxdata=single(tmaxdata);
tmaxdata=round(tmaxdata,1);
save([dirr,'tmax_',num2str(year)],'-v7.3','tmaxdata');
clear tmaxdata

case 5, 
for mo=1:12
tmindata(:,:,mo)=interp2(mlon,mlat,anom(:,:,mo),lon,lat)+mbase.tmindata(:,:,mo);
end
tmindata=single(tmindata);
tmindata=round(tmindata,1);
save([dirr,'tmin_',num2str(year)],'-v7.3','tmindata');
clear tmindata
case 7,
load([dirr,'vap_',num2str(year)]);
load([dirr,'tmax_',num2str(year)]);
load([dirr,'tmin_',num2str(year)]);
es= 6.112*exp((17.67*tmaxdata)./(tmaxdata+243.5))/2+6.112*exp((17.67*tmindata)./(tmindata+243.5))/2;
vpddata=es/10-vapdata;clear ea es tdew tmaxdata tmindata
vpddata=round(vpddata,4);
vpddata(vpddata<0)=0;
save([dirr,'vpd_',num2str(year)],'-v7.3','vpddata');
end
clear anom
end

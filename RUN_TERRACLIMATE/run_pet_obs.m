function run_pet3(yr);
addpath('/home/abatz/Code/');
load annual_co2
dirr='/data/obs/obs/gridded/terraclim/MAT/';
dirr2='/data/obs/obs/gridded/terraclim/MAT/';
%dirr2='/home/abatz/data/';
load /data/obs/obs/gridded/terraclim/MAT/lonlatel
P=1013.25*((293-0.0065*el)/293).^5.26;
ordir=pwd;
 load([dirr2,'vpd_',num2str(yr)]);
 load([dirr2,'tmax_',num2str(yr)]);
 load([dirr2,'tmin_',num2str(yr)]);
f=find(tmaxdata<tmindata);tmaxdata(f)=tmindata(f);
 load([dirr,'srad_',num2str(yr)]);
 load([dirr,'ws_',num2str(yr)]);
 tmaxdata=shiftdim(tmaxdata,2);
 tmindata=shiftdim(tmindata,2);
 winddata=shiftdim(winddata,2);
 vpddata=shiftdim(vpddata,2);
 sraddata=shiftdim(sraddata,2);
ft=find(isnan(sraddata));sraddata(ft)=0;
ft=find(isinf(sraddata));sraddata(ft)=0;
 petdata=NaN*ones(12,4320,8640);
 f=find(~isnan(tmaxdata(1,:))==1);
 %vpddata=vpddata(:,f);
 %tmaxdata=tmaxdata(:,f);
 %tmindata=tmindata(:,f);
 %sraddata=sraddata(:,f);
 %winddata=winddata(:,f);
 tt=find(isnan(sraddata)==1);
 sraddata(tt)=0;
 [ET]=monthlyPET_co2(sraddata, tmaxdata,tmindata, winddata,lat,el,0.23,vpddata,co2(yr-1849)-300);
% [ET]=monthlyPET_co2(sraddata', tmaxdata',tmindata', winddata',lat(f)',el(f)',0.23,vpddata',co2(yr-1849)-300);
 tmean=tmaxdata/2+tmindata/2;
 clear tmaxdata tmindata
MF=1-runsnow(tmean+273.15,1);
ET=ET.*MF;
 petdata=ET;petdata=shiftdim(petdata,1);
petdata=single(round(petdata,1));
 save([dirr2,'pet_',num2str(yr)],'-v7.3','petdata');
 clear *data ET


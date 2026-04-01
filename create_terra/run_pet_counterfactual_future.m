function run_pet3(yr,co22,delta);
% used for running counterfactual or future scenarios only

%addpath('/home/abatz/Code/');
%load annual_co2
%dirr2='/home/abatz/data/';
load /data/obs/obs/gridded/terraclim/MAT/lonlatel
P=1013.25*((293-0.0065*el)/293).^5.26;
ordir=pwd;
if nargin==2
 load(['terra_vpd_',num2str(yr)]);%vpddata=data;
 load(['terra_tmax_',num2str(yr)]);tmaxdata=data;
 load(['terra_tmin_',num2str(yr)]);tmindata=data;
f=find(tmaxdata<tmindata);tmaxdata(f)=tmindata(f);
 load(['terra_srad_',num2str(yr)]);sraddata=data;
 load(['terra_ws_',num2str(yr)]);winddata=data;
else
load(['terra_',num2str(delta),'_vpd_',num2str(yr)]);%vpddata=data;
 load(['terra_',num2str(delta),'_tmax_',num2str(yr)]);tmaxdata=data;
 load(['terra_',num2str(delta),'_tmin_',num2str(yr)]);tmindata=data;
f=find(tmaxdata<tmindata);tmaxdata(f)=tmindata(f);
 load(['terra_',num2str(delta),'_srad_',num2str(yr)]);sraddata=data;
 load(['terra_',num2str(delta),'_wind_',num2str(yr)]);winddata=data;
end


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
 [ET]=monthlyPET_co2(sraddata, tmaxdata,tmindata, winddata,lat,el,0.23,vpddata,co22);
% [ET]=monthlyPET_co2(sraddata', tmaxdata',tmindata', winddata',lat(f)',el(f)',0.23,vpddata',co2(yr-1849)-300);
 tmean=tmaxdata/2+tmindata/2;
 clear tmaxdata tmindata
MF=1-runsnow(tmean+273.15,1);
ET=ET.*MF;
 petdata=ET;petdata=shiftdim(petdata,1);
petdata=single(round(petdata,1));
if nargin==2
 save(['terra_pet_',num2str(yr)],'-v7.3','petdata');
else
 save(['terra_',num2str(delta),'_pet_',num2str(yr)],'-v7.3','petdata');
end
 clear *data ET


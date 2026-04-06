%delta=4;
% need to acquire a the soil water holding capacity layer https://hess.copernicus.org/articles/20/1459/2016/hess-20-1459-2016.pdf
for year=1950:2025
if year>1950
% get initial conditions from prior year
load([dirr2,'terra_wbupdate_',num2str(year-1)],'snowdata','soildata','SSRAIN','SSSNOW');
soillast=soildata(:,:,12);
snowlast=snowdata(:,:,12);
SSSNOW=SSSNOW(:)';
SSRAIN=SSRAIN(:)';
snowlast=snowlast(:)';
soillast=soillast(:)';
else
soillast=soilt*.5;
snowlast=soillast;
SSSNOW=soillast*.2;
SSRAIN=soillast*.2;
end

clear snowdata soildata runoff*
if exist('delta')==1
 load([dirr2,'terra_',num2str(delta),'_tmax_',num2str(year)]);tmaxdata=data;
 load([dirr2,'terra_',num2str(delta),'_tmin_',num2str(year)]);tmindata=data;
else
 load([dirr2,'terra_tmax_',num2str(year)]);tmaxdata=data;
 load([dirr2,'terra_tmin_',num2str(year)]);tmindata=data;
end
 tmean=tmaxdata/2+tmindata/2;
 clear tmaxdata tmindata
if exist('delta')==1
 load([dirr2,'terra_',num2str(delta),'_pet_',num2str(year)]);
 load([dirr2,'terra_',num2str(delta),'_ppt_',num2str(year)]);pptdata=data;
else
 load([dirr2,'terra_pet_',num2str(year)]);
 load([dirr2,'terra_ppt_',num2str(year)]);pptdata=data;
end

 f=find(~isnan(tmean(:,:,1))==1);
 tmean=shiftdim(tmean,2);
 pptdata=shiftdim(pptdata,2);
 petdata=shiftdim(petdata,2);
 tmean=tmean(:,f);
 pptdata=pptdata(:,f);
 petdata=single(petdata(:,f));


 parfor i=1:12
 [AET(i).data,DEF(i).data,RO(i).data,SNOW(i).data,SOIL(i).data,ROSNOW(i).data,RSSRAIN(i).data,RSSSNOW(i).data]=hydro_tax_robase(tmean(:,1+chunk*(i-1):chunk*i)',pptdata(:,1+chunk*(i-1):chunk*i)',petdata(:,1+chunk*(i-1):chunk*i)',soilt(f(1+chunk*(i-1):chunk*i))',soillast(f(1+chunk*(i-1):chunk*i))',snowlast(f(1+chunk*(i-1):chunk*i))',SSRAIN(f(1+chunk*(i-1):chunk*i))',SSSNOW(f(1+chunk*(i-1):chunk*i))');
 end
 last4=chunk*12+1:chunk*12+4;
 [aaet,ddef,rro,snoww,soill,rros,sr1,sr2]=hydro_tax_robase(tmean(:,last4)',pptdata(:,last4)',petdata(:,last4)',soilt(f(last4))',soillast(f(last4))',snowlast(f(last4))',SSRAIN(f(last4))',SSSNOW(f(last4))');
 
 clear petdata tmean pptdata
 aetdata=single(NaN*ones(12,4320,8640));defdata=aetdata;runoffdata=aetdata;snowdata=aetdata;soildata=aetdata;runoffsnowdata=aetdata;SSRAIN=single(NaN*ones(4320,8640));SSSNOW=SSRAIN;
 for i=1:12
   aetdata(:,f(1+chunk*(i-1):chunk*i))=AET(i).data';
   defdata(:,f(1+chunk*(i-1):chunk*i))=DEF(i).data';
   runoffdata(:,f(1+chunk*(i-1):chunk*i))=RO(i).data';
   runoffsnowdata(:,f(1+chunk*(i-1):chunk*i))=ROSNOW(i).data';
   snowdata(:,f(1+chunk*(i-1):chunk*i))=SNOW(i).data';
   soildata(:,f(1+chunk*(i-1):chunk*i))=SOIL(i).data';
   SSSNOW(f(1+chunk*(i-1):chunk*i))=RSSSNOW(i).data';
   SSRAIN(f(1+chunk*(i-1):chunk*i))=RSSRAIN(i).data';
 end

clear AET DEF RO SNOW SOIL ROSNOW 

 aetdata(:,f(last4))=aaet';
 defdata(:,f(last4))=ddef';
 runoffdata(:,f(last4))=rro';
 runoffsnowdata(:,f(last4))=rros';
 snowdata(:,f(last4))=snoww';
 soildata(:,f(last4))=soill';
 SSSNOW(f(last4))=sr2';
 SSRAIN(f(last4))=sr1';

soillast=soildata(12,:);
snowlast=snowdata(12,:);

aetdata=shiftdim(aetdata,1);
defdata=shiftdim(defdata,1);
runoffdata=shiftdim(runoffdata,1);
runoffsnowdata=shiftdim(runoffsnowdata,1);
snowdata=shiftdim(snowdata,1);
soildata=shiftdim(soildata,1);
aetdata=round(aetdata,1);
defdata=round(defdata,1);
runoffdata=round(runoffdata,1);
runoffsnowdata=round(runoffsnowdata,1);
snowdata=round(snowdata,1);
soildata=round(soildata,1);
SSSNOW=round(SSSNOW,1);
SSRAIN=round(SSRAIN,1);
cd /home/abatz/CMIP6/
if exist('delta')==1
save(['terra_',num2str(delta),'_wbupdate_',num2str(year)],'-v7.3','runoffdata','runoffsnowdata','aetdata','defdata','soildata','snowdata','SSSNOW','SSRAIN');
else
save(['terra_wbupdate_',num2str(year)],'-v7.3','runoffdata','runoffsnowdata','aetdata','defdata','soildata','snowdata','SSSNOW','SSRAIN');
end
clear *data
end


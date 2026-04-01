%delta=2; deltaco2=500-300;
delta=4; deltaco2=800-300;
for year=1950:2025
load(['terra_',num2str(delta),'_vap_',num2str(year)]);vapdata=data;
load(['terra_',num2str(delta),'_tmax_',num2str(year)]);tmaxdata=data;
load(['terra_',num2str(delta),'_tmin_',num2str(year)]);tmindata=data;
es= 6.112*exp((17.67*tmaxdata)./(tmaxdata+243.5))/2+6.112*exp((17.67*tmindata)./(tmindata+243.5))/2;
vpddata=es/10-vapdata;clear ea es tdew tmaxdata tmindata
vpddata=round(vpddata,4);
vpddata(vpddata<0)=0;
if exist('delta')==1
save(['terra_',num2str(delta),'_vpd_',num2str(year)],'-v7.3','vpddata');
else
save(['terra_vpd_',num2str(year)],'-v7.3','vpddata');
end
clear *data
run_pet3(year,deltaco2,delta);
end

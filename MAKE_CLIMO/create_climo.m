function [base,lon,lat]=makeclimo(var,version,year1,year2);

dd='/data/obs/obs/gridded/terraclim/MAT/';
switch version,
case 1, extra='';di='';
case 2, extra='cf_';di='COUNTERFACTUAL/';
case 3, extra='2C_',di='2C/';
case 4, extra='4C_';di='4C/';
end

base=zeros(4320,8640,12);
parfor yr=year1:year2
switch var,
case 1, m=matfile([dd,di,'tmax_',extra,num2str(yr)]);base=base+m.tmaxdata;
case 2, m=matfile([dd,di,'tmin_',extra,num2str(yr)]);base=base+m.tmindata;
case 3, m=matfile([dd,di,'ws_',extra,num2str(yr)]);base=base+m.winddata;
case 4, m=matfile([dd,di,'srad_',extra,num2str(yr)]);base=base+m.sraddata;
case 5, m=matfile([dd,di,'ppt_',extra,num2str(yr)]);base=base+m.pptdata;
case 6, m=matfile([dd,di,'vap_',extra,num2str(yr)]);base=base+m.vapdata;
case 7, m=matfile([dd,di,'vpd_',extra,num2str(yr)]);base=base+m.vpddata;
case 8, m=matfile([dd,di,'pet_',extra,num2str(yr)]);base=base+m.petdata;
case 9, m=matfile([dd,di,'wbupdate_',extra,num2str(yr)]);base=base+m.soildata;
case 10, m=matfile([dd,di,'wbupdate_',extra,num2str(yr)]);base=base+m.defdata;
case 11, m=matfile([dd,di,'wbupdate_',extra,num2str(yr)]);base=base+m.aetdata;
case 12, m=matfile([dd,di,'wbupdate_',extra,num2str(yr)]);base=base+m.runoffdata;
case 13, m=matfile([dd,di,'wbupdate_',extra,num2str(yr)]);base=base+m.snowdata;
end
end
base=base/(year2-year1+1);
load([dd,'lonlatel.mat'])

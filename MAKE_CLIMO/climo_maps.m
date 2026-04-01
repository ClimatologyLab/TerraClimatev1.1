% for each variable, map a four panel map of mean annual values

for i=12:12

switch i,

case 1, load terra_climo_19912020 tmaxclimo;obs=tmaxclimo;load terra_climo_cf_19912020 tmaxclimo;cf=tmaxclimo;load terra_climo_2C_19912020 tmaxclimo;twoc=tmaxclimo;load terra_climo_4C_19912020 tmaxclimo;fourc=tmaxclimo;clear tmaxclimo; varname={'Max Temp'};varrange=[0 30];vardel=[-5 5];

case 2, load terra_climo_19912020 tminclimo;obs=tminclimo;load terra_climo_cf_19912020 tminclimo;cf=tminclimo;load terra_climo_2C_19912020 tminclimo;twoc=tminclimo;load terra_climo_4C_19912020 tminclimo;fourc=tminclimo;clear tminclimo; varname={'Min Temp'};varrange=[-10 20];vardel=[-5 5];

case 3, load terra_climo_19912020 wsclimo;obs=wsclimo;load terra_climo_cf_19912020 wsclimo;cf=wsclimo;load terra_climo_2C_19912020 wsclimo;twoc=wsclimo;load terra_climo_4C_19912020 wsclimo;fourc=wsclimo;clear wsclimo; varname={'Wind'};varrange=[2 8];vardel=[-.5 .5];

case 4, load terra_climo_19912020 sradclimo;obs=sradclimo;load terra_climo_cf_19912020 sradclimo;cf=sradclimo;load terra_climo_2C_19912020 sradclimo;twoc=sradclimo;load terra_climo_4C_19912020 sradclimo;fourc=sradclimo;clear sradclimo; varname={'Solar'};varrange=[50 300];vardel=[-10 10];

case 5, load terra_climo_19912020 vpdclimo;obs=vpdclimo;load terra_climo_cf_19912020 vpdclimo;cf=vpdclimo;load terra_climo_2C_19912020 vpdclimo;twoc=vpdclimo;load terra_climo_4C_19912020 vpdclimo;fourc=vpdclimo;clear vpdclimo; varname={'VPD'};varrange=[0 3];vardel=[-.5 .5];

case 6, load terra_climo_19912020 petclimo;obs=petclimo;load terra_climo_cf_19912020 petclimo;cf=petclimo;load terra_climo_2C_19912020 petclimo;twoc=petclimo;load terra_climo_4C_19912020 petclimo;fourc=petclimo;clear petclimo; varname={'ETo'};varrange=[20 150];vardel=[-10 10];

case 7, load terra_climo_19912020 soilclimo;obs=soilclimo;load terra_climo_cf_19912020 soilclimo;cf=soilclimo;load terra_climo_2C_19912020 soilclimo;twoc=soilclimo;load terra_climo_4C_19912020 soilclimo;fourc=soilclimo;clear soilclimo; varname={'Soil'};varrange=[20 150];vardel=[-10 10];

case 8, load terra_climo_19912020 snowclimo;obs=snowclimo;load terra_climo_cf_19912020 snowclimo;cf=snowclimo;load terra_climo_2C_19912020 snowclimo;twoc=snowclimo;load terra_climo_4C_19912020 snowclimo;fourc=snowclimo;clear snowclimo; varname={'Snow'};varrange=[0 100];vardel=[-10 10];

case 9, load terra_climo_19912020 aetclimo;obs=aetclimo;load terra_climo_cf_19912020 aetclimo;cf=aetclimo;load terra_climo_2C_19912020 aetclimo;twoc=aetclimo;load terra_climo_4C_19912020 aetclimo;fourc=aetclimo;clear aetclimo; varname={'AET'};varrange=[20 150];vardel=[-10 10];

case 10, load terra_climo_19912020 defclimo;obs=defclimo;load terra_climo_cf_19912020 defclimo;cf=defclimo;load terra_climo_2C_19912020 defclimo;twoc=defclimo;load terra_climo_4C_19912020 defclimo;fourc=defclimo;clear defclimo; varname={'DEF'};varrange=[20 150];vardel=[-10 10];

case 11, load terra_climo_19912020 pptclimo;obs=pptclimo;load terra_climo_cf_19912020 pptclimo;cf=pptclimo;load terra_climo_2C_19912020 pptclimo;twoc=pptclimo;load terra_climo_4C_19912020 pptclimo;fourc=pptclimo;clear pptclimo; varname={'Precipitation'};varrange=[20 150];vardel=[-10 10];

case 12, load terra_climo_19912020 runoffclimo;obs=runoffclimo;load terra_climo_cf_19912020 runoffclimo;cf=runoffclimo;load terra_climo_2C_19912020 runoffclimo;twoc=runoffclimo;load terra_climo_4C_19912020 runoffclimo;fourc=runoffclimo;clear runoffclimo; varname={'Runoff'};varrange=[20 150];vardel=[-10 10];
end
load terra_climo_19912020 lon lat
lat=lat(:,1);lon=lon(1,:);
subplot(2,2,1); makemap(lon,lat,mean(obs,3),varrange,2);title(varname);colormap(gca,cbrewer('seq','YlOrRd',11));colorbar('h')
subplot(2,2,2); makemap(lon,lat,mean(obs-cf,3),vardel,2);title('Obs minus CF');colormap(gca,flip(cbrewer('div','RdBu',11)));colorbar('h')
subplot(2,2,3); makemap(lon,lat,mean(twoc-obs,3),vardel,2);title('2C minus Obs');colormap(gca,flip(cbrewer('div','RdBu',11)));colorbar('h')
subplot(2,2,4); makemap(lon,lat,mean(fourc-obs,3),vardel,2);title('4C minus Obs');colormap(gca,flip(cbrewer('div','RdBu',11)));colorbar('h')
print(gcf,'-dpng','-r400',[char(varname),'.png']);
fart
clf
end


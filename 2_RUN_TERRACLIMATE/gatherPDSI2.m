year1=25;
year2=76;
for yr=year1:year2
PDSI=single(NaN*ones(12,4320,8640));
for i=1:18
dir='/data/backups/home_pluvial_abatz/DROUGHT/';
m=matfile([dir,'PDSI_',num2str(i)]);
f=m.f;
dyr=1+(yr-1)*12:yr*12;
data=m.PDSI(:,dyr);
data=data';
d1=NaN*ones(12,4320/18,8640);
d1(:,f)=data;
PDSI(:,1+(i-1)*240:i*240,:)=d1;
clear d1 data
end
PDSI=round(PDSI,2);
save([dir,'PDSI_',num2str(yr+1949)],'-v7.3','PDSI');
clear PDSI 
end



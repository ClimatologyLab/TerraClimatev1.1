function [d1]=extractPDSI(i,yr);

dir='/data/backups/home_pluvial_abatz/DROUGHT/';
m=matfile([dir,'PDSI_',num2str(i)]);
f=m.f;
dyr=1+(yr-1)*12:yr*12;
data=m.PDSI(:,dyr);
data=data';
d1=NaN*ones(12,4320/18,8640);
d1(:,f)=data;

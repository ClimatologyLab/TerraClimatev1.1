dir='/data/backups/home_pluvial_abatz/DROUGHT/';
parpool(16);
year1=52;
year2=76+51;
for yr=year1:year2
PDSI=single(NaN*ones(12,4320,8640));
parfor i=1:18
P(i).data=extractPDSI(i,yr);
end
for i=1:18
PDSI(:,1+(i-1)*240:i*240,:)=P(i).data;
end

PDSI=round(PDSI,2);
save([dir,'PDSI_cf_',num2str(yr+1949-51)],'-v7.3','PDSI');
clear PDSI 
end


year1=128;
year2=76+127;
for yr=year1:year2
PDSI=single(NaN*ones(12,4320,8640));
parfor i=1:18
P(i).data=extractPDSI(i,yr);
end
for i=1:18
PDSI(:,1+(i-1)*240:i*240,:)=P(i).data;
end

PDSI=round(PDSI,2);
save([dir,'PDSI_2C_',num2str(yr+1949-51-76)],'-v7.3','PDSI');
clear PDSI 
end

year1=204;
year2=76+203;
for yr=year1:year2
PDSI=single(NaN*ones(12,4320,8640));
parfor i=1:18
P(i).data=extractPDSI(i,yr);
end
for i=1:18
PDSI(:,1+(i-1)*240:i*240,:)=P(i).data;
end

PDSI=round(PDSI,2);
save([dir,'PDSI_4C_',num2str(yr+1949-51-152)],'-v7.3','PDSI');
clear PDSI 
end

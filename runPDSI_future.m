function runPDSI(i);
dir='/data/obs/obs/gridded/terraclim/MAT/';
for yr=1:51
m=matfile([dir,'pet_',num2str(1949+yr)]);
pet(:,:,:,yr)=m.petdata(1+(i-1)*240:i*240,:,:);
m=matfile([dir,'ppt_',num2str(1949+yr)]);
ppt(:,:,:,yr)=m.pptdata(1+(i-1)*240:i*240,:,:)+1;
end

dir='/data/obs/obs/gridded/terraclim/MAT/COUNTERFACTUAL/';
for yr=1:76
m=matfile([dir,'pet_cf_',num2str(1949+yr)]);
pet(:,:,:,yr+51)=m.petdata(1+(i-1)*240:i*240,:,:);
m=matfile([dir,'ppt_cf_',num2str(1949+yr)]);
ppt(:,:,:,yr+51)=m.pptdata(1+(i-1)*240:i*240,:,:)+1;
end

dir='/data/obs/obs/gridded/terraclim/MAT/2C/';
for yr=1:76
m=matfile([dir,'pet_2C_',num2str(1949+yr)]);
pet(:,:,:,yr+127)=m.petdata(1+(i-1)*240:i*240,:,:);
m=matfile([dir,'ppt_2C_',num2str(1949+yr)]);
ppt(:,:,:,yr+127)=m.pptdata(1+(i-1)*240:i*240,:,:)+1;
end

dir='/data/obs/obs/gridded/terraclim/MAT/4C/';
for yr=1:76
m=matfile([dir,'pet_4C_',num2str(1949+yr)]);
pet(:,:,:,yr+203)=m.petdata(1+(i-1)*240:i*240,:,:);
m=matfile([dir,'ppt_4C_',num2str(1949+yr)]);
ppt(:,:,:,yr+203)=m.pptdata(1+(i-1)*240:i*240,:,:)+1;
end


% load representative soils data
pet=shiftdim(pet,2);
ppt=shiftdim(ppt,2);
f=find(ppt(5,5,:)>=0);
ppt=ppt(:,:,f);ppt=shiftdim(ppt,2);
pet=pet(:,:,f);pet=shiftdim(pet,2);
load /data/backups/home_pluvial_abatz/TerraClimate/WORLDCLIM/worldclimsoil2
soilt=soilt(1+(i-1)*240:i*240,:);
soilt=soilt(f);
cd /data/backups/home_pluvial_abatz/DROUGHT/
[PDSI]=calcPDSI(pet,ppt,25.4*ones(size(ppt,1),1),soilt,1:51);
save(['PDSI_',num2str(i)],'-v7.3','PDSI','f');
clear PDSI f clear pet ppt
end




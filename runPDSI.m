function runPDSI(i);
dir='/data/obs/obs/gridded/terraclim/MAT/';
for yr=1:76
m=matfile([dir,'pet_',num2str(1949+yr)]);
pet(:,:,:,yr)=m.petdata(1+(i-1)*240:i*240,:,:);
m=matfile([dir,'ppt_',num2str(1949+yr)]);
ppt(:,:,:,yr)=m.pptdata(1+(i-1)*240:i*240,:,:)+1;
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




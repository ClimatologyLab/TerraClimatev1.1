function make_netcdf_archive(yr);

version = 'v1.1';

% first load up data from each netcdf file
% for Simon GEE files

yearS=num2str(yr);
dirr='/data/obs/obs/gridded/terraclim/';
tmax=load([dirr,'MAT/tmax_',yearS]);tmax=tmax.tmaxdata;
tmin=load([dirr,'MAT/tmin_',yearS]);tmin=tmin.tmindata;
ppt=load([dirr,'MAT/ppt_',yearS]);ppt=ppt.pptdata;
vap=load([dirr,'MAT/vap_',yearS]);vap=vap.vapdata;
ws=load([dirr,'MAT/ws_',yearS]);ws=ws.winddata;
srad=load([dirr,'MAT/srad_',yearS]);srad=srad.sraddata;
pet=load([dirr,'MAT/pet_',yearS]);pet=pet.petdata;
PDSI=load([dirr,'MAT/PDSI_',yearS]);PDSI=PDSI.PDSI;
vpd=load([dirr,'MAT/vpd_',yearS]);vpd=vpd.vpddata;
wb=load([dirr,'MAT/wbupdate_',yearS]);
aet=wb.aetdata;
def=wb.defdata;
soil=wb.soildata;
swe=wb.snowdata;
ro=wb.runoffdata;
clear wb

load([dirr,'MAT/lonlatel.mat'])

for m=1:12

day=datenum(yr,m+1,1)-1-datenum(1900,1,1);

fname=[dirr,'NETCDF/FOR_GEE/permanent_terraclimate_',num2str(yr),sprintf('%02i',m),'_',version,'.nc'];
whos

create_bignc2(fname,lat(:,1),lon(1,:),day,tmax(:,:,m),tmin(:,:,m),vap(:,:,m),ppt(:,:,m),ws(:,:,m),srad(:,:,m),pet(:,:,m),aet(:,:,m),def(:,:,m),ro(:,:,m),soil(:,:,m),swe(:,:,m),squeeze(PDSI(m,:,:)),vpd(:,:,m));

end

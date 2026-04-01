% make monthly climatologies for terraclimate from the monthly data
% 2022/9/27 (K.Hegewisch)

myFile='http://thredds.northwestknowledge.net:8080/thredds/dodsC/TERRACLIMATE_ALL/summaries/TerraClimate19812010_tmax.nc';
time= 1:12; %months since Jan
lat= ncread(myFile,'lat');
lon= ncread(myFile,'lon');


VARIABLES = {'tmax';'tmin';'ppt';'srad';'pet';'aet';'def';'soil';'vap';'vpd';'swe';'ws';'q'};
STANDARD_NAMES = {'';'';'precipitation_amount';...
		'downward_shortwave_flux';...
		'potential_evapotranspiration';...
		'actual_evapotranspiration';...
		'climatic_water_deficit';...
		'soil_moisture';...
		'vapor_pressure';...
		'vapor_pressure_deficit';...
		'snow_water_equivalent';...
		'wind_speed';...
		'runoff';...
		};
DESCRIPTIONS = {'Average Maximum 2-m Temperature';...
		'Average Minimum 2-m Temperature';...
		'Accumulated Precipitation';...
		'Shortwave Radiation';...
		'Reference Evapotranspiration';...
		'Actual Evapotranspiration';...
		'Climatic Water Deficit';...
		'Column Soil Moisture';...
		'Vapor Pressure';...
		'Vapor Pressure Deficit';...
		'Snow Water Equivalent';...
		'Wind Speed';...
		'Runoff';...
		};
INTFORMATS ={'int16';'int16';'int32';'int16';'int32';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16'}
UNITS = {'deg C';'deg C';'mm';'W/m2';'mm';'mm';'mm';'mm';'mm';'mm';'mm';'m/s';'mm'};
SCALE_FACTORS = [0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1,0.1];
ADD_OFFSETS = [-72,-72,0,0,0,0,0,0,0,0,0,0,0];


%not done
%TerraClimate19812010_q.nc
%TerraClimate19812010_absmin.nc

%done
%TerraClimate19812010_srad.nc
%TerraClimate19812010_tmax.nc
%TerraClimate19812010_tmin.nc
%TerraClimate19812010_ppt.nc
%TerraClimate19812010_pet.nc
%TerraClimate19812010_aet.nc
%TerraClimate19812010_def.nc
%TerraClimate19812010_soil.nc
%TerraClimate19812010_vap.nc
%TerraClimate19812010_vpd.nc
%TerraClimate19812010_swe.nc
%TerraClimate19812010_ws.nc


%get mask for the oceans
maskFile=matfile('/data/obs/obs/gridded/terraclim/MAT/tmin_2013.mat');
d = maskFile.tmindata(:,:,1);
mask = ones(size(d),'single');
f=find(isnan(d));
mask(f) = NaN;

for varnum=12:13;
	varname = char(VARIABLES{varnum});
	description = char(DESCRIPTIONS{varnum});
	stname = char(STANDARD_NAMES{varnum});
	units = char(UNITS{varnum});
	scale_factor = SCALE_FACTORS(varnum);
	add_offset = ADD_OFFSETS(varnum);
	intFormat = char(INTFORMATS{varnum});

	if(strcmp(varname,'q'));
		myFile=['/data/obs/obs/gridded/terraclim/MAT/runoff_19912020climo.mat'];
	else;
		myFile=['/data/obs/obs/gridded/terraclim/MAT/',varname,'_19912020climo.mat'];
	end;
	m=matfile(myFile);
	data = m.zz;	
	data = 	data .* repmat(mask,[1 1 12]);
	FULLFILENAME = ['TerraClimate19912020_',varname,'.nc'];
	make_layer_netcdf_integer(data,lat,lon,time,varname,units,FULLFILENAME,description,scale_factor,add_offset,intFormat);
end;


%==============================================
%	TMAX
%==============================================
myFile='/data/obs/obs/gridded/terraclim/MAT/tmax_19912020climo.mat';
m=matfile(myFile,'Writable',true);
m.units = 'deg C';
m.description = 'Mean monthly max temperature from TerraClimate 1991-2020'; 
data =m.zz;
scale_factor = 0.1;
add_offset = 0.0;
varname = 'tmax';
units = 'deg C';
FULLFILENAME = ['gridmet_',varname,'_monthlyClimatologies_19912020.nc'];
description = 'Average Maximum 2-m Temperature from 1991-2020';
make_layer_netcdf_integer(data,lat,lon,time,varname,units,FULLFILENAME,description,scale_factor,add_offset);

%==============================================
%	TMMN
%==============================================
tmin=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/climatologies/Summaries_1991-2020/gridmet_tmmn_dailyClimatologies.nc','tmmn');
for i=1:12
    tminm(:,:,i)=nanmean(tmin(:,:,d1(i):d2(i)),3);
end
clear tmin
data =tminm;
varname = 'tmmn';
units = 'K';
FULLFILENAME = ['gridmet_',varname,'_monthlyClimatologies_19912020.nc'];
description = 'Monthly average of min daily temperature from 4-km GRIDMET (1991-2020).'
make_layer_netcdf(data,lat,lon,time,varname,units,FULLFILENAME,description);

%==============================================
%       TMEAN
%==============================================
tmean=tminm/2+tmaxm/2;
data =tmean;
varname = 'tmean';
units = 'K';
FULLFILENAME = ['gridmet_',varname,'_monthlyClimatologies_19912020.nc'];
description = 'Monthly average of mean daily temperature from 4-km GRIDMET (1991-2020).'
make_layer_netcdf(data,lat,lon,time,varname,units,FULLFILENAME,description);

%==============================================
%       PET
%==============================================
pet=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/climatologies/Summaries_1991-2020/gridmet_pet_dailyClimatologies.nc','pet');
for i=1:12
    petm(:,:,i)=sum(pet(:,:,d1(i):d2(i)),3);
end
clear pet
data =petm;
varname = 'pet';
units = 'mm';
FULLFILENAME = ['gridmet_',varname,'_monthlyClimatologies_19912020.nc'];
description = 'Monthly total of potential evapotranspiration from 4-km GRIDMET (1991-2020) using the Penman-Monteith method.'
make_layer_netcdf(data,lat,lon,time,varname,units,FULLFILENAME,description);

%==============================================
%      PPT
%==============================================
ppt=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/MET/climatologies/Summaries_1991-2020/gridmet_ppt_dailyClimatologies.nc','ppt');
for i=1:12
    pptm(:,:,i)=sum(ppt(:,:,d1(i):d2(i)),3);
end
clear ppt
data =pptm;
varname = 'ppt';
units = 'mm';
FULLFILENAME = ['gridmet_',varname,'_monthlyClimatologies_19912020.nc'];
description = 'Monthly total of precipitation from 4-km GRIDMET (1991-2020).'
make_layer_netcdf(data,lat,lon,time,varname,units,FULLFILENAME,description);

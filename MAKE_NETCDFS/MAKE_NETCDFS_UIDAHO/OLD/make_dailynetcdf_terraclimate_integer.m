%note PDSI_2021 has units='' not 'unitless'.. might be an issue


function []=make_dailynetcdf_terraclimate_integer(varname,year);
%,inputDir,outputDir,gridFilename);
%function []=make_dailynetcdf_terraclimate_integer(varname,year);


outputDir = '';
gridFilename = '';

	%inputs:  
	%varname: variable name from the list below in VAR_NAME_IN_FILE
	%year: year from 1958 to 2015

        methodName='TerraClimate';
        inputDir='/data/obs/obs/gridded/terraclim/MAT/';
        outputDir='/data/obs/obs/gridded/terraclim/NETCDF/';
%        outputDir='/home/katherine/TERRA/DATA/';
	filename_location='/data/obs/obs/gridded/terraclim/MAT/lonlatel.mat';
        yrRef=1900;

        VAR_NAME_FILENAME = {'pet';'ppt';'srad';'tmax';'tmin';'vap';'ws';'wbupdate';'wbupdate';'wbupdate';'wbupdate';'wbupdate';'PDSI';'vpd'};
        VAR_NAME_IN_FILE = {'pet';'ppt';'srad';'tmax';'tmin';'vap';'ws';'def';'aet';'q';'soil';'swe';'PDSI';'vpd'};
        STD_NAME = {'water_potential_evaporation_amount';'precipitation_amount';'downwelling_shortwave_flux_in_air';'air_temperature';'air_temperature';'water_vapor_partial_pressure_in_air';'wind_speed';'water_potential_evaporation_amount_minus_water_evaporation_amount';'water_evaporation_amount';'runoff_amount';'soil_moisture_content';'liquid_water_content_of_surface_snow';'palmer_drought_severity_index';'vapor_pressure_deficit'};
        UNITS={'mm';'mm';'W/m^2';'degC';'degC';'kPa';'m/s';'mm';'mm';'mm';'mm';'mm';'unitless';'kPa'};
	DESCRIPTION={'Reference Evapotranspiration';'Accumulated Precipitation';'Downward Shortwave Radiation Flux at the Surface';'Maximum 2-m Temperature';'Minimum 2-m Temperature';'2-m Vapor Pressure';'Wind Speed at 10-m';'Climatic Water Deficit';'Actual Evapotranspiration';'Runoff';'Soil Moisture at End of Month';'Snow Water Equivalent at End of Month';'Palmer Drought Severity Index';'Vapor Pressure Deficit'};

	%compute scale and offset
	INT_FORMAT = {'int16';'int32';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int32';'int16';'int32';'int16';'int16'};
	MINVALUE=[-1;  -1;   -1;  -99;-99;-1; -1;  -1;   -1;    -1;   -1; -1;-50;-1;];   %extra padding so fill value can be smallest negative in
	MAXVALUE=[484;6390;528; 58; 39; 14.8;30;484; 331; 12561; 889; 108095;50;30;];	
	%SIGNEDORNOT =[0;0;0;1;1;1;0;0;0;0;0;0]; %signed variable or not
	SIGNEDORNOT =[0;0;0;0;0;0;0;0;0;0;0;0;0;0]; %signed variable or not  - keep all signed since all int__

	%For all moisture related variables than have units of mm, I think 0.1mm is sufficient (we can’t measure anything less than that). For wind speed 0.01; for radiation 0.1; vapor pressure 0.001 should work.  -John A, 7/5/2017
	SCALE=[0.1;0.1;0.1;0.01;0.01;0.001;0.01;0.1;0.1;0.1;0.1;0.1;0.01;0.01];
	ADDOFFSET=[0;0;0;-99;-99;0;0;0;0;0;0;0;-45;0]; %changed to -99 for tmin/tmax because was 0 and cutting off mountain values, changed PDSI to -15 for same reason

	 %for signed variables
        %scale_factor =(dataMax - dataMin) / (2^n^ - 1);
        %add_offset = dataMin + 2^n\ -\ 1^ * scale_factor;

        %for unsigned variables
        %scale_factor =(dataMax - dataMin) / (2^n^ - 1);
        %add_offset = dataMin;

	varToRun = find(strcmp(varname,VAR_NAME_IN_FILE));
        varname_infilename=char(VAR_NAME_FILENAME(varToRun));
        varname_infile=char(VAR_NAME_IN_FILE(varToRun));
        stdname=char(STD_NAME(varToRun));
        units=char(UNITS(varToRun));
        description=char(DESCRIPTION(varToRun));
        intFormat=char(INT_FORMAT(varToRun));


	%get fil value
	if(strcmp(intFormat,'int32'));
                fillvalue=int32(-2147483648); %min possible for int32=2^31
        elseif(strcmp(intFormat,'int16'));
                fillvalue=int16(-32768); %min possible for int16 =2^15
        elseif(strcmp(intFormat,'int8'));
               fillvalue =int8(-128); %min possible for int16 =2^7
        else;
                fillvalue =-9999;
        end;
	

        %================================
        %    DATA 
        %================================
        filename=[varname_infilename,'_',num2str(year),'.mat'];
        path=[inputDir,filename];
        filehandle=matfile(path); %[4320 8640 12]
        switch varToRun
             case 1
                data = filehandle.petdata;
             case 2
                data = filehandle.pptdata;
             case 3
                data = filehandle.sraddata;
		%data = data/ 86.4; %convert from kJ/m2/day to W/m2  %not true about .mat file data now 5/19/21 (KCH)
             case 4
                data = filehandle.tmaxdata;
             case 5
                data = filehandle.tmindata;
             case 6
                data = filehandle.vapdata;
             case 7
                data = filehandle.winddata;
             case 8
                data = filehandle.defdata;
             case 9
                data = filehandle.aetdata;
             case 10
                data = filehandle.runoffdata;
             case 11
                data = filehandle.soildata;
             case 12
                data = filehandle.snowdata;
             case 13
            	data = filehandle.PDSI;
                data = permute(data,[2 3 1]);
             case 14
                data = filehandle.vpddata;
        end;

	%================================
        %    DATA 
        %================================
% we are no longer adding station_influence since no longer using the CRU dataset. Feb 5,2026 - KCH
%	if(strcmp(varname,'ppt') || strcmp(varname,'tmax') || strcmp(varname,'tmin') || strcmp(varname,'vap'));
%		filename_meta=[varname_infilename,'meta_',num2str(year),'.mat'];
%		path_meta=[inputDir,filename_meta];
%		filehandle_meta=matfile(path_meta); %[4320 8640 12]
%		data_meta = filehandle_meta.metadata;
%		data_meta = single(data_meta);
%		%need to mask the meta with the mask from the data
%		f=find(isnan(data)); data_meta(f) = NaN;
%		data_meta = permute(data_meta,[2 1 3]);  %lon,lat,time
%	end;

	%=====================
	% CONVERT TO INT W SCALE/OFFSET
	%=====================
	scale = SCALE(varToRun);
	offset = ADDOFFSET(varToRun);
	%signedOrNot = SIGNEDORNOT(varToRun);

	data=round((data-offset)/scale);

	%=====================
	% PROCESS DATA
	%=====================
	f=find(isnan(data));data(f) =fillvalue;

	data = permute(data,[2 1 3]);  %lon,lat,time

        %================================
        %    TIME
        %================================
        %get time variable
        for m=1:12;
                time(m) = datenum(year,m,1)  -datenum(yrRef,1,1);
        end;
        %check on time
        %[Y,M,D]=datevec(time+datenum(yrRef,1,1));
	N_TIME=length(time);

        %================================
        %    LAT/LON 
        %================================
        %lat = matFile.lat;
        %lon = matFile.lon-360;
	filehandle_location=matfile(filename_location);
	lat=filehandle_location.lat;lat=lat(:,1);
	lon=filehandle_location.lon;lon=lon(1,:);
	N_LON = length(lon);
	N_LAT = length(lat);
	%N_LON = 8640;
	%N_LAT = 4320;

        %================================
        %   SET UP METADATA IN NETCDF FILE 
        %================================
	FULLFILENAME=[outputDir,methodName,'_',varname,'_',num2str(year),'.nc'];
  	if(exist(FULLFILENAME));
		system(['rm ',FULLFILENAME]);
	end;
  	if(~exist(FULLFILENAME));
		 nccreate(FULLFILENAME,'lat','Dimensions',{'lat',length(lat)});
                ncwrite(FULLFILENAME,'lat',lat);
                ncwriteatt(FULLFILENAME,'lat','units','degrees_north');
                ncwriteatt(FULLFILENAME,'lat','description','Latitude of the center of the grid cell');
                ncwriteatt(FULLFILENAME,'lat','long_name','latitude');
                ncwriteatt(FULLFILENAME,'lat','standard_name','latitude');
                ncwriteatt(FULLFILENAME,'lat','axis','Y');

                nccreate(FULLFILENAME,'lon','Dimensions',{'lon',length(lon)});
                ncwrite(FULLFILENAME,'lon',lon);
                ncwriteatt(FULLFILENAME,'lon','units','degrees_east');
                ncwriteatt(FULLFILENAME,'lon','description','Longitude of the center of the grid cell');
                ncwriteatt(FULLFILENAME,'lon','long_name','longitude');
                ncwriteatt(FULLFILENAME,'lon','standard_name','longitude');
                ncwriteatt(FULLFILENAME,'lon','axis','X');

                nccreate(FULLFILENAME,'time','Dimensions',{'time',length(time)});
                ncwrite(FULLFILENAME,'time',time);
		ncwriteatt(FULLFILENAME,'time','description',['days since ',num2str(yrRef),'-01-01']);
                ncwriteatt(FULLFILENAME,'time','units',['days since ' num2str(yrRef),'-01-01 00:00:00']);
                ncwriteatt(FULLFILENAME,'time','long_name','time');
                ncwriteatt(FULLFILENAME,'time','standard_name','time');
                ncwriteatt(FULLFILENAME,'time','calendar','gregorian');
	end;

	%================================
        % PROJECTION 
        %================================
        nccreate(FULLFILENAME,'crs','Dimensions',{'crs',1},'DataType','int16');
        ncwrite(FULLFILENAME,'crs',int16(3));
        ncwriteatt(FULLFILENAME,'crs','grid_mapping_name','latitude_longitude');
        ncwriteatt(FULLFILENAME,'crs','longitude_of_prime_meridian',0.0);
        ncwriteatt(FULLFILENAME,'crs','semi_major_axis',6378137.0);
        ncwriteatt(FULLFILENAME,'crs','inverse_flattening',298.257223563);
        ncwriteatt(FULLFILENAME,'crs','long_name','crs');

        %================================
        %   SET UP DATA IN NETCDF FILE 
        %================================
	%needs to be T,Y,X
	nccreate(FULLFILENAME,varname,'Dimensions',{'lon',N_LON,'lat',N_LAT,'time',N_TIME},'DataType',intFormat,'FillValue', fillvalue,'DeflateLevel',9); %for scale/offset
	if(strcmp(intFormat,'int32'));
		ncwrite(FULLFILENAME,varname,int32(data));
	elseif(strcmp(intFormat,'int16'));
		ncwrite(FULLFILENAME,varname,int16(data));
	elseif(strcmp(intFormat,'int8'));
		ncwrite(FULLFILENAME,varname,int8(data));
	else;

	end;
       ncwriteatt(FULLFILENAME,varname,'units',units);
        ncwriteatt(FULLFILENAME,varname,'description',description);
        ncwriteatt(FULLFILENAME,varname,'long_name',stdname);
        ncwriteatt(FULLFILENAME,varname,'standard_name',stdname);
        ncwriteatt(FULLFILENAME,varname,'missing_value',fillvalue);

        ncwriteatt(FULLFILENAME,varname,'dimensions','lon lat time');
        ncwriteatt(FULLFILENAME,varname,'grid_mapping','crs');
        ncwriteatt(FULLFILENAME,varname,'coordinate_system','WGS84,EPSG:4326');
        ncwriteatt(FULLFILENAME,varname,'scale_factor',scale);
        ncwriteatt(FULLFILENAME,varname,'add_offset',offset);

        %if(signedOrNot==0);
                %ncwriteatt(FULLFILENAME,varname,'_Unsigned','true');
        %else;
        ncwriteatt(FULLFILENAME,varname,'_Unsigned','false');
        %end;


	if(strcmp(varname,'ppt') || strcmp(varname,'tmax') || strcmp(varname,'tmin') || strcmp(varname,'vap'));
		if(0);
		%int4 covers integers 0 ->2^3 =8.. perfect
		intFormat_meta ='int8';
		fillvalue_meta =int8(-8); %min possible for int4 =2^3 =8 .... can't do int4 though
		 f=find(isnan(data_meta));data_meta(f) =fillvalue_meta;
		varname_meta = 'station_influence';
		 nccreate(FULLFILENAME,varname_meta,'Dimensions',{'lon',N_LON,'lat',N_LAT,'time',N_TIME},'DataType',intFormat_meta,'FillValue',fillvalue_meta); 
		ncwrite(FULLFILENAME,varname_meta,int8(data_meta));

	        ncwriteatt(FULLFILENAME,varname_meta,'units','none');
	        ncwriteatt(FULLFILENAME,varname_meta,'description','A number between 0 and 8, indicating the number of stations contributing to each grid value directly from CRU and interpolated to the TerraClimate grid. When this value is greater than 1, CRU data is used for the anomalies in the method. When this value is 0, JRA-55 is used for anomalies in the method.');
                ncwriteatt(FULLFILENAME,varname_meta,'long_name',varname_meta);
                ncwriteatt(FULLFILENAME,varname_meta,'standard_name',varname_meta');
                ncwriteatt(FULLFILENAME,varname_meta,'missing_value',fillvalue_meta');
		ncwriteatt(FULLFILENAME,varname_meta,'dimensions','lon lat time');
		ncwriteatt(FULLFILENAME,varname_meta,'grid_mapping','crs');
		ncwriteatt(FULLFILENAME,varname_meta,'coordinate_system','WGS84,EPSG:4326');
		ncwriteatt(FULLFILENAME,varname_meta,'_Unsigned','false');
		end;

		METHOD = 'These layers from TerraClimate were creating using climatically aided interpolation of monthly anomalies from the CRU Ts4.0 and Japanese 55-year Reanalysis (JRA-55) datasets with WorldClim v2.0 climatologies. We provide an additional layer(station_influence) of the number of stations contributing to each grid directly from CRU and interpolated to the TerraClimate grid. This is a number between 0 and 8. CRU data is used for anomalies where the station influence value is at least 1. JRA-55 is used for anomalies where the station influence is 0.';
        elseif(strcmp(varname,'pet'));
		METHOD = 'These layers from TerraClimate were derived from the essential climate variables of TerraClimate. Reference evapotranspiration was calculated using the ASCE Penman-Monteith approach for short grass. These values were further adjusted to account for reduced surface water flux when snow cover exists or prior to the onset of the growing season and active transpiration using an empirical relationship with temperature that accounts for precipitation phase changes.';
        elseif(strcmp(varname,'def')|| strcmp(varname,'aet') || strcmp(varname,'q') || strcmp(varname,'soil') || strcmp(varname,'swe'));
		METHOD = 'These layers from TerraClimate were derived from the essential climate variables of TerraClimate. Water balance variables, actual evapotranspiration, climatic water deficit, runoff, soil moisture, and snow water equivalent were calculated using a water balance model and plant extractable soil water capacity derived from Wang-Erlandsson et al (2016).';
	else;
		METHOD ='These layers from TerraClimate were creating using climatically aided interpolation of monthly anomalies from the Japanese 55-year Reanalysis (JRA-55) and WorldClim v2.0 climatologies. We do not provide an additional layer of station density since JRA-55 is used across the entire globe.';

	end;
	%write to global '/'
	ncwriteatt(FULLFILENAME,'/','method',METHOD);
	%================================
	% FIX METADATA
	%================================
	%status=system(['./terraclimate_metdata.sh ',num2str(year),' ',varname]);
	%================================
	%VIEW NETCDF INFO
	%================================
	%ncdisp(FULLFILENAME);

end

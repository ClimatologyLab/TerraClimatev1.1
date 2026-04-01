function create_nc_files(ncfilename,lat,lon,date,tmax,tmin,vap,pr,vs,srad,pet,aet,def,ro,soil,swe,pdsi,vpd);


version = 'V1.1'

%accomplishing getting a perfect 1/24-deg grid here

yrRef=1900;
FULLFILENAME=ncfilename
system(['rm ',FULLFILENAME])
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
time=date;
                nccreate(FULLFILENAME,'time','Dimensions',{'time',length(time)});
                ncwrite(FULLFILENAME,'time',time);
		ncwriteatt(FULLFILENAME,'time','description',['days since ',num2str(yrRef),'-01-01']);
                ncwriteatt(FULLFILENAME,'time','units',['days since ' num2str(yrRef),'-01-01 00:00:00']);
                ncwriteatt(FULLFILENAME,'time','long_name','time');
                ncwriteatt(FULLFILENAME,'time','standard_name','time');
                ncwriteatt(FULLFILENAME,'time','calendar','gregorian');
                ncwriteatt(FULLFILENAME,'time','axis','T');

	%================================
        % PROJECTION 
        %================================
        nccreate(FULLFILENAME,'crs','Dimensions',{'crs',1},'DataType','int16');
        ncwrite(FULLFILENAME,'crs',3);
        ncwriteatt(FULLFILENAME,'crs','grid_mapping_name','latitude_longitude');
        ncwriteatt(FULLFILENAME,'crs','longitude_of_prime_meridian',0.0);
        ncwriteatt(FULLFILENAME,'crs','semi_major_axis',6378137.0);
        ncwriteatt(FULLFILENAME,'crs','inverse_flattening',298.257223563);
        ncwriteatt(FULLFILENAME,'crs','long_name','crs');


data(:,:,1)=tmax;
data(:,:,2)=tmin;
data(:,:,3)=vap;
data(:,:,4)=pr;
data(:,:,5)=vs;
data(:,:,6)=srad;
data(:,:,7)=pet;
data(:,:,8)=aet;
data(:,:,9)=def;
data(:,:,10)=ro;
data(:,:,11)=soil;
data(:,:,12)=swe;
data(:,:,13)=pdsi;
data(:,:,14)=vpd;


	INT_FORMAT = {'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16';'int16'};
	MINVALUE=[-99;-99;-1; -1;  -1;   -1;    -1;   -1; -1;-1;-1;-1;-1;-1;-50;-1];   %extra padding so fill value can be smallest negative in
	MAXVALUE=[58; 39; 14.8;6390;30;528;484; 331;484; 12561; 889; 108095;50;30];	
	SIGNEDORNOT =[1;1;0;0;0;0;0;0;0;0;0;0;1;0]; %signed variable or not

	%For all moisture related variables than have units of mm, I think 0.1mm is sufficient (we canât measure anything less than that). For wind speed 0.01; for radiation 0.1; vapor pressure 0.001 should work.  -John A, 7/5/2017
	SCALE=[0.1;0.1;0.001;1;0.01;0.1;0.1;0.1;0.1;1;0.1;1;0.01;0.01];
	ADDOFFSET=[0;0;0;0;0;0;0;0;0;0;0;0;0;0];


%change data from (lat,lon) to (lon,lat)  -KCH change to make nc file more like other gridmet files
data = permute(data,[2 1 3]);

clear tmax tmin rmax rmin sph vs pr th srad pet erc bi fm100 fm1000

for i=1:14
switch i
case 1,vardes='Monthly Average Maximum Temperature';units='C';vs='tmmx';vn='maximum_air_temperature';
case 2,vardes='Monthly Average Minimum Temperature';units='C';vs='tmmn';vn='minimum_air_temperature';
case 3,vardes='Monthly Vapor Pressure';vs='vap';units='kPa';vn='vapor_pressure';
case 4,vardes='Monthly Accumulated Precipitation';units='mm';vs='pr';vn='precipitation_amount';
case 5,vardes='Monthly Mean Wind Speed';units='m/s';vs='vs';vn='wind_speed';
case 6, vardes='Monthly Mean downward shortwave radiation at surface';units='W m-2';vs='srad';vn='surface_downwelling_shortwave_flux_in_air';
case 7,vardes='Reference evapotranspiration (FAO-ASCE: Penman-Monteith)';vs='pet';units='mm';vn='potential_evapotranspiration';
case 8,vardes='Actual evapotranspiration';vs='aet';units='mm';vn='actual_evapotranspiration';
case 9,vardes='Climate Water Deficit';vs='def';units='mm';vn='climate_water_deficit';
case 10,vardes='Runoff';vs='ro';units='mm';vn='runoff';
case 11,vardes='Soil Moisture';vs='soil';units='mm';vn='soil_moisture_content';
case 12,vardes='Snow Water Equivalent';vs='swe';units='mm';vn='snow_water_equivalent';
case 13,vardes='Palmer Drought Severity Index';vs='pdsi';units='unitless';vn='palmer_drought_severity_index';
case 14,vardes='Monthly Vapor Pressure Deficit';vs='vpd';units='kPa';vn='vapor_pressure_deficit';
end

intFormat=INT_FORMAT(i);

	%get fil value
	if(strcmp(intFormat,'int32'));
                fillvalue=int32(-2147483648); %min possible for int32=2^31
        elseif(strcmp(intFormat,'int16'));
                fillvalue=int16(-32768); %min possible for int16 =2^15
        elseif(strcmp(intFormat,'int8'));
               fillvalue =int8(-128); %min possible for int16 =2^7
        else;
                fillvalue =-9999;
    end


%=====================
	% CONVERT TO INT W SCALE/OFFSET
	%=====================
	scale = SCALE(i);
	offset = ADDOFFSET(i);
	signedOrNot = SIGNEDORNOT(i);

	dataout=round((data(:,:,i)-offset)/scale);

t=find(isnan(dataout)==1);
dataout(t)=double(fillvalue);

varname=vs;
N_LON = 8640;
N_LAT = 4320;
intFormat=cell2mat(intFormat);
	nccreate(FULLFILENAME,varname,'Dimensions',{'lon',N_LON,'lat',N_LAT},'DataType',intFormat,'FillValue',fillvalue,'format','netcdf4','DeflateLevel',9); %for scale/offset
	if(strcmp(intFormat,'int32'));
		ncwrite(FULLFILENAME,varname,int32(dataout));
	elseif(strcmp(intFormat,'int16'));
		ncwrite(FULLFILENAME,varname,int16(dataout));
	elseif(strcmp(intFormat,'int8'));
		ncwrite(FULLFILENAME,varname,int8(dataout));
	end

       ncwriteatt(FULLFILENAME,varname,'units',units);
        ncwriteatt(FULLFILENAME,varname,'description',vardes);
        ncwriteatt(FULLFILENAME,varname,'long_name',vardes);
        ncwriteatt(FULLFILENAME,varname,'standard_name',vn);
        ncwriteatt(FULLFILENAME,varname,'missing_value',fillvalue);

        ncwriteatt(FULLFILENAME,varname,'dimensions','lon lat');
        ncwriteatt(FULLFILENAME,varname,'grid_mapping','crs');
        ncwriteatt(FULLFILENAME,varname,'coordinate_system','WGS84,EPSG:4326');
        ncwriteatt(FULLFILENAME,varname,'scale_factor',scale);
        ncwriteatt(FULLFILENAME,varname,'add_offset',offset);

	% removing unsigned as it caused an isssue with Simon@googles ingestions. 2026Feb6-CH
        %if(signedOrNot==0);
        %        ncwriteatt(FULLFILENAME,varname,'_Unsigned','true');
        %else;
        %        ncwriteatt(FULLFILENAME,varname,'_Unsigned','false');
       %end;

        ncwriteatt(FULLFILENAME,'/','version',version);
end


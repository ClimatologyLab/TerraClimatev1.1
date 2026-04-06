function []=make_layer_netcdf_integer(data,lat,lon,time,varname,units,FULLFILENAME,description,scale_factor,add_offset,intFormat);
	%=====================
	% replace missing data
	%=====================
	f_mask=find(isnan(data));

		nccreate(FULLFILENAME,'lat','Dimensions',{'lat',length(lat)});
		ncwrite(FULLFILENAME,'lat',lat);
		ncwriteatt(FULLFILENAME,'lat','units','degrees_north');
		ncwriteatt(FULLFILENAME,'lat','description','latitude of the center of the grid cell');
		ncwriteatt(FULLFILENAME,'lat','long_name','latitude');
		ncwriteatt(FULLFILENAME,'lat','standard_name','latitude');
		ncwriteatt(FULLFILENAME,'lat','axis','Y');

		nccreate(FULLFILENAME,'lon','Dimensions',{'lon',length(lon)});
		ncwrite(FULLFILENAME,'lon',lon);
		ncwriteatt(FULLFILENAME,'lon','units','degrees_east');
		ncwriteatt(FULLFILENAME,'lon','description','longitude of the center of the grid cell');
		ncwriteatt(FULLFILENAME,'lon','long_name','longitude');
		ncwriteatt(FULLFILENAME,'lon','standard_name','longitude');
		ncwriteatt(FULLFILENAME,'lon','axis','X');

	        nccreate(FULLFILENAME,'time','Dimensions',{'time',length(time)});
                ncwrite(FULLFILENAME,'time',time);
                ncwriteatt(FULLFILENAME,'time','units','months');
		%bad idea to write months.... doesn't work well with thredds
                ncwriteatt(FULLFILENAME,'time','description','months since January');
                ncwriteatt(FULLFILENAME,'time','long_name','time');
                ncwriteatt(FULLFILENAME,'time','calendar','months');
                ncwriteatt(FULLFILENAME,'time','standard_name','time');

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
		%   MISSING VALUES
		%================================
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
		%   ADJUST DATA FOR WRITING INTEGER FORMAT
		%================================
		min(data(:))
		max(data(:))
		data=round((data-add_offset)/scale_factor);

		INT_MAX = -fillvalue;
                INT_MIN = fillvalue;

		 if(min(data(:))<INT_MIN);
                        [' There is problem with casting to integer min=',num2str(min(data(:))),' from ', num2str(INT_MIN)]
                end;
                if(max(data(:))>INT_MAX);
                        [' There is problem with casting to integer for max=',num2str(max(data(:))) , 'from ',num2str(INT_MAX)]
                end;


		data(f_mask) = fillvalue;

		data = permute(data,[2 1 3]);

		%================================
		%   SET UP DATA IN NETCDF FILE 
		%================================
		nccreate(FULLFILENAME,varname,'Dimensions',{'lon',length(lon),'lat',length(lat),'time',length(time)},'FillValue',fillvalue','DeflateLevel',9,'DataType',intFormat);
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
		ncwriteatt(FULLFILENAME,varname,'long_name',varname);
		ncwriteatt(FULLFILENAME,varname,'standard_name',varname);
		 ncwriteatt(FULLFILENAME,varname,'missing_value',fillvalue);
		ncwriteatt(FULLFILENAME,varname,'dimensions','lon lat time');
		ncwriteatt(FULLFILENAME,varname,'grid_mapping','crs');
		ncwriteatt(FULLFILENAME,varname,'coordinate_system','WGS84,EPSG:4326');
		ncwriteatt(FULLFILENAME,varname,'scale_factor',scale_factor);
		ncwriteatt(FULLFILENAME,varname,'add_offset',add_offset);

		%================================
		% GLOBAL METADATA
		%================================
		%write to global '/'
		METHOD = 'These monthly climatologies were computed from TerraClimate v1.1 using years 1991-2020. In TerraClimate, water balance variables, actual evapotranspiration, climatic water deficit, runoff, soil moisture, and snow water equivalent were calculated using a water balance model and plant extractable soil water capacity derived from Wang-Erlandsson et al (2016).';
		ncwriteatt(FULLFILENAME,'/','method',METHOD);

		%================================
		%VIEW NETCDF INFO
		%================================
		%ncdisp(FULLFILENAME);
end

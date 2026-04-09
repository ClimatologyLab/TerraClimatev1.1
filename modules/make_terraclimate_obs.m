function data = make_terraclimate_obs(path_to_input_data,path_to_final_data, var, year);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_terraclimate_obs.m
%
% Generates historical TerraClimate fields based on observed
% climate data and preloaded climatologies.
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%   - Uses interp2, meshgrid
%
% Description:
%   This module calculates monthly TerraClimate fields for a
%   given year using observed data, climatology, and longitude/latitude
%   grids. Supports variables:
%       1 - Max temperature (°C)
%       2 - Min temperature (°C)
%       3 - Wind speed (m/s)
%       4 - Solar radiation (W/m^2)
%       5 - Precipitation (mm)
%       6 - Dewpoint / Vapor pressure
%
% Inputs:
%   path_to_input_data - Path to input data files
%   path_to_final_data - Path to final terraclimate .mat files
%   var   - Variable index (1-6)
%   year  - Year of the observations
%
% Outputs:
%   data  - 3-D matrix (lat x lon x month) of historical TerraClimate values
%
% Example usage:
%   data = make_terraclimate_obs('data/inputs','data/final',1,1980); %tmax for 1980
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------
% Get  lon, lat - Longitude and latitude grids for TerraClimate grid
%------------------------------------------
load([path_to_input_data,'lonlatel.mat']); %lat,lon

%------------------------------------------
% Load Monthly observed ERA5 data for the year (3-D: lon x lat x month)
%------------------------------------------
era5_matfile = matfile([path_to_input_data,'monthly_era5summary.mat']);
era5_VARNAMES = {'tmax';'tmin';'was';'rsds';'tp';'dew'};
era5_varname = char(era5_VARNAMES{var});
myyr = era5_matfile.(era5_varname)(:,:,:,year-1949); %1440 x 721 x 12 x 76

%------------------------------------------
% Load Monthly ERA5 climatology data for  1970 - 2000 (3-D: lon x lat x month)
%------------------------------------------
era5_climo_matfile = matfile([path_to_input_data,'climo_19712000_era5summary.mat']);
mclimo = era5_climo_matfile.(era5_varname); % 1440 x 721 x 12

%------------------------------------------
% Load Monthly WorldClim v2.0 climatology data for  1970 - 2000 (3-D: lon x lat x month)
%------------------------------------------
worldclim_VARNAMES = {'tmax';'tmin';'wind';'srad';'pr';'tdew';};
worldclim_varname = char(worldclim_VARNAMES{});
worldclim_climo_matfile = matfile([path_to_input_data,'worldclim_pr_global.mat']):
mbase_xygrid = worldclim_climo_matfile.(worldclim_varname); % 21600       43200          12   (x,y,months)

% Extract x,y grid of files
x = mbase_xygrid.x;
y = mbase_xygrid.y;

% Change WorldClim climatology from x,y grid to lon,lat grid
for month=1:12
 mbase(:,:,month)=interp2(lon,lat,mbase_xygrid(:,:,month),x,y);
end

%------------------------------------------
% Get  mlon, mlat - Longitude and latitude grids for input climatology
%------------------------------------------
x=ncread([path_to_input_data,'scalefactor_tasmax.nc'],'lon');
y=ncread([path_to_input_data,'scalefactor_tasmax.nc'],'lat');
[mlon,mlat]=meshgrid(x,y);

%------------------------------------------
% Compute anomalies
%------------------------------------------
if var == 5
    % For precipitation, anomalies are ratios
    anom = myr ./ mclimo;
else;
    % For all but precipitation, anomalies are differences
    anom = myr - mclimo;
end

%------------------------------------------
% Swap longitudes given ERA5 goes 0-360, but TerraClimate is -180 to 180
%------------------------------------------
k = anom(:,1:720,:);
anom(:,1:720,:) = anom(:,721:1440,:);
anom(:,721:1440,:) = k;

% Add padding for interpolation assistance
anom(:,1441,:) = anom(:,1,:);

%------------------------------------------
% Apply anomalies to WorldClim v2.0 baseline
%------------------------------------------
if var <= 4
    % Additive variables: temperature, wind, solar
    for mo = 1:12
        data(:,:,mo) = interp2(mlon, mlat, anom(:,:,mo), lon, lat) + mbase(:,:,mo);
    end
    if(var == 1);
	   tmaxdata  = data;
   elseif(var == 2);
	   tmindata  = data;
   elseif(var == 3);
	   winddata  = data;
   elseif(var == 4);
	   sraddata  = data;
   end;

elseif var == 5
    % Precipitation: multiplicative, with bounds
    % Clamping small and large values to bounds to be sure there are not wild anomalies due to very low climatological precipitaiton
    anom(isinf(anom)) = 1; % setting values of Inf to 1
    anom(anom > 10) = 10;  % setting values > 10 to 10

    anom(isnan(anom)) = 1; % setting values of NaN to 1
    anom(anom < 0) = 0;    % setting values < 0 to 0

    zz = mbase;

    % Setting precipitation below a threshold of 0.1 mm to the threshold
    zz(zz < 0.1) = 0.1; % ensure minimum baseline

    data = zeros(size(mbase));
    for mo = 1:12
        data(:,:,mo) = interp2(mlon, mlat, anom(:,:,mo), lon, lat) .* zz(:,:,mo);
    end
    pptdata = data;

elseif var == 6
    % Dewpoint / vapor pressure
    climovap = mbase * 10;

    % Setting all vapor pressure below a threshold of 0.01 kPa to the threshold
    climovap(climovap < 0.01) = 0.01;

    % Convert vapor pressure to dewpoint
    e1 = log(climovap / 6.112);
    Td = 243.5 * e1 ./ (17.67 - e1);

    for mo = 1:12
        tddata(:,:,mo) = interp2(mlon, mlat, anom(:,:,mo), lon, lat) + Td(:,:,mo);
    end

    % Convert back to vapor pressure w/ Magnus
    data = 6.112 * exp((17.67 * tddata) ./ (tddata + 243.5));
    data = reshape(data / 10, size(tddata));

    % Force non-negative values
    data(data < 0) = 0;
    vapdata = data;

end

%% ----------------------------------
% Save output
%% ----------------------------------
save([path_to_final_data, varname,'_', num2str(yr)], '-v7.3', [varname,'data']); % lon x lat x 12

end

function make_terraclimate_future(path_to_input_data,path_to_final_data,var, targetyear, delta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_terraclimate_future.m
%
% Generates future TerraClimate fields based on historical
% data, global warming scenarios, and scale factors.
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%   - Uses ncread, meshgrid, movmean, interp2
%   - movmean requires R2016b or later
%
% Description:
%   This module applies climate change scenarios to observed
%   TerraClimate data using scale factors and global warming
%   targets (e.g., +2°C, +4°C). Supports variables:
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
%   delta   - Global warming level (°C)
%   var          - Variable index (1-6)
%   targetyear   - Year for future scenario
%
% Required Data Files (NetCDF):
%   - scalefactor_<variable>.nc       : scale factors per variable
%   - TerraClimate_<variable>_<year>.nc : historical/future data
%   - TerraClimate_19912020_<variable>.nc : climatology reference
%   - NASAGISS.csv                     : global mean temperature
%
% Outputs:
%   Saves PET data to MAT file in the directory path_to_terraclimate_data:
%     terra_pet_<year>.mat                (observed)
%     terra_<delta>_pet_<year>.mat        (scenario)
%   data         - 3-D matrix (lat x lon x month) of future values  - QUESTION: is this the format of the saved data?
%
% Folder Structure:
%   Place NetCDF files in the working directory or adjust paths
%   according to your local data organization.
%
% Example usage:
%   delta = 4;
%   var = 1; % Tmax
%   targetyear = 2050;
%   data = make_terraclimate_future(var, targetyear, delta);
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%=============================================================
%%		LOAD SCALE FACTORS 
%%Load scale factors from NetCDF based on variable
%% var: 1=tmax, 2=tmin, 3=wind speed, 4=solar radiation, 5=precipitation, 6=dewpoint/vapor pressure
%%=============================================================
% Map variable indices to NetCDF filenames
nc_files = { ...
    'scalefactor_tasmax.nc', ...    % var = 1
    'scalefactor_tasmin.nc', ...    % var = 2
    'scalefactor_was.nc', ...       % var = 3
    'scalefactor_rsds.nc', ...      % var = 4
    'scalefactor_pr.nc', ...        % var = 5
    'scalefactor_tdmean.nc' ...     % var = 6
};

% Select the appropriate file
nc_file = nc_files{var};

% Read latitude, longitude, mean, and standard deviation scale factors
scalefactor = ncread([path_to_input_data,nc_file], 'ps_mean');  % mean scaling factor
scalefactors = ncread([path_to_input_data,nc_file], 'ps_std');  % std scaling factor

% Create meshgrid for interpolation later
Y = ncread(nc_file, 'lat');           % latitude
X = ncread(nc_file, 'lon');           % longitude
[x, y] = meshgrid(X, Y);

%%=============================================================
%%		LOAD GLOBAL MEAN TEMPERATURE, COMPUTE DELTA
%% Load global mean temperature (GMT) and compute delta for target year
%%=============================================================
% Remove the 5-year moving mean GMT from the observed part relative to 1850-1900 baseline
% NASA GISS data are adjusted to 1850-1900 reference
gmt_table = readtable([path_to_input_data,'NASAGISS.csv']);   % read NASA GISS CSV
GMT = gmt_table{:,3};                     % extract GMT column
GMT = movmean(GMT, 5);                    % % loess 5-year filter of GMT relative to 1850-1900 baseline

% Compute delta for target year relative to GMT
d2 = delta - GMT(targetyear - 1879);

%%=============================================================
%		LOAD TERRACLIMATE DATA AND CLIMATOLOGIES
%%=============================================================
% NOTE: These files need to be downloaded from here into the /data/ directory
% Climatology: http://thredds.northwestknowledge.net:8080/thredds/catalog/TERRACLIMATE_ALL/climatology/catalog.html
% Data:      http://thredds.northwestknowledge.net:8080/thredds/catalog/TERRACLIMATE_ALL/data/catalog.html

% Compute the target anomaly relative to observed GMT
d2 = delta - GMT(targetyear - 1879);

% Define variable mapping
varnames = {'tmax', 'tmin', 'ws', 'srad', 'ppt', 'vap'};

% Select variable name
varname = varnames{var};

% Read TerraClimate data file
data_file_template = [path_to_final_data,'TerraClimate_%s_%d.nc'];
data_nc_file = sprintf(data_file_template, varname, targetyear);
data = ncread(data_nc_file,varname);

% Read TerraClimate climatology file (1991 - 2020)
ref_file_template  = [path_to_final_data,'TerraClimate_19912020_%s.nc'];
ref_nc_file = sprintf(ref_file_template, varname);
refdata = ncread(ref_nc_file,varname);

% Read latitude and longitude from the corresponding data file
lat = ncread(data_nc_file, 'lat');
lon = ncread(data_nc_file, 'lon');

%%=============================================================
% 	APPLY SCALEFACTORS TO TERRACLIMATE FUTURE PROJECTIONS
%%=============================================================
if var <= 4
    %-------------------------------
    % Simple additive approach for temperature, wind speed, solar radiation
    %-------------------------------
    
    % Compute anomaly by Removing reference climatology
    data = data - refdata;
    
    % Apply multiplicative scaling for each month
    for j = 1:12
        data(:,:,j) = data(:,:,j) .* interp2(x, y, 1 + d2 .* scalefactors(:,:,j), lon, lat);
    end
    
    % Add back the reference climatology
    data = data + refdata;
    
    % Add the mean scalefactor contribution
    for j = 1:12
        data(:,:,j) = data(:,:,j) + d2 .* interp2(x, y, scalefactor(:,:,j), lon, lat);
    end

elseif var == 5;
    %-------------------------------
    % Relative scaling for precipitation
    %-------------------------------
    % Minimum bounds from precipitation ref data (0.1 mm) to avoid dividing by zero
    refdata(refdata < 0.1) = 0.1;
    
    % Compute anomaly as ratio
    data = data ./ refdata;
    
    % Apply multiplicative scaling
    for j = 1:12
        data(:,:,j) = data(:,:,j) .* interp2(x, y, 1 + d2 .* scalefactors(:,:,j), lon, lat);
    end
    
    % Convert anomaly back to absolute values
    data = data .* refdata;
    
    % Apply mean scalefactor contribution
    for j = 1:12
        data(:,:,j) = data(:,:,j) .* (1 + d2 .* interp2(x, y, scalefactor(:,:,j,5), lon, lat));
    end
    
    % Force all negative values to zero
    data(data < 0) = 0;

elseif var == 6;
    %-------------------------------
    % Convert from vapor pressure to dewpoint temperature
    %-------------------------------
    
    % Convert to dewpoint scale
    data = data * 10;
    refdata = refdata * 10;
    
    % Set minimum bounds to avoid log(0)
    data(data == 0) = 1e-4;
    refdata(refdata == 0) = 1e-4;
    
    % Convert vapor pressure to dewpoint temperature using Magnus formula
    data = (243.5 * log(data / 6.112)) ./ (17.67 - log(data / 6.112));
    refdata = (243.5 * log(refdata / 6.112)) ./ (17.67 - log(refdata / 6.112));
    
    % Compute anomaly by removing reference
    data = data - refdata;
    
    % Apply multiplicative scaling
    for j = 1:12
        data(:,:,j) = data(:,:,j) .* interp2(x, y, 1 + d2 .* scalefactors(:,:,j), lon, lat);
    end
    
    % Add back reference
    data = data + refdata;
    
    % Add mean scalefactor contribution
    for j = 1:12
        data(:,:,j) = data(:,:,j) + d2 .* interp2(x, y, scalefactor(:,:,j,8), lon, lat);
    end
    
    % Convert dewpoint to vapor pressure
    data = 6.112 * exp(17.67 * data ./ (243.5 + data));
    data = data / 10;
    
end

%% ----------------------------------
% Save output  - this is a new addition
%% ----------------------------------
%DEADBEEF - not sure that the dimension of data is right for these .mat files ...also do we round(data,1)? 
save([path_to_final_data, varname,'_', num2str(delta), 'C_', num2str(yr)], '-v7.3', ['data']);

end

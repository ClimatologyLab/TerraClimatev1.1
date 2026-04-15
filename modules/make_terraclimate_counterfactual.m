function data = make_terraclimate_counterfactual(path_to_input_data,path_to_input_data,var, targetyear)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_terraclimate_counterfactual.m
%
% Generates counterfactual TerraClimate fields based on
% historical data and GCM-based counterfactual deltas.
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%
% Description:
%   Applies counterfactual changes to observed TerraClimate
%   data for a given year. Supports variables:
%       1 - Max temperature (°C)
%       2 - Min temperature (°C)
%       3 - Solar radiation (W/m^2)
%       4 - Wind speed (m/s)
%       5 - Precipitation (mm)
%       6 - Vapor pressure
%
% Inputs:
%   path_to_input_data - Path to input data files
%   path_to_final_data - Path to final terraclimate .mat files
%   var          - Variable index (1-6)
%   targetyear   - Year for the counterfactual scenario
%
% Required Data Files (NetCDF):
%   - counterfactual_<variable>.nc    : GCM counterfactual deltas
%   - TerraClimate_<variable>_<year>.nc : historical data
%
% Outputs:
%   data         - 3-D matrix (lat x lon x month) of counterfactual values
%
% Notes:
%   Historical TerraClimate data need to be downloaded from:
%     http://thredds.northwestknowledge.net:8080/thredds/catalog/TERRACLIMATE_ALL/data/catalog.html
%   Counterfactuals available at:
%     https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%=============================================================
%% Load counterfactual delta and historical TerraClimate

% Map variable index to TerraClimate variable names
varnames = {'tmax','tmin','srad','ws','ppt','vap'};
varname_data  = varnames{var};

% Read counterfactual delta
delta_file = [path_to_input_data,'counterfactual_', varname_data, '.nc'];       % Counterfactual delta file
varname_delta = ['counterfactual_', varname_data];            % Variable name inside counterfactual file
delta = ncread(delta_file, varname_delta);

% Construct filenames
tc_file    = [path_to_final_data,'TerraClimate_', varname_data, '_', num2str(targetyear), '.nc']; % Historical TerraClimate
data = ncread(tc_file, varname_data);

% Read counterfactual lat/lon grid
x = ncread(delta_file, 'lon');
y = ncread(delta_file, 'lat');
[x, y] = meshgrid(x, y);

% Read historical TerraClimate data
lon = ncread(tc_file, 'lon');
lat = ncread(tc_file, 'lat');
[lon, lat] = meshgrid(lon, lat);
data = ncread(tc_file, varname_data);

%%=============================================================
%% Re-shape and permute for correct orientation
delta = reshape(delta, 181, 91, 12, []);      % reshape to lon x lat x month x year
delta = permute(delta, [2 1 3 4]);            % permute to lat x lon x month x year
data = permute(data, [2 1 3]);                % permute historical data

%%=============================================================
%% Apply counterfactual deltas
year_index = targetyear - 1849;  % assuming first delta year = 1850

if var <= 4
    % subtract additive deltas from historical data
    for j = 1:12
        data(:,:,j) = data(:,:,j) - interp2(x, y, delta(:,:,j,year_index), lon, lat);
    end
else
    % divide by multiplicative deltas (precipitation or vapor pressure)
    for j = 1:12
        data(:,:,j) = data(:,:,j) ./ interp2(x, y, delta(:,:,j,year_index), lon, lat);
    end
end

%% ----------------------------------
% Save output  - this is a new addition
%% ----------------------------------
%DEADBEEF - not sure that the dimension of data is right for these .mat files ...also do we round(data,1)?
save([path_to_final_data, varname,'_cf_', num2str(yr)], '-v7.3', ['data']);

end

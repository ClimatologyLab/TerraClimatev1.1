function make_pet_scenario(path_to_terraclimate_data, yr, co22, mode, delta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_pet_scenario.m
%
% Computes monthly Potential Evapotranspiration (PET) for
% TerraClimate using temperature, radiation, wind, and vapor
% pressure deficit inputs.
%
% This function is used for generating PET under:
%   - Future or counterfactual scenarios (with delta input)
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%   - Uses shiftdim, interp2, and custom functions (monthlyPET_co2)
%
% Inputs:
%   path_to_terraclimate_data - Path to terraclimate .mat files
%   yr    - Year to process (e.g., 1980, 2015)
%   co22  - Atmospheric CO₂ concentration (ppm)
%   delta - Scenario identifier (e.g., 2 or 4 for +2°C / +4°C)
%
% Outputs:
%   Saves PET data to MAT file in the directory path_to_terraclimate_data:
%     terra_pet_<year>.mat                (observed)
%     terra_<delta>_pet_<year>.mat        (scenario)
%
% Required Files:
%   - terra_<var>_<year>.mat (tmax, tmin, vpd, srad, ws)
%   - data/elevation/lonlatel.mat (lat, lon, elevation)
%   - monthlyPET_co2.m
%   - make_snow.m
%
% Notes:
%   - Ensures Tmax >= Tmin
%   - Applies snow correction factor to PET
%   - Handles NaNs/Infs in radiation fields
%
% Example usage:
%   make_pet_scenario(2050, 550, 4, 'data/terraclimate');     % +4°C scenario
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ----------------------------------
% Load spatial data (lat, lon, elevation(el))
%% ----------------------------------
addpath('../data/elevation');
file_elevation = 'lonlatel.mat';
lat = ncread(file_elevation,'lat');      % 8640        4320
lon = ncread(file_elevation,'lon');      % 8640        4320
el = ncread(file_elevation,'elevation'); % 8640   4320

% Atmospheric pressure from elevation (hPa)
P = 1013.25 * ((293 - 0.0065 * el) / 293) .^ 5.26;

%% ----------------------------------
% Load input climate variables
%% ----------------------------------
if nargin == 3
    % Observed data
    load([path_to_terraclimate_data, 'terra_vpd_', num2str(yr)]);      % vpddata
    load([path_to_terraclimate_data, 'terra_tmax_', num2str(yr)]);     % tmaxdata
    load([path_to_terraclimate_data, 'terra_tmin_', num2str(yr)]);     % tmindata
    load([path_to_terraclimate_data, 'terra_srad_', num2str(yr)]);     % sraddata
    load([path_to_terraclimate_data, 'terra_ws_', num2str(yr)]);       % winddata
else
    % Scenario data (future or counterfactual)
    load([path_to_terraclimate_data, 'terra_', num2str(delta), '_vpd_', num2str(yr)]);
    load([path_to_terraclimate_data, 'terra_', num2str(delta), '_tmax_', num2str(yr)]);
    load([path_to_terraclimate_data, 'terra_', num2str(delta), '_tmin_', num2str(yr)]);
    load([path_to_terraclimate_data, 'terra_', num2str(delta), '_srad_', num2str(yr)]);
    load([path_to_terraclimate_data, 'terra_', num2str(delta), '_wind_', num2str(yr)]);
end

%% ----------------------------------
% Ensure Tmax >= Tmin
%% ----------------------------------
f = find(tmaxdata < tmindata);
tmaxdata(f) = tmindata(f);

%% ----------------------------------
% Re-orient data (month x lat x lon)
%% ----------------------------------
tmaxdata = shiftdim(tmaxdata, 2);
tmindata = shiftdim(tmindata, 2);
winddata = shiftdim(winddata, 2);
vpddata  = shiftdim(vpddata, 2);
sraddata = shiftdim(sraddata, 2);

%% ----------------------------------
% Clean solar radiation data
%% ----------------------------------
sraddata(isnan(sraddata)) = 0;
sraddata(isinf(sraddata)) = 0;

%% ----------------------------------
% Compute PET using Penman-Monteith approach
%% ----------------------------------
ET = monthlyPET_co2(sraddata, tmaxdata, tmindata, winddata, ...
                   lat, el, 0.23, vpddata, co22);

%% ----------------------------------
% Apply snow correction factor
%% ----------------------------------
tmean = (tmaxdata + tmindata) / 2;
MF = 1 - make_snow(tmean + 273.15, 1);   % snow melt fraction
ET = ET .* MF;

%% ----------------------------------
% Format output
%% ----------------------------------
petdata = shiftdim(ET, 1);             % reshape from (month x lat x lon) to (lat x lon x month)
petdata = single(round(petdata, 1));   % convert to single precision

%% ----------------------------------
% Save output
%% ----------------------------------
if nargin == 3
    save([path_to_terraclimate_data, 'terra_pet_', num2str(yr)], '-v7.3', 'petdata');
else
    save([path_to_terraclimate_data, 'terra_', num2str(delta), '_pet_', num2str(yr)], '-v7.3', 'petdata');
end

end

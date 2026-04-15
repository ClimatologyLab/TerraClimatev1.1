function make_pet(path_to_input_data, path_to_final_data, yr, mode, co22, delta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_pet.m
%
% Computes monthly Potential Evapotranspiration (PET)
% for observed TerraClimate data using the Penman-Monteith
% formulation with CO₂ correction.
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%
% Description:
%   This script loads observed TerraClimate variables for a
%   given year and computes PET using:
%       - Radiation (srad)
%       - Temperature (tmax, tmin)
%       - Wind speed (ws)
%       - Vapor pressure deficit (vpd)
%       - Elevation and latitude
%
%   PET is adjusted by a snow mask so that evapotranspiration
%   does not occur when precipitation is snow-dominated.
%
% Inputs:
%   path_to_input_data - Path to input data
%   path_to_final_data - Path to final terraclimate .mat files
%   yr    - Year to process (e.g., 1980, 2015)
%   mode    - string for which data product ('obs','future','cf' for counterfactual)
%   co22  - (optional) Atmospheric CO₂ concentration (ppm)
%   delta - (optional) Scenario identifier (e.g., 2 or 4 for +2°C / +4°C)
%
% Outputs:
%   Saves:
%       pet_<year>.mat  (monthly PET, mm)
%
% Required Data Files:
%   - tmax_<year>.mat
%   - tmin_<year>.mat
%   - vpd_<year>.mat
%   - srad_<year>.mat
%   - ws_<year>.mat
%   - lonlatel.mat        (lat, lon, elevation)
%   - annual_co2.mat      (CO₂ concentration time series)
%
% Dependencies:
%   - monthlyPET_co2.m
%   - runsnow.m

% Notes:
%   - Ensures Tmax >= Tmin
%   - Applies snow correction factor to PET
%   - Handles NaNs/Infs in radiation fields
%
% Folder Structure:
%   Adjust paths below to match your local setup
%
% Example usage:
%   run_pet('data/input/', 'data/final/', 2000, 'obs');
%   run_pet('data/input/', 'data/final/', 2000, 'future', 600, 2);
%   run_pet('data/input/', 'data/final/', 2000, 'cf', 600);
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ---------------------------------------------------------
% Load static data
% ---------------------------------------------------------
if(strcmp(mode,'future') || strcmp(mode,'cf'));
	load([path_to_input_data,'annual_co2.mat']);             % co2
	load([path_to_input_data,'lonlatel.mat']);               % lat, lon, elevation(el)
end;

%% ---------------------------------------------------------
% Load TerraClimate variables for given year
% ---------------------------------------------------------
if(strcmp(mode,'obs'));
	load([path_to_final_data 'vpd_'  num2str(yr)]);    %vpddata = data;
	load([path_to_final_data 'tmax_' num2str(yr)]);    %tmaxdata = data;
	load([path_to_final_data 'tmin_' num2str(yr)]);   %tmindata = data;
	load([path_to_final_data  'srad_' num2str(yr)]);  % sraddata = data;
	load([path_to_final_data  'ws_'   num2str(yr)]);  %winddata = data;
elseif(strcmp(mode,'future'));
        load([path_to_final_data, 'vpd_', num2str(delta), 'C_',num2str(yr)]);  %vpddata = data;
   	load([path_to_final_data, 'tmax_', num2str(delta), 'C_', num2str(yr)]); %tmaxdata = data;
    	load([path_to_final_data, 'tmin_', num2str(delta), 'C_',num2str(yr)]);  %tmindata  = data;
    	load([path_to_final_data, 'srad_', num2str(delta), 'C_', num2str(yr)]); %sraddata = data;
    	load([path_to_final_data, 'ws_', num2str(delta),  'C_',num2str(yr)]);   %winddata = data;
elseif(strcmp(mode,'cf'));
	load([path_to_final_data 'vpd_cf_'  num2str(yr)]);   %vpddata = data;
	load([path_to_final_data 'tmax_cf_' num2str(yr)]);    %tmaxdata =data;
	load([path_to_final_data 'tmin_cf_' num2str(yr)]);   %tmindata =data;
	load([path_to_final_data  'srad_cf_' num2str(yr)]);  %  sraddata =data;
	load([path_to_final_data  'ws_cf_'   num2str(yr)]);   % winddata =data;
end;

% Ensure Tmax >= Tmin
f = find(tmaxdata < tmindata);
tmaxdata(f) = tmindata(f);

%% ---------------------------------------------------------
% Re-orient data (time x space)
% ---------------------------------------------------------
tmaxdata = shiftdim(tmaxdata, 2);
tmindata = shiftdim(tmindata, 2);
winddata = shiftdim(winddata, 2);
vpddata  = shiftdim(vpddata, 2);
sraddata = shiftdim(sraddata, 2);

%% ---------------------------------------------------------
% Clean radiation data
% ---------------------------------------------------------
sraddata(isnan(sraddata)) = 0;
sraddata(isinf(sraddata)) = 0;

%% ---------------------------------------------------------
% Compute PET using Penman-Monteith with CO₂ correction
% ---------------------------------------------------------
if(strcmp(mode,'obs'));
	co2_anomaly = co2(yr - 1849) - 300;
else;
	co2_anomaly = co22;
end;

ET = monthlyPET_co2(sraddata, tmaxdata, tmindata, winddata, ...
                   lat, el, 0.23, vpddata, co2_anomaly);

%% ---------------------------------------------------------
% Apply snow mask (reduce ET when snow present)
% ---------------------------------------------------------
tmean = (tmaxdata + tmindata) / 2;

MF = 1 - runsnow(tmean + 273.15, 1);   % melt fraction
ET = ET .* MF;

%% ---------------------------------------------------------
% Format output
% ---------------------------------------------------------
petdata = shiftdim(ET, 1);
petdata = single(round(petdata, 1));

%% ---------------------------------------------------------
% Save output
% ---------------------------------------------------------
if(strcmp(mode,'obs'));
	save([path_to_final_data, 'pet_' num2str(yr)], '-v7.3', 'petdata');
elseif(strcmp(mode,'future'));
	save([path_to_final_data, 'pet_',  num2str(delta), 'C_', num2str(yr)], '-v7.3', 'petdata');
elseif(strcmp(mode,'cf'));
	save([path_to_final_data, 'pet_cf_' num2str(yr)], '-v7.3', 'petdata');
end;

%% ---------------------------------------------------------
% Cleanup
% ---------------------------------------------------------
clear *data ET

end

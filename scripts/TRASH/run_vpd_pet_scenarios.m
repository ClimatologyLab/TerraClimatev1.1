%% run_vpd_pet_scenarios.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_vpd_pet_scenarios.m
%
% Computes Vapor Pressure Deficit (VPD) and runs PET calculations
% for TerraClimate future or counterfactual scenarios.
%
% Workflow:
%   1. Load vapor pressure, Tmax, Tmin
%   2. Compute saturation vapor pressure (es)
%   3. Compute VPD = es - vapor pressure
%   4. Save VPD fields
%   5. Run PET model (make_pet_counterfactual_future)
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%
% Inputs (set below):
%   delta      - Scenario warming level (2 or 4 °C)
%   deltaco2   - CO₂ adjustment (ppm above baseline ~300 ppm)
%   years      - Range of years to process
%
% Required Files:
%   - terra_<delta>_<var>_<year>.mat (vap, tmax, tmin)
%
% Custom Functions Required:
%   - make_pet_scenarios.m
%   - make_vpd_scenarios.m
%
% Example:
%   delta = 4;
%   deltaco2 = 800 - 300;
%   years = 1950:2025;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('../modules');

clear; clc;

%% ----------------------------------
% Settings
%% ----------------------------------
delta = 4;                  % +2 or +4 °C scenario
deltaco2 = 800 - 300;       % CO₂ adjustment (ppm)
years = 1950:2025;          % Years to process
path_to_terraclimate_data = 'data/terraclimate';

%% ----------------------------------
% Loop over years
%% ----------------------------------
for year = years;

    fprintf('Processing year %d (delta=%d)...\n', year, delta);

    %% -----------------------------
    % Run VPD model
    %% -----------------------------
    make_vpd_scenario(path_to_terraclimate_data, year, delta);

    %% -----------------------------
    % Run PET model
    %% -----------------------------
    make_pet_scenario(path_to_terraclimate_data, year, deltaco2, delta)
end

fprintf('All years processed successfully.\n');

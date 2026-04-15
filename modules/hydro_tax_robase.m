function [AET, DEF, RUNOFF, SNOWS, SOILS, RUNOFFSNOW, SRAIN, SSNOW] = simplehydromodel(TMEAN, PPT, PET, AWC, soil, snow, SRAIN, SSNOW)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simplehydromodel.m  (hydro_tax_robase equivalent)
%
% Simulates hydrologic water balance using a simple
% 1-bucket soil moisture model with snow dynamics.
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%
% Description:
%   This function computes monthly (or daily) water balance
%   components including:
%       - Actual Evapotranspiration (AET)
%       - Deficit (DEF)
%       - Runoff (RUNOFF)
%       - Snow storage (SNOWS)
%       - Soil moisture (SOILS)
%       - Snow runoff (RUNOFFSNOW)
%
%   The model includes:
%       - Rain/snow partitioning using temperature
%       - Snow accumulation and melt
%       - Soil moisture storage and drainage
%       - Runoff partitioning (rain vs snow)
%
% Inputs:
%   TMEAN  - Mean temperature (°C) [nPixels x nTime]
%   PPT    - Precipitation (mm)
%   PET    - Potential evapotranspiration (mm)
%   AWC    - Available water capacity (mm)
%   soil   - Initial soil moisture (mm)
%   snow   - Initial snow storage (mm)
%   SRAIN  - Surface runoff storage (rain component)
%   SSNOW  - Surface runoff storage (snow component)
%
% Outputs:
%   AET        - Actual evapotranspiration (mm)
%   DEF        - Water deficit (mm)
%   RUNOFF     - Total runoff (mm)
%   SNOWS      - Snow storage (mm)
%   SOILS      - Soil moisture (mm)
%   RUNOFFSNOW - Snow-derived runoff (mm)
%   SRAIN      - Updated rain storage
%   SSNOW      - Updated snow storage
%
% Dependencies:
%   - runsnow.m   (snow partitioning function)
%
% Notes:
%   - Designed for large gridded datasets
%   - Assumes inputs are pre-aligned spatially
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fraction of runoff retained between timesteps
fratio = 0.5;

% Initialize outputs
AET = single(zeros(size(PPT)));
DEF = AET;
RUNOFF = AET;
RUNOFFSNOW = AET;

% Initialize snow storage
snowstorage = snow;

% Loop over time (months or timesteps)
for j = 1:size(TMEAN,2)

    TMN = TMEAN(:,j);

    % Initialize intermediate variables
    drainsoil = zeros(size(TMN));
    snowdrink = zeros(size(TMN));

    %% --------------------------------------------------------
    % Partition precipitation into rain and snow
    % --------------------------------------------------------
    MF   = 1 - runsnow(TMN + 273.15, 1);  % melt fraction
    SNOW = (1 - MF) .* PPT(:,j);
    RAIN = MF .* PPT(:,j);

    % Snow melt contribution
    MELT  = MF .* (SNOW + snowstorage);
    INPUT = RAIN + MELT;

    % Fraction of rain contribution
    FRACTRAIN = max(0, RAIN ./ INPUT);
    FRACTRAIN(isinf(FRACTRAIN) | isnan(FRACTRAIN)) = 1;
    FRACTRAIN = min(1, FRACTRAIN);

    %% --------------------------------------------------------
    % Immediate runoff (5% of input)
    % --------------------------------------------------------
    extrarun = INPUT * 0.05;
    INPUT    = INPUT * 0.95;

    % Partition extra runoff into snow vs rain
    csnow = min(extrarun, MELT);
    RRAIN = extrarun - csnow;

    RAININPUT = RAIN - RRAIN;

    %% --------------------------------------------------------
    % Update snow storage
    % --------------------------------------------------------
    snowstorage = (1 - MF) .* (SNOW + snowstorage);

    %% --------------------------------------------------------
    % Soil moisture balance
    % --------------------------------------------------------
    deltasoil = INPUT - PET(:,j);

    % Excess liquid input after PET demand
    excessafterliquid = max(0, RAININPUT - PET(:,j));

    % Case: deficit (need water from snow/soil)
    f1 = find(deltasoil < 0);

    % Use snow first if available
    f2 = find(snowstorage(f1) > 0 & snowstorage(f1) > -deltasoil(f1));
    snowstorage(f1(f2)) = snowstorage(f1(f2)) + deltasoil(f1(f2));
    snowdrink(f1(f2))   = -deltasoil(f1(f2));
    deltasoil(f1(f2))   = 0;

    % If snow insufficient → draw from soil 
    % after eating snowpack, what else is needed from soil moisture?
    f3 = find(snowstorage(f1) > 0 & snowstorage(f1) < -deltasoil(f1));
    deltasoil(f1(f3))   = deltasoil(f1(f3)) + snowstorage(f1(f3));
    snowdrink(f1(f3))   = snowstorage(f1(f3));
    snowstorage(f1(f3)) = 0;

    % Limit soil drainage - can not drain more than is in soil!
    ff = find(-deltasoil > soil);
    deltasoil(ff) = -soil(ff);

    % Soil drainage function
    drainsoil(f1) = deltasoil(f1) .* (1 - exp(-soil(f1) ./ AWC(f1)));

    %% --------------------------------------------------------
    % Compute AET and DEF
    % --------------------------------------------------------
    demand = PET(:,j);
    supply = INPUT + snowdrink;  % supply without mining soil water

    f  = find(demand >= supply);
    f1 = find(demand < supply);

    % Water-limited case
    AET(f,j) = supply(f) - drainsoil(f);
    DEF(f,j) = PET(f,j) - AET(f,j);
    RUNOFF(f,j) = 0;
    soil(f) = soil(f) + drainsoil(f);

    % Energy-limited case
    AET(f1,j) = PET(f1,j);
    DEF(f1,j) = 0;

    % Soil saturation and runoff
    f2 = find(soil(f1) + deltasoil(f1) > AWC(f1));
    f3 = find(soil(f1) + deltasoil(f1) <= AWC(f1));

    excess = max(0, soil + deltasoil - AWC);
    excessrainonly = max(0, soil + excessafterliquid - AWC);

    RUNOFF(f1(f2),j)     = excess(f1(f2));
    RUNOFFSNOW(f1(f2),j) = excess(f1(f2)) - excessrainonly(f1(f2));

    soil(f1(f2)) = AWC(f1(f2));
    soil(f1(f3)) = soil(f1(f3)) + deltasoil(f1(f3));

    %% --------------------------------------------------------
    % Route runoff through storage pools
    % --------------------------------------------------------
    remainRAIN = fratio * SRAIN + fratio * (RUNOFF(:,j) - RUNOFFSNOW(:,j));
    remainSNOW = fratio * SSNOW + fratio * RUNOFFSNOW(:,j);

    RUNOFF(:,j)     = RUNOFF(:,j) * (1 - fratio) + (1 - fratio) * (SRAIN + SSNOW) + extrarun;
    RUNOFFSNOW(:,j) = RUNOFFSNOW(:,j) * (1 - fratio) + (1 - fratio) * SSNOW + csnow;

    SRAIN = remainRAIN;
    SSNOW = remainSNOW;

    %% Store state variables
    SOILS(:,j) = soil;
    SNOWS(:,j) = snowstorage;
end

end

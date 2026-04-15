function snow = make_snow(temp, precip)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_snow.m
%
% Estimates snowfall (or snow-equivalent precipitation)
% based on air temperature and total precipitation.
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%
% Description:
%   This function partitions precipitation into snow using
%   a temperature-dependent relationship based on a smoothed
%   hyperbolic tangent (tanh) transition.
%
%   - Cold temperatures → all precipitation falls as snow
%   - Warm temperatures → all precipitation falls as rain
%   - Transitional range → mixed phase (fractional snow)
%
% Inputs:
%   temp    - Air temperature (K)
%   precip  - Total precipitation (mm)
%
% Outputs:
%   snow    - Snowfall amount (mm), same size as inputs
%
% Notes:
%   - Temperature is internally converted from Kelvin to Celsius
%   - Snow fraction is constrained between 0–100%
%   - Empirical coefficients define transition curve
%
% Example:
%   snow = make_now(tmean + 273.15, ppt);
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ---------------------------------------------------------
% Empirical coefficients for snow fraction function
% ---------------------------------------------------------
a = -48.2292;
b = 0.7205;
c = 1.1662;
d = 1.0223;

%% ---------------------------------------------------------
% Convert temperature from Kelvin to Celsius
% ---------------------------------------------------------
temp = temp - 273.15;

%% ---------------------------------------------------------
% Compute snow fraction (%) using tanh-based transition
% ---------------------------------------------------------
snowf = a * (tanh(b * (temp - c)) - d);

%% ---------------------------------------------------------
% Apply physical bounds
% ---------------------------------------------------------

% Very cold → all precipitation is snow (100%)
f = find(temp < -2);
snowf(f) = 100;

% Warm → no snow (0%)
f = find(temp > 6.5);
snowf(f) = 0;

%% ---------------------------------------------------------
% Convert snow fraction to snowfall amount
% ---------------------------------------------------------
snow = single((snowf ./ 100) .* precip);

end

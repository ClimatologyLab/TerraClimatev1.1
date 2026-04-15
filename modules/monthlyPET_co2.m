function ET = monthlyPET_co2(radiation, tmax, tmin, wind, Lat, Z, albedo, vpd, co2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% monthlyPET_co2.m
%
% Computes monthly Potential Evapotranspiration (PET)
% using the FAO-56 Penman-Monteith equation with a CO₂
% adjustment applied to aerodynamic resistance.
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%
% Description:
%   This function estimates PET using radiation, temperature,
%   wind speed, vapor pressure deficit, latitude, and elevation.
%   A CO₂ correction is included to account for stomatal response
%   (higher CO₂ reduces evapotranspiration).
%
% Inputs:
%   radiation - Incoming shortwave radiation (W/m²)
%   tmax      - Maximum temperature (°C)
%   tmin      - Minimum temperature (°C)
%   wind      - Wind speed at 10 m (m/s)
%   Lat       - Latitude (degrees)
%   Z         - Elevation (m)
%   albedo    - Surface albedo (unitless, ~0.23 default)
%   vpd       - Vapor pressure deficit (kPa)
%   co2       - CO₂ anomaly relative to 300 ppm (ppm)
%
% Outputs:
%   ET        - Monthly PET (mm/month)
%
% Custom Functions:
%   - None required (standalone)
%
% Notes:
%   - Radiation converted from W/m² → MJ/m²/day
%   - Wind adjusted from 10 m → 2 m height
%   - Includes net radiation + soil heat flux
%   - Uses FAO-56 formulation (Allen et al. 1998)
%
% Reference:
%   Allen, R.G. et al. (1998). FAO Irrigation and Drainage Paper 56
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ---------------------------------------------------------
% Reshape inputs to 2D (gridcell x month)
% ---------------------------------------------------------
original_dimensions = size(radiation);
s1 = size(radiation);

radiation = reshape(radiation, 12, s1(3)*s1(2))';
tmax      = reshape(tmax,      12, s1(3)*s1(2))';
tmin      = reshape(tmin,      12, s1(3)*s1(2))';
wind      = reshape(wind,      12, s1(3)*s1(2))';
vpd       = reshape(vpd,       12, s1(3)*s1(2))';

Lat = Lat(:);
Z   = Z(:);

% Handle 4D input case
if ndims(radiation) == 4
    s1 = size(radiation);

    radiation = reshape(permute(radiation,[3 1 2]),12,s1(1)*s1(2))';
    tmax      = reshape(permute(tmax,[3 1 2]),12,s1(1)*s1(2))';
    tmin      = reshape(permute(tmin,[3 1 2]),12,s1(1)*s1(2))';
    wind      = reshape(permute(wind,[3 1 2]),12,s1(1)*s1(2))';
    vpd       = reshape(permute(vpd,[3 1 2]),12,s1(1)*s1(2))';

    Lat = Lat(:);
    Z   = Z(:);
end

%% ---------------------------------------------------------
% Unit conversions
% ---------------------------------------------------------
radiation = radiation * 0.0864;   % W/m² → MJ/m²/day

%% ---------------------------------------------------------
% Time constants
% ---------------------------------------------------------
daysinmonth = [31 28 31 30 31 30 31 31 30 31 30 31];
d1 = [1 32 60 91 121 152 182 213 244 274 305 335];

%% ---------------------------------------------------------
% Temperature variables
% ---------------------------------------------------------
tmean = (tmax + tmin) / 2;

% Month-to-month temperature change (for soil heat flux)
lasttmean = NaN(size(tmax));
for i = 2:size(tmax,2)
    lasttmean(:,i) = tmean(:,i) - tmean(:,i-1);
end
lasttmean(:,1) = tmean(:,1) - tmean(:,end);

%% ---------------------------------------------------------
% Wind speed adjustment (10m → 2m)
% Can be changed for ET at elevations other than 2m, but need 
% to scale using logarithmic increase in wind speed with elevation
% ---------------------------------------------------------
wind = wind .* (4.87 ./ log(67*10 - 5.42));

%% ---------------------------------------------------------
% Vapor pressure terms
% ---------------------------------------------------------
es1 = 0.6108 * exp(17.27 .* tmin ./ (tmin + 237.3));
es2 = 0.6108 * exp(17.27 .* tmax ./ (tmax + 237.3));
es  = (es1 + es2) / 2;

ea = es - vpd;
vpd(vpd < 0) = 0;

% Slope of vapor pressure curve
DEL = (4098 .* es) ./ (tmean + 237.3).^2;

%% ---------------------------------------------------------
% Atmospheric pressure + psychrometric constant
% ---------------------------------------------------------
P = 101.3 * ((293 - 0.0065*Z)/293).^5.26;
lambda = 2.501 - 2.361e-3 .* tmean;

GAM = 0.00163 .* repmat(P,[1 12]) ./ lambda;

%% ---------------------------------------------------------
% Solar geometry
% ---------------------------------------------------------
GSC = 0.082; % MJ m^-2 min^-1
phi = pi * Lat / 180;

%% ---------------------------------------------------------
% Main PET loop (monthly)
% ---------------------------------------------------------
for doy = 1:12

    % Compute clear-sky radiation (Rso)
    % assumed to be 75% TOA shortwave radiation or cloudless day, FAO, 1998
    for i = 1:daysinmonth(doy)
        DoY = d1(doy)-1+i;
        dr = 1 + 0.033*cos(2*pi/365 * DoY);
        delta = 0.409 * sin(2*pi/365*DoY - 1.39);
        omegas = acos(-tan(phi).*tan(delta));

        Ra = 24*60/pi .* GSC .* dr .* ...
            (omegas .* sin(phi).*sin(delta) + cos(phi).*cos(delta).*sin(omegas));

        Rso(:,i) = Ra .* (0.75 + 2e-5*Z);
    end

    %  Incomming solar radiation has already been corrected for macroscale
    %  albedo, may need to calibrate for actual albedo
    Rso = real(mean(Rso,2));
    Rso(Rso < 0 | isnan(Rso)) = 0;

    %% Radiation balance
    radfract = radiation(:,doy) ./ Rso;
    radfract(radfract > 1 | isnan(radfract) | isinf(radfract)) = 1;

    longw = 4.903e-9 * ...
        ((tmax(:,doy)+273.15).^4 + (tmin(:,doy)+273.15).^4)/2 .* ...
        (0.34 - 0.14*sqrt(ea(:,doy))) .* (1.35*radfract - 0.35);

    netrad = (radiation(:,doy) .* (1 - albedo) - longw) * daysinmonth(doy);

    %% Soil heat flux
    G = 0.14 .* lasttmean(:,doy) * daysinmonth(doy);

    %% Penman-Monteith terms
    TERM1 = 0.408 .* DEL(:,doy) .* (netrad - G);
    TERM2 = GAM(:,doy) .* wind(:,doy) .* vpd(:,doy) .* ...
            900 ./ (273.15 + tmean(:,doy)) * daysinmonth(doy);

	      
    %% This is the stomatal resistance scaling
    DENOMINATOR = DEL(:,doy) + GAM(:,doy) .* (1 + wind(:,doy) .* (0.34 + 2.4e-4 * co2));

    ET(:,doy) = (TERM1 + TERM2) ./ DENOMINATOR;

end

%% ---------------------------------------------------------
% Final cleanup
% ---------------------------------------------------------
ET(ET < 0) = 0;

% Reshape back to original dimensions
ET = reshape(ET', original_dimensions);

end

function [was, tmax, tmin, rmax, rmin, tp, u, v, dew, rsds] = save_year_summary_of_ERA5(year, new_MAT_path)
	%====================================
	%SUMMARIZEYEARERA5 Summarize ERA5 hourly data into daily statistics
	%   Inputs:
	%       year - Year of the ERA5 data
	%   Outputs:
	%       was  - Daily mean wind speed (m/s)
	%       tmax - Daily max temperature (°C)
	%       tmin - Daily min temperature (°C)
	%       rmax - Daily max relative humidity (%)
	%       rmin - Daily min relative humidity (%)
	%       tp   - Daily total precipitation (mm)
	%       u    - Daily mean u-component of wind (m/s)
	%       v    - Daily mean v-component of wind (m/s)
	%       dew  - Daily mean dew point temperature (°C)
	%       rsds - Daily mean surface solar radiation (W/m²)
	%====================================
	% Path to the new MAT file for this year
	%new_MAT_path = '/data/obs/reanalysis/ecmwf/era5/SFC/';

	%% Constants
	nx = 1440; % Longitude grid points
	ny = 721;  % Latitude grid points
	hours_per_day = 24;

	%====================================
	%% Compute daily mean wind components and wind speed
	%====================================
	%% Load and reshape wind components
	% V wind
	v_all = single(ncread(['download_v_', num2str(year), '.nc'], 'v10'));
	v = cat(3, squeeze(v_all(:,:,1,1:8016)), squeeze(v_all(:,:,2,8017:end)));

	% U wind
	u_all = single(ncread(['download_u_', num2str(year), '.nc'], 'u10'));
	u = cat(3, squeeze(u_all(:,:,1,1:8016)), squeeze(u_all(:,:,2,8017:end)));

	% Compute wind speed
	was = sqrt(u.^2 + v.^2);

	%====================================
	%% Get number of days
	%====================================
	%% Number of days
	nd = size(u,3) / hours_per_day;

	%====================================
	%% Load dew point - units of deg C
	%====================================
	dew_all = single(ncread(['download_dew_', num2str(year), '.nc'], 'd2m'));
	dew = cat(3, squeeze(dew_all(:,:,1,1:8016)), squeeze(dew_all(:,:,2,8017:end)));

	%====================================
	%% Load temperature - units of deg C
	%====================================
	t_all = single(ncread(['download_t_', num2str(year), '.nc'], 't2m'));
	t = cat(3, squeeze(t_all(:,:,1,1:8016)), squeeze(t_all(:,:,2,8017:end)));

	%====================================
	%% Compute relative humidity
	%====================================
	es = 6.112 * exp((17.67 * (t-273.15)) ./ (t-273.15 + 243.5));
	e  = 6.112 * exp((17.67 * (dew-273.15)) ./ (dew-273.15 + 243.5));
	rh = 100 * e ./ es;
	rh(rh > 100) = 100; % Cap at 100%

	%====================================
	%% Load solar radiation - convert to W/m^2
	%====================================
	rsds = single(ncread(['download_ssrd_', num2str(year), '.nc'], 'ssrd'));
	rsds = rsds / 3600; % Convert units to W/m^2

	%====================================
	%% Load precipitation - convert to mm/day
	%====================================
	tp_all = single(ncread(['download_', num2str(year), '.nc'], 'tp'));
	tp = cat(3, squeeze(tp_all(:,:,1,1:8016)), squeeze(tp_all(:,:,2,8017:end)));
	tp = tp * 1000; % Convert from m/day to mm/day

	%====================================
	%% Daily statistics - min, max, mean, sum over hourly amounts
	%====================================
	was  = squeeze(mean(reshape(was, nx, ny, hours_per_day, nd), 3));
	tmax = squeeze(max( reshape(t,    nx, ny, hours_per_day, nd), [], 3));
	tmin = squeeze(min( reshape(t,    nx, ny, hours_per_day, nd), [], 3));
	rmax = squeeze(max( reshape(rh,   nx, ny, hours_per_day, nd), [], 3));
	rmin = squeeze(min( reshape(rh,   nx, ny, hours_per_day, nd), [], 3));
	tp   = squeeze(sum( reshape(tp,    nx, ny, hours_per_day, nd), 3));
	u    = squeeze(mean(reshape(u,    nx, ny, hours_per_day, nd), 3));
	v    = squeeze(mean(reshape(v,    nx, ny, hours_per_day, nd), 3));
	dew  = squeeze(mean(reshape(dew,  nx, ny, hours_per_day, nd), 3));
	rsds = squeeze(mean(reshape(rsds, nx, ny, hours_per_day, nd), 3));

	%====================================
	%% Round to desired precision
	%====================================
	was  = round(was, 1);
	tmax = round(tmax, 1);
	tmin = round(tmin, 1);
	rmax = round(rmax, 1);
	rmin = round(rmin, 1);
	tp   = round(tp, 1);
	u    = round(u, 1);
	v    = round(v, 1);
	dew  = round(dew, 1);
	rsds = round(rsds, 1);

	%====================================
	%% Save monthly MAT file
	%====================================
	m=matfile([new_MAT_path,num2str(year),'data.mat'],'Writable',true);
	m.was = was;
	m.tmax = tmax;
	m.tmin = tmin;
	m.rmax  = rmax;
	m.rmin = rmin;
	m.tp = tp;
	m.u = u;
	m.v = v;
	m.dew = dew;
	m.rsds = rsds;
end

function [month_tmax, month_tmin, month_rsds, month_was, month_tp, month_dew] = compute_monthly_values_for_year(year, new_MAT_path)
	%MONTHVALS Compute monthly averages from daily ERA5 summaries
	%   Inputs:
	%       year - Year of the data
	%   Outputs:
	%       month_tmax  - Monthly mean of daily maximum temperature
	%       month_tmin  - Monthly mean of daily minimum temperature
	%       month_rsds  - Monthly mean of surface solar radiation
	%       month_was   - Monthly mean wind speed
	%       month_tp    - Monthly total precipitation
	%       month_dew   - Monthly mean dew point temperature

	 % Path to the new MAT file for this year
        %new_MAT_path = '/data/obs/reanalysis/ecmwf/era5/SFC/';

	%% Load yearly data
	m = matfile([new_MAT_path,num2str(year), 'data.mat']);

	%% Preallocate arrays
	[nx, ny, ~] = size(m.tmax); % Get spatial dimensions
	month_tmax  = nan(nx, ny, 12);
	month_tmin  = nan(nx, ny, 12);
	month_rsds  = nan(nx, ny, 12);
	month_was   = nan(nx, ny, 12);
	month_tp    = nan(nx, ny, 12);
	month_dew   = nan(nx, ny, 12);

	%% Compute monthly averages
	for month = 1:12
	    % Determine start and end day indices in the year
	    start_day = datenum(year, month, 1) - datenum(year, 1, 0);
	    end_day   = datenum(year, month + 1, 0) - datenum(year, 1, 0);
	    
	    % Compute monthly means
	    month_tmax(:,:,month)  = nanmean(m.tmax(:,:,start_day:end_day), 3);
	    month_tmin(:,:,month)  = nanmean(m.tmin(:,:,start_day:end_day), 3);
	    month_rsds(:,:,month)  = nanmean(m.rsds(:,:,start_day:end_day), 3);
	    month_was(:,:,month)   = nanmean(m.was(:,:,start_day:end_day), 3);
	    month_tp(:,:,month)    = nanmean(m.tp(:,:,start_day:end_day), 3);
	    month_dew(:,:,month)   = nanmean(m.dew(:,:,start_day:end_day), 3);
	end

	% Save monthly data to mat file
	mnew = matfile('monthly_era5summary.mat','Writable',true);
	mnew.

end

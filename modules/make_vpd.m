function make_vpd(path_to_final_data, yr, mode, delta);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_vpd_scenario.m
%
% Computes monthly  Vapor Pressure Deficit (VPD) for
% TerraClimate using temperature and vapor pressure inputs. 
%
% This function is used for generating VPD under:
%   - Future or counterfactual scenarios (with delta input)
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%   - Uses round, and save
%
% Inputs:
%   path_to_final_data - Path to terraclimate .mat files
%   yr    - Year to process (e.g., 1980, 2015)
%   mode    - string for which data product ('obs','future','cf' for counterfactual)
%   delta - Scenario identifier (e.g., 2 or 4 for +2°C / +4°C)
%
% Outputs:
%   Saves VPD data to MAT file in the directory path_to_final_data:
%     vpd_<year>.mat           (observation)
%     vpd_<delta>C_<year>.mat   (future)
%     vpd_cf_<year>.mat        (counterfactual)
%
% Required Files:
%   - <var>_<year>.mat (tmax, tmin, vap)
%   - or <var>_2C_<year>.mat (tmax, tmin, vap)
%   - or <var>_4C_<year>.mat (tmax, tmin, vap)
%   - or <var>_cf_<year>.mat (tmax, tmin, vap)
%
% Example usage:
%   make_vpd('data/final', 2020, 'obs');     % observations
%   make_vpd('data/final', 2020, 'future', 2);     % +2°C scenario
%   make_vpd('data/final', 2020, 'future', 4);     % +4°C scenario
%   make_vpd('data/final', 2020, 'cf');     % counterfactual scenario
%
% Date: 2026-04-06
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% -----------------------------
    % Load input variables
    %% -----------------------------
    if strcmp(mode,'obs');
	    load([path_to_final_data, 'vap_', num2str(year)]);  %vapdata = data;
	    load([path_to_final_data, 'tmax_', num2str(year)]); %tmaxdata = data;
	    load([path_to_final_data, 'tmin_', num2str(year)]); %tmindata = data;
    elseif strcmp(mode,'future');
	    load([path_to_final_data, 'vap_', num2str(delta), 'C_', num2str(year)]);  %vapdata = data;
	    load([path_to_final_data, 'tmax', num2str(delta), 'C_', num2str(year)]); %tmaxdata = data;
	    load([path_to_final_data, 'tmin_', num2str(delta), 'C_', num2str(year)]); %tmindata = data;
    elseif strcmp(mode,'cf');
	    load([path_to_final_data, 'vap_cf_', num2str(year)]);  %vapdata = data;
	    load([path_to_final_data, 'tmax_cf_', num2str(year)]); %tmaxdata = data;
	    load([path_to_final_data, 'tmin_cf_', num2str(year)]); %tmindata = data;
    end;

    %% -----------------------------
    % Compute saturation vapor pressure (es)
    % Using Magnus equation
    %% -----------------------------
    es = 6.112 .* exp((17.67 .* tmaxdata) ./ (tmaxdata + 243.5)) / 2 + ...
         6.112 .* exp((17.67 .* tmindata) ./ (tmindata + 243.5)) / 2;

    %% -----------------------------
    % Compute Vapor Pressure Deficit (VPD)
    %% -----------------------------
    vpddata = es / 10 - vapdata;

    % Clean up
    vpddata = round(vpddata, 4);
    vpddata(vpddata < 0) = 0;

    clear es tmaxdata tmindata vapdata

    %% -----------------------------
    % Save VPD
    %% -----------------------------
    if strcmp(mode,'obs');
    	save([path_to_final_data, 'vpd_', num2str(year)], '-v7.3', 'vpddata');
    elseif strcmp(mode,'future');
    	save([path_to_final_data, 'vpd_', num2str(delta), 'C_', num2str(year)], '-v7.3', 'vpddata');
    elseif strcmp(mode,'cf');
    	save([path_to_final_data, 'vpd_cf_', num2str(year)], '-v7.3', 'vpddata');
    end;

end

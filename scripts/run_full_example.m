%% run_future_example.m
% Example script to generate observation and scenario TerraClimate
% Date: 2026-04-06
%================================================================

%% Add modules folder to MATLAB path
addpath('../modules');  	% Assumes running this from the scripts/ folder

%% Paths to data storage
path_to_final_data = 'data/final/';
path_to_int_data = 'data/intermediary/';
path_to_input_data = 'data/input/';

%% Settings
target_years = 1950:2025;          % Years to generate future fields

target_var = 1:6;                  % Climate variables to process (1=tmax, 2=tmin, etc.)
                                    % 1=tmax, 2=tmin, 3=wind speed, 4=solar radiation
                                    % 5=precipitation, 6=dewpoint/vapor pressure

delta = 4;                  % +2 or +4 °C scenario for Global warming
deltaco2 = 800 - 300;       % CO₂ adjustment (ppm)

%%==============================================================
%%              OBSERVATIONS RUN
%% Loop over years to create the terraclimate variables for observations
%%==============================================================
mode = 'obs'
for year = target_years;
    %% -----------------------------
    % Run model for TMAX, TMIN, WS, SRAD, PPT, VAP
    %% -----------------------------
    year_index = year - min(target_years) + 1;
    for var = target_var;
            fprintf('Processing year %d...\n', year);
            make_terraclimate_obs(path_to_input_data,path_to_final_data,var, yr);
    end;
    %% -----------------------------
    % Run model for VPD
    %% -----------------------------
    make_vpd(path_to_final_data, year, mode);

    %% -----------------------------
    % Run model for PET
    %% -----------------------------
    make_pet_obs(path_to_input_data, path_to_final_data, year)
end
%% -----------------------------
% Run model for Water Balance metrics (SM, SWE,Q )
%% -----------------------------
make_wb(path_to_int_data, deltaco2, mode);

%%==============================================================
%%		FUTURE SCENARIO
%% Loop over years to create the terraclimate variables for future scenario
%%==============================================================
mode = 'future';
for year = target_years
    %% -----------------------------
    % Run model for TMAX, TMIN, WS, SRAD, PPT, VAP
    %% -----------------------------
    year_index = year - min(target_years) + 1;
    for var = target_var;
	    fprintf('Processing year %d...\n', year);
	    make_terraclimate_future(var, year, delta);
    end;
    %% -----------------------------
    % Run model for VPD
    %% -----------------------------
    make_vpd(path_to_final_data, year, mode, delta);

    %% -----------------------------
    % Run model for PET
    %% -----------------------------
    make_pet_scenario(path_to_final_data, year, deltaco2, mode, delta)

end
%% -----------------------------
% Run model for Water Balance metrics (SM, SWE, Q) 
%% -----------------------------
make_wb(path_to_int_data, mode, delta)

%%==============================================================
%%              COUNTERFACTUAL SCENARIO
%% Loop over years to create the terraclimate variable for counterfactual scenario
%%==============================================================
mode = 'cf';
delta = 0;  %DEADBEEF:not sure this is correct
for year = target_years
    %% -----------------------------
    % Run model for TMAX, TMIN, WS, SRAD, PPT, VAP
    %% -----------------------------
    year_index = year - min(target_years) + 1;
    for var = target_var;
            fprintf('Processing year %d...\n', year);
            make_terraclimate_counterfactual(var, year);
    end;
    %% -----------------------------
    % Run model for VPD
    %% -----------------------------
    %% not sure how this is made to be counterfactual... leave off the delta?
    make_vpd(path_to_final_data, year, mode, delta);

    %% -----------------------------
    % Run model for PET
    %% -----------------------------
    %% not sure how this is made to be counterfactual...leave off the delta?
    make_pet_scenario(path_to_final_data, year, deltaco2, mode, delta)

    %% -----------------------------
    % Run model for Water Balance metrics (SM, SWE, Q)
    %% -----------------------------
    make_wb(path_to_int_data, mode, delta)
end


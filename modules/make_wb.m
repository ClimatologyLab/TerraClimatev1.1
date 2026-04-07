function make_wb(path_to_input_data,path_to_int_data,mode,delta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_wb.m
%
% Runs monthly water balance model (AET, runoff, soil moisture,
% snow dynamics) for TerraClimate under observed or scenario
% (future / counterfactual) conditions.
%
% Workflow:
%   1. Load previous year soil/snow state (or initialize)
%   2. Load temperature, precipitation, PET
%   3. Compute water balance via hydrologic model
%   4. Aggregate outputs into global grids
%   5. Save results for next timestep
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%   - Uses parfor, shiftdim, interp-style indexing
%
% Inputs (defined in workspace):
%   path_to_input_data   - directory containing input data files
%   path_to_int_data   - directory containing intermediary .mat files
%   mode    - string for which data product ('obs','future','cf' for counterfactual)
%   delta   - (optional) scenario (e.g., 2 or 4 °C) for mode = 'future'
%
% Required Input Files:
%   - terra_<var>_<year>.mat OR terra_<delta>_<var>_<year>.mat
%       (tmax, tmin, ppt, pet)
%   - terra_wbupdate_<year-1>.mat (initial conditions)
%
% Custom Functions Required:
%   - hydro_tax_robase.m   (core water balance model)
%
% Outputs:
%   - terra_wbupdate_<year>.mat
%   - or terra_<delta>_wbupdate_<year>.mat
%
% Notes:
%   - Uses chunked + parallel processing for large grids
%   - Maintains soil and snow state between years
%
% Date: 2026-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ---------------------------------------------------------
% Initial spin up
% ---------------------------------------------------------
% DEADBEEF: Need to acquire a the soil water holding capacity layer
% https://hess.copernicus.org/articles/20/1459/2016/hess-20-1459-2016.pdf
soilt =  ; % soil water holding capacity grid

chunk = 100 ; %chunk size for parallel processing

% ---------------------------------------------------------
% Loop over years
% ---------------------------------------------------------
for year = years; %needs to be run in order.. do not parfor

    fprintf('Running water balance for year %d...\n', year);

    %% -----------------------------------------------------
    % Initialize or load previous state
    %% -----------------------------------------------------
    if year > 1950
        % Load previous year state variables 
	%DEADBEEF - shouldn't we be loading the data just saved for previous year, 
	% ie.. terra_wbupdate_',num2str(year-1) or 'terra_',num2str(delta),'_wbupdate_',num2str(year-1)
	% 					or  'terra_cf_wbupdate_',num2str(year-1)
 	if strcmp(mode,'obs');
		load([path_to_int_data,'wbupdate_',num2str(year-1)], ...
		    'snowdata','soildata','SSRAIN','SSSNOW');
 	elseif strcmp(mode,'future');
		load([path_to_int_data,'wbupdate_',num2str(delta),'C_',num2str(year-1)], ...
		    'snowdata','soildata','SSRAIN','SSSNOW');
	elseif strcmp(mode,'cf');
		load([path_to_int_data,'wbupdate_cf_',num2str(year-1)], ...
		    'snowdata','soildata','SSRAIN','SSSNOW');
	end

        % Extract last month state (December)
        soillast = soildata(:,:,12);
        snowlast = snowdata(:,:,12);

        % Flatten for vectorized processing
        SSSNOW = SSSNOW(:)';
        SSRAIN = SSRAIN(:)';
        snowlast = snowlast(:)';
        soillast = soillast(:)';

    else
        % Initial conditions (spin-up)
        soillast = soilt * 0.5;
        snowlast = soillast;
        SSSNOW = soillast * 0.2;
        SSRAIN = soillast * 0.2;
    end

    clear snowdata soildata runoff*

    %% -----------------------------------------------------
    % Load temperature data
    %% -----------------------------------------------------
    if strcmp(mode,'obs');
        load([path_to_input_data,'tmax_',num2str(year)]); %tmaxdata = data;
        load([path_to_input_data,'tmin_',num2str(year)]); %tmindata = data;
    elseif strcmp(mode,'future');
        load([path_to_input_data,'tmax_',num2str(delta),'C_',num2str(year)]); %tmaxdata = data;
        load([path_to_input_data,'tmin_',num2str(delta),'C_',num2str(year)]); %tmindata = data;
    elseif strcmp(mode,'cf');
        load([path_to_input_data,'tmax_cf_',num2str(year)]); %tmaxdata = data;
        load([path_to_input_data,'tmin_cf_',num2str(year)]); %tmindata = data;
    end

    % Mean temperature
    tmean = (tmaxdata + tmindata) / 2;
    clear tmaxdata tmindata

    %% -----------------------------------------------------
    % Load PET and precipitation
    %% -----------------------------------------------------
    if strcmp(mode,'obs');
        load([path_to_int_data,'pet_',num2str(year)]); %petdata
        load([path_to_int_data,'ppt_',num2str(year)]); %pptdata = data;
    elseif strcmp(mode,'future');
        load([path_to_int_data,'pet_',num2str(delta),'C_',num2str(year)]); %petdata
        load([path_to_int_data,'pet_',num2str(delta),'C_',num2str(year)]); %pptdata = data;
    elseif strcmp(mode,'cf');
        load([path_to_int_data,'pet_cf_',num2str(year)]); %petdata
        load([path_to_int_data,'ppt_cf_',num2str(year)]); %pptdata = data;
    end

    %% -----------------------------------------------------
    % Prepare data (flatten valid grid cells)
    %% -----------------------------------------------------
    f = find(~isnan(tmean(:,:,1)));

    tmean   = shiftdim(tmean,2);
    pptdata = shiftdim(pptdata,2);
    petdata = shiftdim(petdata,2);

    tmean   = tmean(:,f);
    pptdata = pptdata(:,f);
    petdata = single(petdata(:,f));

    %% -----------------------------------------------------
    % Run hydrologic model (parallelized by chunks)
    %% -----------------------------------------------------
    parfor i = 1:12
        idx = 1 + chunk*(i-1) : chunk*i;

        [AET(i).data, DEF(i).data, RO(i).data, ...
         SNOW(i).data, SOIL(i).data, ROSNOW(i).data, ...
         RSSRAIN(i).data, RSSSNOW(i).data] = ...
         hydro_tax_robase( ...
            tmean(:,idx)', ...
            pptdata(:,idx)', ...
            petdata(:,idx)', ...
            soilt(f(idx))', ...
            soillast(f(idx))', ...
            snowlast(f(idx))', ...
            SSRAIN(f(idx))', ...
            SSSNOW(f(idx))' );
    end

    %% -----------------------------------------------------
    % Process remaining grid cells (edge case)
    %% -----------------------------------------------------
    last4 = chunk*12+1 : chunk*12+4;

    [aaet,ddef,rro,snoww,soill,rros,sr1,sr2] = ...
        hydro_tax_robase( ...
            tmean(:,last4)', ...
            pptdata(:,last4)', ...
            petdata(:,last4)', ...
            soilt(f(last4))', ...
            soillast(f(last4))', ...
            snowlast(f(last4))', ...
            SSRAIN(f(last4))', ...
            SSSNOW(f(last4))' );

    clear petdata tmean pptdata

    %% -----------------------------------------------------
    % Reconstruct full global grids
    %% -----------------------------------------------------
    aetdata        = single(NaN(12,4320,8640));
    defdata        = aetdata;
    runoffdata     = aetdata;
    snowdata       = aetdata;
    soildata       = aetdata;
    runoffsnowdata = aetdata;

    SSRAIN = single(NaN(4320,8640));
    SSSNOW = SSRAIN;

    for i = 1:12
        idx = 1 + chunk*(i-1) : chunk*i;

        aetdata(:,f(idx))        = AET(i).data';
        defdata(:,f(idx))        = DEF(i).data';
        runoffdata(:,f(idx))     = RO(i).data';
        runoffsnowdata(:,f(idx)) = ROSNOW(i).data';
        snowdata(:,f(idx))       = SNOW(i).data';
        soildata(:,f(idx))       = SOIL(i).data';

        SSSNOW(f(idx)) = RSSSNOW(i).data';
        SSRAIN(f(idx)) = RSSRAIN(i).data';
    end

    % Fill remainder
    aetdata(:,f(last4))        = aaet';
    defdata(:,f(last4))        = ddef';
    runoffdata(:,f(last4))     = rro';
    runoffsnowdata(:,f(last4)) = rros';
    snowdata(:,f(last4))       = snoww';
    soildata(:,f(last4))       = soill';

    SSSNOW(f(last4)) = sr2';
    SSRAIN(f(last4)) = sr1';

    %% -----------------------------------------------------
    % Update state variables for next year
    %% -----------------------------------------------------
    soillast = soildata(12,:);
    snowlast = snowdata(12,:);

    %% -----------------------------------------------------
    % Reformat + round outputs
    %% -----------------------------------------------------
    aetdata        = round(shiftdim(aetdata,1),1);
    defdata        = round(shiftdim(defdata,1),1);
    runoffdata     = round(shiftdim(runoffdata,1),1);
    runoffsnowdata = round(shiftdim(runoffsnowdata,1),1);
    snowdata       = round(shiftdim(snowdata,1),1);
    soildata       = round(shiftdim(soildata,1),1);

    SSSNOW = round(SSSNOW,1);
    SSRAIN = round(SSRAIN,1);

    %% -----------------------------------------------------
    % Save outputs
    %% -----------------------------------------------------
    if strcmp(mode,'obs');
        save([path_to_int_data,'wbupdate_',num2str(year)], ...
            '-v7.3','runoffdata','runoffsnowdata','aetdata','defdata', ...
            'soildata','snowdata','SSSNOW','SSRAIN');
    elseif strcmp(mode,'future');
        save([path_to_int_data,'wbupdate',num2str(delta),'C_',num2str(year)], ...
            '-v7.3','runoffdata','runoffsnowdata','aetdata','defdata', ...
            'soildata','snowdata','SSSNOW','SSRAIN');
    elseif strcmp(mode,'cf');
        save([path_to_int_data,'wbupdate_cf_',num2str(year)], ...
            '-v7.3','runoffdata','runoffsnowdata','aetdata','defdata', ...
            'soildata','snowdata','SSSNOW','SSRAIN');
    end

    clear *data

end
fprintf('Water balance processing complete.\n');

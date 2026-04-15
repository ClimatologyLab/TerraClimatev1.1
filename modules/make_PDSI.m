function runPDSI(i)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% runPDSI.m
%
% Computes the Palmer Drought Severity Index (PDSI) for a
% horizontal subset of TerraClimate data.
%
% This function is used for generating PDSI from:
%   - Observed historical data
%
% MATLAB version:
%   Tested on MATLAB R2018b and later
%   - Uses matfile, shiftdim, and save
%
% Inputs:
%   i - Horizontal block index (used to subset the grid, e.g., 1,2,...)
%
% Outputs:
%   Saves PDSI results to a MAT file in the current directory:
%     PDSI_<i>.mat
%
% Required Files:
%   - pet_<year>.mat  (potential evapotranspiration)
%   - ppt_<year>.mat  (precipitation)
%   - worldclimsoil2.mat  (representative soil data)
%
% Example usage:
%   runPDSI(1);   % compute PDSI for the first horizontal block
%   runPDSI(2);   % compute PDSI for the second horizontal block
%
% Date: 2026-04-07
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directory containing TerraClimate .MAT files
dir = '/data/obs/obs/gridded/terraclim/MAT/';

% Loop through each year (1949 + yr)
for yr = 1:76
    % Load PET data for the current year
    m = matfile([dir,'pet_', num2str(1949 + yr)]);
    % Extract a horizontal subset of 240 rows corresponding to index i
    pet(:,:,:,yr) = m.petdata(1 + (i - 1) * 240 : i * 240, :, :);

    % Load precipitation data for the current year
    m = matfile([dir,'ppt_', num2str(1949 + yr)]);
    % Extract the same horizontal subset and add 1 to avoid zero precipitation
    ppt(:,:,:,yr) = m.pptdata(1 + (i - 1) * 240 : i * 240, :, :) + 1;
end

% Shift dimensions to match expected input for PDSI calculation
pet = shiftdim(pet, 2);
ppt = shiftdim(ppt, 2);

% Filter out missing or negative precipitation values
f = find(ppt(5,5,:) >= 0);
ppt = ppt(:,:,f); ppt = shiftdim(ppt,2);
pet = pet(:,:,f); pet = shiftdim(pet,2);

% Load representative soil data
m=matfile([path_to_input_data,'worldclimsoil2']);
soilt = m.soilt ; % soil water holding capacity grid

% Subset soil data for the current horizontal block
soilt = soilt(1 + (i - 1) * 240 : i * 240, :);
% Apply the same temporal filter as for PET and PPT
soilt = soilt(f);

% Change directory to where PDSI results will be saved
cd /data/backups/home_pluvial_abatz/DROUGHT/

% Compute PDSI
% Inputs: PET, PPT, scaling factor (25.4 mm/inch), soil data, months 1:51
[PDSI] = calcPDSI(pet, ppt, 25.4 * ones(size(ppt,1),1), soilt, 1:51);

% Save results with index i
save(['PDSI_', num2str(i)], '-v7.3', 'PDSI', 'f');

% Clear variables to free memory
clear PDSI f pet ppt
end

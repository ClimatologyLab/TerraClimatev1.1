#!/usr/bin/env bash

set -e  # stop on error

BASE_URL="https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT"

echo "Creating directory structure..."
mkdir -p data/coarse_gcm
mkdir -p 2_RUN_TERRACLIMATE/INPUTDATA

echo "Downloading coarse resolution GCM NetCDF files..."
cd data/coarse_gcm

wget -nc ${BASE_URL}/counterfactual_pr.nc
wget -nc ${BASE_URL}/counterfactual_srad.nc
wget -nc ${BASE_URL}/counterfactual_tdmean.nc
wget -nc ${BASE_URL}/counterfactual_tmax.nc
wget -nc ${BASE_URL}/counterfactual_tmin.nc
wget -nc ${BASE_URL}/counterfactual_vap.nc
wget -nc ${BASE_URL}/counterfactual_ws.nc

cd ../../

echo "Downloading scale factor NetCDF files..."
cd 2_RUN_TERRACLIMATE/INPUTDATA

wget -nc ${BASE_URL}/scalefactor_was.nc
wget -nc ${BASE_URL}/scalefactor_pr.nc
wget -nc ${BASE_URL}/scalefactor_huss.nc
wget -nc ${BASE_URL}/scalefactor_rsds.nc
wget -nc ${BASE_URL}/scalefactor_tasmax.nc
wget -nc ${BASE_URL}/scalefactor_tasmin.nc

echo "Downloading MATLAB support files..."

wget -nc ${BASE_URL}/annual_co2.mat
wget -nc ${BASE_URL}/global_smooth2.mat
wget -nc ${BASE_URL}/scalefactorCMIP6.mat

cd ../../

echo "All downloads complete."

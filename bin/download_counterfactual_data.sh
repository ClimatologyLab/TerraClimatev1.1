#!/usr/bin/env bash

BASE_URL="https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT"

echo "Downloading counterfactual NetCDF files..."
cd data/inputs

wget -nc ${BASE_URL}/counterfactual_pr.nc
wget -nc ${BASE_URL}/counterfactual_srad.nc
wget -nc ${BASE_URL}/counterfactual_tdmean.nc
wget -nc ${BASE_URL}/counterfactual_tmax.nc
wget -nc ${BASE_URL}/counterfactual_tmin.nc
wget -nc ${BASE_URL}/counterfactual_vap.nc
wget -nc ${BASE_URL}/counterfactual_ws.nc

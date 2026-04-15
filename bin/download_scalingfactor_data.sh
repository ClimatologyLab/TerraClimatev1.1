#!/usr/bin/env bash

BASE_URL="https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT"

# -------------------------------
# Download scale factor NetCDFs
# -------------------------------
echo "Downloading scale factor NetCDF files..."
cd data/inputs

wget -nc ${BASE_URL}/scalefactor_was.nc
wget -nc ${BASE_URL}/scalefactor_pr.nc
wget -nc ${BASE_URL}/scalefactor_huss.nc
wget -nc ${BASE_URL}/scalefactor_rsds.nc
wget -nc ${BASE_URL}/scalefactor_tasmax.nc
wget -nc ${BASE_URL}/scalefactor_tasmin.nc

echo "All downloads complete."

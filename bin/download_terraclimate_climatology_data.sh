#!/usr/bin/env bash

BASE_CLIM="http://thredds.northwestknowledge.net:8080/thredds/fileServer/TERRACLIMATE_ALL/climatology"

echo "Creating directory for TerraClimate data..."

# -------------------------------
# Climatology files (1991-2020)
# -------------------------------
echo "Downloading TerraClimate climatology files..."
wget -nc ${BASE_CLIM}/TerraClimate_19912020_tmax.nc
wget -nc ${BASE_CLIM}/TerraClimate_19912020_tmin.nc
wget -nc ${BASE_CLIM}/TerraClimate_19912020_ws.nc
wget -nc ${BASE_CLIM}/TerraClimate_19912020_srad.nc
wget -nc ${BASE_CLIM}/TerraClimate_19912020_ppt.nc
wget -nc ${BASE_CLIM}/TerraClimate_19912020_vap.nc

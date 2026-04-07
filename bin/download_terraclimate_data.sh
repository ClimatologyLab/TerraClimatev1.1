#!/usr/bin/env bash

BASE_DATA="http://thredds.northwestknowledge.net:8080/thredds/fileServer/TERRACLIMATE_ALL/data"

# -------------------------------
# Example yearly data
# -------------------------------
CURRENT_YEAR=$(date +%Y)
LAST_YEAR=$((CURRENT_YEAR - 1))
VARS=(tmax tmin ws srad ppt vap)

cd data/final
echo "Downloading TerraClimate yearly data from 1950 to $LAST_YEAR..."
for year in $(seq 1950 $LAST_YEAR); do
    for var in "${VARS[@]}"; do
        FILE="TerraClimate_${var}_${year}.nc"
        URL="${BASE_DATA}/TerraClimate_${var}_${year}.nc"
        echo "Downloading $FILE..."
        wget -nc $URL
    done
done

echo "TerraClimate downloads complete."

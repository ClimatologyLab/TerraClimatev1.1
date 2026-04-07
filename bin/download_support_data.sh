#!/usr/bin/env bash

BASE_URL="https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT"

echo "Downloading MATLAB support files...

cd data/inputs
wget -nc ${BASE_URL}/annual_co2.mat
wget -nc ${BASE_URL}/global_smooth2.mat
wget -nc ${BASE_URL}/scalefactorCMIP6.mat
wget -nc ${BASE_URL}/latlonel.mat

echo "All downloads complete."

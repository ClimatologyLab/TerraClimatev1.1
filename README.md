# TerraClimate v1.1 Code Repository

## Repository Structure and Processing Workflow

This repository contains the code and supporting resources used to generate the TerraClimate v1.1 dataset, including observational fields and future scenario products. The workflow is organized into three primary stages: (1) data generation, and (2) NetCDF export and dissemination.

---

## Overview of Workflow

1. **Core data generation (`create_terra/`)**
   Scripts and data used to construct TerraClimate fields, including water balance modeling, potential evapotranspiration (PET), and Palmer Drought Severity Index (PDSI) calculations for both historical and future scenarios.

2. **NetCDF export (`MAKE_NETCDFS/`)**
   Utilities for formatting and exporting outputs into NetCDF files tailored for distribution platforms such as THREDDS and Google Earth Engine.

---

## Directory Layout

```text
├── create_terra/                     # Core TerraClimate data generation workflows
│   ├── annual_co2.mat               # Annual CO₂ concentration data
│   ├── download22.py                # Script to download input datasets
│   ├── extractPDSI.m                # Extract Palmer Drought Severity Index (PDSI)
│   ├── gatherPDSI2.m                # Assemble historical PDSI data
│   ├── gatherPDSI2_future.m         # Assemble future scenario PDSI data
│   ├── global_smooth2.mat           # Global smoothing parameters
│   ├── make_terraclimate_obs.m      # Generate observational TerraClimate fields
│   ├── make_terraclimate_future.m   # Generate future scenario datasets
│   ├── make_terraclimate_counterfactual.m # Counterfactual climate generation
│   ├── monthlyPET_co2.m             # PET calculation including CO₂ effects
│   ├── runPDSI.m                    # Run PDSI model (historical)
│   ├── runPDSI_future.m             # Run PDSI model (future scenarios)
│   ├── run_pet_obs.m                # PET for observational data
│   ├── run_pet_counterfactual_future.m    # PET for counterfactual/future runs
│   ├── run_vpd_pet_counterfactual_future.m # VPD + PET workflows
│   ├── run_wb_terra_counterfactual_future.m # Water balance modeling
│   ├── runsnow.m                    # Snow model routines
│   ├── scalefactorCMIP6.mat         # CMIP6 scaling factors
│   └── readme.txt                   # Module-specific notes
│
├── MAKE_NETCDFS/                    # Export processed data to NetCDF format
│   ├── MAKE_NETCDFS_CLIMOS/         # NetCDF generation for climatologies (THREDDS)
│   ├── MAKE_NETCDFS_GEE/            # NetCDF outputs formatted for Google Earth Engine
│   ├── MAKE_NETCDFS_UIDAHO/         # NetCDF generation for observations (1950–present)
│   └── MAKE_NETCDFS_UIDAHO_+2C+4C/  # NetCDF for warming scenarios (+2°C, +4°C, counterfactual)
```

---

## Processing Details

### 1. TerraClimate Field Generation

The `create_terra/` module contains the primary computational workflows used to generate TerraClimate fields. These include:

* Water balance modeling integrating precipitation, temperature, and soil parameters
* Potential evapotranspiration (PET) calculations incorporating CO₂ effects
* Drought metrics, including the Palmer Drought Severity Index (PDSI)
* Scenario generation, including historical, future (CMIP6-based), and counterfactual simulations

Intermediate datasets (e.g., CO₂ time series, smoothing parameters, scaling factors) are stored as `.mat` files and used across workflows.

Additional data files to support this code can be downloaded here: 
* NetCDF files of coarse resolution GCM data:
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/counterfactual_pr.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/counterfactual_srad.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/counterfactual_tdmean.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/counterfactual_tmax.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/counterfactual_tmin.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/counterfactual_vap.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/counterfactual_ws.nc
* NetCDF files of scale factors which should go in the folder create_terra/INPUTDATA
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/scalefactor_was.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/scalefactor_pr.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/scalefactor_huss.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/scalefactor_rsds.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/scalefactor_tasmax.nc
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/scalefactor_tasmin.nc
* MATLAB files which should go in the folder create_terra/INPUTDATA
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/annual_co2.mat
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/global_smooth2.mat
  * wget https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/CODE_SUPPORT/scalefactorCMIP6.mat

---

### 2. NetCDF Formatting and Distribution

The `MAKE_NETCDFS/` module prepares final outputs for dissemination. Separate submodules support:

* THREDDS-compatible outputs for data access services
* Google Earth Engine ingestion formats
* University of Idaho distributions, including:

  * Observational datasets (1950–present)
  * Scenario datasets (+2 °C, +4 °C, and counterfactual conditions) (1950-present))

---

### 3. Data Accessibility

We have included code samples in R, Python and MATLAB to aid in accessibility of the TerraClimate data files: 

## Download subsets and point data using THREDDS web services

### Using OPeNDAP
- **Rectangular subsets**
  - MATLAB
  - Python
  - R
  - R (alternative version)

- **Point data**
  - MATLAB
  - Python
  - R

### Using NCSS
- **Batch scripts**
  - Subsets
  - Points

## Notes

* MATLAB (`.m`) scripts form the core of the processing pipeline.
* Supporting Python utilities are included where appropriate (e.g., data acquisition).
* Module-specific documentation is provided within each subdirectory (`readme.txt`).
* This repository is intended to support transparency and reproducibility of the TerraClimate v1.1 dataset generation workflow.

---

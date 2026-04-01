# TerraClimate v1.1 Code Repository

## Repository Structure and Processing Workflow

This repository contains the code and supporting resources used to generate the TerraClimate v1.1 dataset, including observational fields, climatologies, and future scenario products. The workflow is organized into three primary stages: (1) data generation, (2) climatology construction, and (3) NetCDF export and dissemination.

---

## Overview of Workflow

1. **Core data generation (`create_terra/`)**
   Scripts and data used to construct TerraClimate fields, including water balance modeling, potential evapotranspiration (PET), and Palmer Drought Severity Index (PDSI) calculations for both historical and future scenarios.

2. **Climatology generation (`MAKE_CLIMO/`)**
   Tools for producing baseline climatological summaries over standard periods (e.g., 1981–2010, 1991–2020).

3. **NetCDF export (`MAKE_NETCDFS/`)**
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
├── MAKE_CLIMO/                      # Climatology generation (baseline periods)
│   ├── create_climo.m               # Build climatological summaries
│   ├── climo_maps.m                 # Generate climatology maps
│   ├── runclimo_19812010.m          # Climatology for 1981–2010 baseline
│   ├── runclimo_19912020.m          # Climatology for 1991–2020 baseline
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

---

### 2. Climatology Construction

The `MAKE_CLIMO/` module generates climatological summaries over standard baseline periods. These climatologies are used for:

* Anomaly calculations
* Visualization products
* Comparative analyses across time periods

Two standard climatological baselines are provided:

* **1981–2010**
* **1991–2020**

---

### 3. NetCDF Formatting and Distribution

The `MAKE_NETCDFS/` module prepares final outputs for dissemination. Separate submodules support:

* THREDDS-compatible outputs for data access services
* Google Earth Engine ingestion formats
* University of Idaho distributions, including:

  * Observational datasets (1950–present)
  * Scenario datasets (+2 °C, +4 °C, and counterfactual conditions) (1950-present))

---

## Notes

* MATLAB (`.m`) scripts form the core of the processing pipeline.
* Supporting Python utilities are included where appropriate (e.g., data acquisition).
* Module-specific documentation is provided within each subdirectory (`readme.txt`).
* This repository is intended to support transparency and reproducibility of the TerraClimate v1.1 dataset generation workflow.

---

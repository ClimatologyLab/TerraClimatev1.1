# TerraClimate v1.1 Code Repository

## Repository Structure and Processing Workflow

This repository contains the code and supporting resources used to generate the TerraClimate v1.1 dataset, including observational fields and future scenario (+2C,+4C, counterfactual) products. The workflow is organized into three primary stages: (1) download supporting files, (2) data generation, (3) NetCDF export. We have also added code support for downloading subsets of TerraClimate.

---

## Overview of Workflow and Support

1. **Core data generation (`create_terra/`)**
   Scripts and data used to construct TerraClimate fields, including water balance modeling, potential evapotranspiration (PET), and Palmer Drought Severity Index (PDSI) calculations for both historical and future scenarios.

2. **Input data retrieval (`create_terra/INPUTDATA`)**
   Input data files (MAT and NetCDF formats) can be downloaded to fill in the repository

3. **NetCDF export (`MAKE_NETCDFS/`)**
   Utilities for formatting and exporting outputs into NetCDF files tailored for distribution platforms such as THREDDS and Google Earth Engine.

4. **Data accessibility support (`/DATA_ACCESSIBILITY`)**
   Code in R, Python and MATLAB to help support the subset data extraction for points and rectangles

---

## Directory Layout

```text
├── create_terra/                          # Core TerraClimate data generation workflows
│   ├── INPUTDATA/                         # Static inputs and scaling factors
│   │   ├── annual_co2.mat                 # Annual CO₂ concentration data
│   │   ├── global_smooth2.mat             # Global smoothing parameters
│   │   ├── scalefactorCMIP6.mat           # CMIP6 scaling factors
│   │   ├── scalefactor_*.nc               # Variable-specific scaling NetCDFs
│   ├── STEP1_DOWNLOADS/                   # ERA5 data acquisition pipeline
│   │   ├── directions.md                  # Instructions for download workflow
│   │   ├── PYTHON_SCRIPTS/                # Generated download scripts
│   │   ├── PYTHON_TEMPLATES/              # Templates used to build scripts
│   │   ├── step1_generate_python_scripts.sh  # Generate download scripts
│   │   ├── step2_execute_python_scripts.sh   # Execute downloads
│   │   ├── step3_summarize_year_of_ERA5.m    # Summarize yearly data
│   │   ├── step4_compute_monthly_values_for_year.m # Monthly aggregation
│   │   └── summarizeERA5.m                # Supporting summarization routines
│   ├── OLD/                              # Legacy scripts
│   │   └── download22.py
│   ├── extractPDSI.m                     # Extract Palmer Drought Severity Index (PDSI)
│   ├── gatherPDSI2.m                     # Assemble historical PDSI data
│   ├── gatherPDSI2_future.m              # Assemble future scenario PDSI data
│   ├── make_terraclimate_obs.m           # Generate observational TerraClimate fields
│   ├── make_terraclimate_future.m        # Generate future scenario datasets
│   ├── make_terraclimate_counterfactual.m # Counterfactual climate generation
│   ├── monthlyPET_co2.m                  # PET calculation including CO₂ effects
│   ├── runPDSI.m                         # Run PDSI model (historical)
│   ├── runPDSI_future.m                  # Run PDSI model (future scenarios)
│   ├── run_pet_obs.m                     # PET for observational data
│   ├── run_pet_counterfactual_future.m   # PET for counterfactual/future runs
│   ├── run_vpd_pet_counterfactual_future.m # VPD + PET workflows
│   ├── run_wb_terra_counterfactual_future.m # Water balance modeling
│   ├── runsnow.m                         # Snow model routines
│   └── readme.txt                        # Module-specific notes
│
├── DATA_ACCESSIBILITY/                   # Scripts for accessing TerraClimate data
│   ├── POINT_SUBSETS/                    # Extract time series at point locations
│   │   ├── *.m / *.py / *.R / *.sh       # MATLAB, Python, R, and shell examples
│   ├── RECTANGLE_SUBSETS/               # Extract spatial subsets (bounding boxes)
│   │   ├── *.m / *.py / *.R / *.sh       # Multi-language implementations
│   └── terraclimate_opendap_python_modified.py # OPeNDAP example (Python)
│
├── MAKE_CLIMO/                           # Climatology generation workflows
│   ├── climo_maps.m                      # Visualization of climatologies
│   ├── create_climo.m                    # Core climatology computation
│   ├── runclimo_19812010.m               # 1981–2010 climatology
│   ├── runclimo_19912020.m               # 1991–2020 climatology
│   └── readme.txt                        # Notes on climatology generation
│
├── MAKE_NETCDFS/                         # Export processed data to NetCDF format
│   ├── MAKE_NETCDFS_CLIMOS/              # NetCDF generation for climatologies
│   ├── MAKE_NETCDFS_GEE/                 # Outputs formatted for Google Earth Engine
│   ├── MAKE_NETCDFS_UIDAHO/              # NetCDF generation for observations (1950–present)
│   └── MAKE_NETCDFS_UIDAHO_+2C+4C/       # NetCDF for warming scenarios (+2°C, +4°C)
│
└── README.md                             # Repository overview and documentation
```

---
## Processing Details

### 1. Additional Data Files for Code Repository

The `1_DOWNLOAD_SUPPORT_DATA` folder contains a bash script `download_support_data.sh` for downloading additional data to support this code. This data can be downloaded into the proper folders using:

```bash
chmod +x download_support_data.sh
./download_support_data.sh
```

The `download_support_data.sh` script downloads the following types of files:

* **Coarse-resolution GCM NetCDFs:** e.g., `counterfactual_pr.nc`, `counterfactual_srad.nc`, …
* **Scale factor NetCDFs** (to `create_terra/INPUTDATA`): e.g., `scalefactor_pr.nc`, `scalefactor_was.nc`, …
* **MATLAB support files** (to `create_terra/INPUTDATA`): e.g., `annual_co2.mat`, `global_smooth2.mat`, …


### 2. TerraClimate Field Generation

The `2_RUN_TERRACLIMATE/` folder contains the primary computational workflows used to generate TerraClimate fields. These include:

* Water balance modeling integrating precipitation, temperature, and soil parameters
* Potential evapotranspiration (PET) calculations incorporating CO₂ effects
* Drought metrics, including the Palmer Drought Severity Index (PDSI)
* Scenario generation, including historical, future (CMIP6-based), and counterfactual simulations

Intermediate datasets (e.g., CO₂ time series, smoothing parameters, scaling factors) are stored as `.mat` files and used across workflows.

---

### 2. Additional Data Files for Code Repository

Additional data files required to run this code can be downloaded using the provided bash script:

```bash
chmod +x download_support_data.sh
./download_support_data.sh
```

The `download_support_data.sh` script downloads the following types of files:

* **Coarse-resolution GCM NetCDFs:** e.g., `counterfactual_pr.nc`, `counterfactual_srad.nc`, …
* **Scale factor NetCDFs** (to `create_terra/INPUTDATA`): e.g., `scalefactor_pr.nc`, `scalefactor_was.nc`, …
* **MATLAB support files** (to `create_terra/INPUTDATA`): e.g., `annual_co2.mat`, `global_smooth2.mat`, …
---

### 4. Data Accessibility

To facilitate access to the TerraClimate dataset, we provide example code in **R**, **Python**, and **MATLAB**.

Users can download rectangular subsets and point-based data via THREDDS web services using either **OPeNDAP** or **NCSS**, as outlined below:

* **Using OPeNDAP**
  * Rectangular subsets
    * MATLAB
    * Python
    * R
    * R (alternative version)
  * Point data
    * MATLAB
    * Python
    * R

* **Using NCSS**
  * Batch scripts for:
    * Rectangular subsets
    * Point data


## Notes

* MATLAB (`.m`) scripts form the core of the processing pipeline.
* Supporting Python utilities are included where appropriate (e.g., data acquisition).
* Module-specific documentation is provided within each subdirectory (`readme.txt`).
* This repository is intended to support transparency and reproducibility of the TerraClimate v1.1 dataset generation workflow.

---

## License

All scripts and example datasets are licensed under **CC BY 4.0**.

See [LICENSE.md](LICENSE.md) for full license text.
---

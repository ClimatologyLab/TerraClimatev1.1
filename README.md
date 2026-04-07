# TerraClimate v1.1 Code Repository

## Repository Structure and Processing Workflow

This repository contains the code and supporting resources used to generate the TerraClimate v1.1 dataset, including observational fields and future scenario (+2C,+4C, counterfactual) products. The workflow is organized into primary stages: (1) download supporting files, and (2) running a MATLAB script to generate the TerraClimate files for specific variables and years. Additionally in this repository are scripts to aid in extracting subsets from the data hosted at the University of Idaho.

---

## Overview of Repository Directories


1. **Input data retrieval (`bin/*.sh`)**
   Input data files (MAT and NetCDF formats) for the directory data/inputs can be downloaded with the bash scripts located in /bin. These files are needed to support the run of the main script for generating TerraClimate files. 

2. **Code for raw data retrieval (`bin/*.sh`)**
   Code for retrieving the raw data files from ERA5 is supplied in the modules/era5_downloads directory. This python code connects to the Climate Data Store fore retrieval of 6-hourly ERA5 data. This data is used to fill in the monthly ERA5 (1950-Current year) MATLAB file data/inputs/monthly_era5summary.mat needed for the TerraClimate runs. 


2. **Core data generation (`scripts/run_terraclimate.m`)**
   A script to construct TerraClimate fields, including water balance modeling, potential evapotranspiration (PET), and Palmer Drought Severity Index (PDSI) calculations for both historical and scenarios (+2C, +4C, counterfactual). 


3. **Functions used (`modules/`)**
   Functions called in this script are in the modules/ directory. These functions aid in creating the different variables for TerraClimate.

3. **Data generated (`data/final`)**
   Data generated for the TerraClimate files are stored in the `data/final` directory:

   * `<variable_name>_<year>.mat` — observational data files
   * `<variable_name>_2C_<year>.mat` — +2 °C warming scenario
   * `<variable_name>_4C_<year>.mat` — +4 °C warming scenario
   * `<variable_name>_cf_<year>.mat` — counterfactual scenario


4. **Data accessibility support (`examples/`)**
   Code examples (written in R, Python and MATLAB) are provided to help support data extraction of the TerraClimate files hosted at the University of Idaho. These examples are written in R, Python and MATLAB with options for point and rectangle subsets extractions. These examples utilize the THREDDS web services at the University of Idaho. 

---

## Directory Layout

```text
.
├── bin
│   ├── download_counterfactual_data.sh
│   ├── download_scalingfactor_data.sh
│   ├── download_support_data.sh
│   ├── download_terraclimate_climatology_data.sh
│   └── download_terraclimate_data.sh
├── data
│   ├── final
│   ├── inputs
│   │   ├── annual_co2.mat
│   │   ├── counterfactual_pr.nc
│   │   ├── counterfactual_srad.nc
│   │   ├── counterfactual_tdmean.nc
│   │   ├── counterfactual_tmax.nc
│   │   ├── counterfactual_tmin.nc
│   │   ├── counterfactual_vap.nc
│   │   ├── counterfactual_ws.nc
│   │   ├── global_smooth2.mat
│   │   ├── lonlatel.mat
│   │   ├── NASAGISS.csv
│   │   ├── scalefactorCMIP6.mat
│   │   ├── scalefactor_huss.nc
│   │   ├── scalefactor_pr.nc
│   │   ├── scalefactor_rsds.nc
│   │   ├── scalefactor_tasmax.nc
│   │   ├── scalefactor_tasmin.nc
│   │   └── scalefactor_was.nc
│   │   └──  worldclimsoil2.mat
│   ├── intermediary
├── examples
│   ├── point_subsets
│   │   ├── terraclimate_extract_point_subsets.m
│   │   ├── terraclimate_extract_point_subsets.py
│   │   ├── terraclimate_extract_point_subsets.R
│   │   ├── terraclimate_extract_point_subsets.sh
│   │   └── terrraclimate_extract_point_subsets.m
│   ├── rectangle_subsets
│   │   ├── terraclimate_extract_rectangle_subsets.py
│   │   ├── terraclimate_extract_rectangle_subsets.sh
│   │   ├── terraclimate_extract_rectangle_subsets_v1.R
│   │   ├── terrraclimate_extract_rectangle_subsets.m
│   │   └── terrraclimate_extract_rectangle_subsets.py
│   └── terraclimate_opendap_python_modified.py
├── modules
│   ├── era5_downloads
│   │   ├── PYTHON_SCRIPTS
│   │   │   ├── pyy_dew_2025.py
│   │   │   ├── pyy_p_2025.py
│   │   │   ├── pyy_ssrd_2025.py
│   │   │   ├── pyy_t_2025.py
│   │   │   ├── pyy_u_2025.py
│   │   │   └── pyy_v_2025.py
│   │   ├── PYTHON_TEMPLATES
│   │   │   ├── template_dew.sh
│   │   │   ├── template_p.sh
│   │   │   ├── template_ssrd.sh
│   │   │   ├── template_t.sh
│   │   │   ├── template_u.sh
│   │   │   └── template_v.sh
│   │   ├── directions.md
│   │   ├── step1_generate_python_scripts.sh
│   │   ├── step2_execute_python_scripts.sh
│   │   ├── step3_summarize_year_of_ERA5.m
│   │   ├── step4_compute_monthly_values_for_year.m
│   │   └── summarizeERA5.m
│   ├── TRASH
│   │   └── make_pet_scenario.m
│   ├── hydro_tax_robase.m
│   ├── make_pet.m
│   ├── make_snow.m
│   ├── make_terraclimate_counterfactual.m
│   ├── make_terraclimate_future.m
│   ├── make_terraclimate_obs.m
│   ├── make_vpd.m
│   ├── make_wb.m
│   └── monthlyPET_co2.m
├── scripts
│   └── run_terraclimate.m
├── LICENSE.md
└── README.md
```

---
## Processing Details

### 1. Additional Data Files for Code Repository

The `bin/` folder contains bash scripts (`download_*.sh`) for downloading the data required to run the TerraClimate workflows.

- `download_support_data.sh` — MATLAB inputs and supporting datasets  
- `download_scalingfactor_data.sh` — CMIP6-derived scaling factors  
- `download_counterfactual_data.sh` — counterfactual climate forcing data  
- `download_terraclimate_data.sh` — TerraClimate observational data for running the scenarios (in lieu of generated .mat files)
- `download_terraclimate_climatology_data.sh` — climatological baseline data  

Example usage:

```bash
chmod +x download_support_data.sh
./download_support_data.sh
```

Input Data Files

The inputs/ folder contains datasets used across the TerraClimate workflows:

annual_co2.mat — Annual global CO₂ concentration time series for PET and drought modeling
counterfactual_*.nc — Counterfactual climate forcing data for various variables:
counterfactual_pr.nc — precipitation
counterfactual_srad.nc — incoming solar radiation
counterfactual_tdmean.nc — mean dew point temperature
counterfactual_tmax.nc — maximum temperature
counterfactual_tmin.nc — minimum temperature
counterfactual_vap.nc — vapor pressure
counterfactual_ws.nc — wind speed
global_smooth2.mat — Spatial smoothing coefficients for climate variables (used in bias correction or interpolation)
lonlatel.mat — Longitude and latitude grid information for all TerraClimate points
NASAGISS.csv — NASA GISS reference climate data (used for validation or comparison)
scalefactorCMIP6.mat - Consolidated CMIP6 scaling factors for multiple climate variables (precipitation, temperature, radiation, wind, humidity) stored in a single MATLAB file for convenience
scalefactor_pr.nc — precipitation scaling factors
scalefactor_tasmax.nc — maximum temperature scaling factors
scalefactor_tasmin.nc — minimum temperature scaling factors
scalefactor_rsds.nc — surface radiation scaling factors
scalefactor_was.nc — wind speed scaling factors
scalefactor_huss.nc — specific humidity scaling factors
worldclimsoil2.mat — Representative soil properties used for hydrologic modeling (e.g., field capacity, wilting point), derived from WorldClim and FAO data. https://hess.copernicus.org/articles/20/1459/2016/hess-20-1459-2016.pdf

These files provide the essential input data required to generate historical, future, and counterfactual TerraClimate fields, and are used by scripts in modules/ and examples/.

---
### 2. TerraClimate Script

The script `script/run_terraclimate.m` serves as the primary workflow driver. It:

* Loads input datasets (e.g., CO₂, climatology, scaling factors)
* Executes functions in `modules/` to compute PET, water balance, snow, and drought metrics
* Produces historical, future, and counterfactual TerraClimate fields
* Saves outputs as `.mat` files for downstream analysis

---
### 3. TerraClimate Functions

The `modules/` folder contains the primary functions used to generate TerraClimate fields. These include:

* `make_terraclimate_obs.m` – Generates historical (observational) TerraClimate fields
* `make_terraclimate_future.m` – Produces future climate projections (CMIP6-based scenarios)
* `make_terraclimate_counterfactual.m` – Constructs counterfactual climate scenarios

* `make_pet.m` – Computes potential evapotranspiration (PET)
* `monthlyPET_co2.m` – PET calculation with CO₂ sensitivity
* `make_vpd.m` – Calculates vapor pressure deficit (VPD)

* `make_wb.m` – Runs the core water balance model
* `make_snow.m` – Simulates snow accumulation and melt processes
* `hydro_tax_robase.m` – Hydrologic parameterization and soil water capacity setup

These functions support:
* Water balance modeling integrating precipitation, temperature, and soil parameters
* PET calculations incorporating CO₂ effects
* Drought metrics, including the Palmer Drought Severity Index (PDSI)
* Scenario generation (historical, future, and counterfactual)

Input datasets (e.g., CO₂ time series, smoothing parameters, scaling factors) are stored as `.mat` files in the `data/inputs/` directory and used across workflows. Intermediary datasets are stored as `.mat` files in the `data/intermediary/` directory.

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

To facilitate access to TerraClimate data, the `examples/` folder provides demonstration scripts in **MATLAB**, **Python**, and **R** for downloading subsets of the dataset.  

Two types of subsets are supported:

* **Point-based subsets** – extract time series for specific locations
  * Scripts: `terraclimate_extract_point_subsets.*` (MATLAB, Python, R)
* **Rectangular subsets** – extract gridded data for a defined region
  * Scripts: `terraclimate_extract_rectangle_subsets.*` (MATLAB, Python, R, with some alternate versions)

These examples demonstrate how to download data via:

* **OPeNDAP** – programmatic access to individual points or regions
* **NCSS** – batch downloads for points or rectangular subsets

Users can adapt these scripts to retrieve historical, future, or counterfactual TerraClimate fields efficiently.

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

TerraClimate v1.1 code repository

The repository is organized into modules corresponding to major stages of the TerraClimate v1.1 production workflow, including data generation, climatology construction, and NetCDF export.

The repository is structured to reflect the sequential workflow used to generate, summarize, and distribute TerraClimate v1.1 data products.

The following is the structure of the directory. However, *.mat and *.nc files are not included in this repository. 

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
│   ├── create_climo.m              # Build climatological summaries
│   ├── climo_maps.m                # Generate climatology maps
│   ├── runclimo_19812010.m         # Climatology for 1981–2010 baseline
│   ├── runclimo_19912020.m         # Climatology for 1991–2020 baseline
│   └── readme.txt                 # Module-specific notes
│
├── MAKE_NETCDFS/                   # Export processed data to NetCDF format
│   ├── MAKE_NETCDFS_CLIMOS/        # NetCDF generation for climatologies for University of Idaho THREDDS
│   ├── MAKE_NETCDFS_GEE/           # NetCDF outputs formatted for Google Earth Engine ingestion
│   ├── MAKE_NETCDFS_UIDAHO/        # NetCDF generation for observations (1950-CurrentYear)
│   └── MAKE_NETCDFS_UIDAHO_+2C+4C/ # NetCDF generation for warming scenarios (+2°C, +4°C, Counterfactual)


# ERA5 Data Download and Processing

This repository provides scripts and instructions to download and summarize ERA5 data (wind speed, solar radiation, precipitation, temperature, and humidity) for a single year using the [Climate Data Store (CDS) API](https://cds.climate.copernicus.eu/).  

---

## 1. Setup the CDS API Key

Before accessing the CDS data, you need to set up your API key.

1. If you do not have an account, register here: [CDS registration](https://cds.climate.copernicus.eu/how-to-api#)  
2. If you already have an account, log in: [CDS login](https://cds.climate.copernicus.eu/how-to-api#)  
3. Once logged in, copy the API key into the file `$HOME/.cdsapirc` on your Unix/Linux environment with the following format:

    url: https://cds.climate.copernicus.eu/api  
    key: <YOUR_PERSONAL_ACCESS_TOKEN>

---

## 2. Install the CDS API Client

The CDS API client is a Python library that supports Python 3. You can install it via `pip`:

    pip install "cdsapi>=0.7.7"

---

## 3. Access Data Using the CDS API Client

Once installed, you can use the CDS API client to request data from the CDS and other supported catalogues.  

> **Important:** You must agree to the Terms of Use for each dataset before downloading. This is done manually on the dataset's download page.  

### Example Python API Request

At the bottom of each dataset page, press **"Show API request code"** to see a Python snippet. A typical request looks like:

    import cdsapi

    client = cdsapi.Client()

    dataset = 'reanalysis-era5-pressure-levels'
    request = {
        'product_type': ['reanalysis'],
        'variable': ['geopotential'],
        'year': ['2024'],
        'month': ['03'],
        'day': ['01'],
        'time': ['13:00'],
        'pressure_level': ['1000'],
        'data_format': 'grib',
    }
    target = 'download.grib'

    client.retrieve(dataset, request, target)

---

## 4. Download Scripts

This directory contains scripts to automate data downloads using Python templates like the example above.  

1. Modify the year in the scripts.  
2. Run them in order:

    ./step1_generate_python_scripts.sh  
    ./step2_execute_python_scripts.sh

---

## 5. File Organization

After downloading, place the `.nc` files in the following directory:

    /data/obs/reanalysis/ecmwf/era5/SFC/

---

## 6. Summarize Data in MATLAB

Use MATLAB to create daily summaries:

    summarizeERA5(year)

This will generate a daily summarized `.mat` file and update the monthly `.mat` file required for subsequent processing scripts.

Structure of the yearly file 2025data.mat
m = 

  matlab.io.MatFile

  Properties:
              Properties.Source: '/data/obs/reanalysis/ecmwf/era5/SFC/2025data.mat'
            Properties.Writable: false                                             
    Properties.ProtectedLoading: false                                             
                            dew: [3-D single]                                      
                            eto: [3-D single]                                      
                           rmax: [3-D single]                                      
                           rmin: [3-D single]                                      
                           rsds: [3-D single]                                      
                           tmax: [3-D single]                                      
                           tmin: [3-D single]                                      
                             tp: [3-D single]                                      
                              u: [3-D single]                                      
                              v: [3-D single]                                      
                            was: [3-D single]     

Structure of the yearly file monthly_era5summary.mat
m = 

  matlab.io.MatFile

  Properties:
              Properties.Source: '/data/obs/reanalysis/ecmwf/era5/SFC/monthly_era5summary.mat'
            Properties.Writable: true                                                         
    Properties.ProtectedLoading: false                                                        
                            dew: [4-D    single]                                              
                            lat: [721x1  single]                                              
                            lon: [1440x1 single]                                              
                           rsds: [4-D    single]                                              
                           tmax: [4-D    single]                                              
                           tmin: [4-D    single]                                              
                             tp: [4-D    single]                                              
                            was: [4-D    single]                                              
                          years: [1x76   double]   
---

## References

- [CDS API Documentation](https://cds.climate.copernicus.eu/api-how-to)  
- [ERA5 Dataset Overview](https://cds.climate.copernicus.eu/cdsapp#!/dataset/reanalysis-era5-single-levels)


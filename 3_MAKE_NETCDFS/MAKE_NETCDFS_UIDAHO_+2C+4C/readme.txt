From KCH (khegewisch@ucmerced.edu, 2/21/2025)
What to do with the annual update of the TerraClimate files: 

============================================================
STEP 1: The terraclimate*.nc files are for Google Earth Engine to ingest. 

Transfer the terraclimate_{yearmonth}.nc files to our FTP directory scanned by GEE: 

We need to make sure that these files do not have the _Unsigned attribute for all the variables, as this is causing an error with GDAL on Simon's side. I suggest that we just delete that attribute by running this bash script: 

	cd /data/obs/obs/gridded/terraclim/NETCDF
	./remove_unsigned.sh

scp terraclimate_2024*.nc khegewisch@climate.nkn.uidaho.edu:/nethome/khegewisch/webpage/climate/ACSL/TERRACLIMATE

Log into that machine and rename the files: 

ssh khegewisch@climate.nkn.uidaho.edu
cd webpage/climate/ACSL/TERRACLIMATE
vi rename_files.sh 

%replace the old year with the new year... in VI
:%s/2023/2024/g

%run the bash script
./rename_files.sh

The files are now ready for Simon @ google.
Send an email to simonf@google.com (cc:earthengine-data@google.com )

Subject: TerraClimate 2024
Message:

Hi Simon, 

 John Abatzoglou made the 2024 TerraClimate files yesterday.

You can download them here:

https://climate.northwestknowledge.net/ACSL/TERRACLIMATE/

Thanks. 

Katherine

============================================================
STEP 2: The TerraClimate*.nc files go to THREDDS on RCDS. 

However, they need to exactly match the other files that are already there for previous years. 

Unfortunately, the netCDFs that John usually makes do not match the previous years in some ways. 
For example, need PDSI not pdsi and need ws instead of vs. 

So instead of transferring the netCDF files that John usually makes, run this code in MATLAB to generate netCDF files that will match all of the other TerraClimate files on RCDS:

%Note: do not run this code on the newer machines, santaana, zephyr, etc as there is some error about the HDF5 not matching. Instead, run it on graupel. 

/data/code/USER_CODE/KATHERINE/DATASETS/TERRACLIMATE/MAKE_NETCDFS_UIDAHO/make_all_netcdf.m

Before running this code in MATLAB, change the value of years=2023 to the current year, i.e. years=2024.
The code will create netCDF files in the same directory: 
/data/obs/obs/gridded/terraclim/NETCDF

Once these are made, transfer the TerraClimate_*{year}.nc files to RCDS:

scp TerraClimate*2024.nc khegewisch@climate-utils.nkn.uidaho.edu:/reacch-data/TERRACLIMATE/data

============================================================
STEP 3: The scripts on webpages that help to download TerraClimate. We need to update the year available for all of these. 

ssh khegewisch@climate.nkn.uidaho.edu
cd /nethome/khegewisch/webpage/climate/TERRACLIMATE

Edit TERRACLIMATE_directdownload.php  and add another option for the newest year, i.e. 
 <option value="2024">2024</option>

Edit TERRACLIMATE_download_wget.php  and add another option for the newest year, i.e.
<input type="checkbox" name="timee[]" value="2024" />2024<br />


For the Climate TOolbox, edit the Data Download tool: 
cd /nethome/khegewisch/webpage/climate/NWTOOLBOX/pages/formattedDownloads/CONFIGURATION

dataStore.js: 
var yearRange={
        'terraclimate':[1958,2024], //update to the newest end year

============================================================

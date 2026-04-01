This is only a readme for updating TerraClimate for a year.

For TerraClimate Annual Updates, the following steps are needed

1) Download hourly data from ERA5 for wind speed, solar radiation, precipitation, temperature, and humidity

python22.py is an example of what should be run

Put the resultant .nc files in

/data/obs/reanalysis/ecmwf/era5/SFC/

From here, execute script summarizeERA5(year);

This should create a daily summarized .mat and augment the monthly.mat file that we need to read from in the subsequent script







# example script for subsetting terraclimate using Python 2.7
# for Python 3 anaconda users, be aware of the bug: 
#https://www.unidata.ucar.edu/mailing_lists/archives/python-users/2017/msg00005.html

#============================
# Required packages 
#============================
from netCDF4 import Dataset  #another option is to use xarray
import numpy as np
from datetime import date
import matplotlib.pyplot as plt

#============================
# General Settings
#============================

# enter your bounding lat/lon for data extraction
latbounds = [41, 44]
lonbounds = [75, 80]

# enter your time start and time end
year_start = 1950
year_end = 2025
month_start=1
month_end=12

# enter opendap filename
pathname = 'http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_terraclimate_aet_1950_CurrentYear_GLOBE.nc'
filehandle = Dataset(pathname,'r',format="NETCDF4")

# enter variable name in the above opendap file
varname = 'aet'

#============================
# Data Subsetting 
#============================

# subset in space (lat/lon)
lathandle = filehandle.variables['lat']
lonhandle = filehandle.variables['lon']
lat=lathandle[:]
lon=lonhandle[:]

# find indices of target lat/lon/day
lat_min = latbounds[0]
lat_max = latbounds[1]
lon_min = lonbounds[0]
lon_max = lonbounds[1]
lat_index_min = (np.abs(lat-lat_min)).argmin()
lat_index_max = (np.abs(lat-lat_max)).argmin()
lon_index_min = (np.abs(lon-lon_min)).argmin()
lon_index_max = (np.abs(lon-lon_max)).argmin()

def check_latlon_bounds(lat,lon,lat_index,lon_index,lat_target,lon_target):  
    #check final indices are in right bounds
    if(lat[lat_index]>lat_target):   
        if(lat_index!=0):
            lat_index = lat_index - 1
    if(lat[lat_index]<lat_target):
        if(lat_index!=len(lat)):
            lat_index = lat_index +1
    if(lon[lon_index]>lon_target):
        if(lon_index!=0):
            lon_index = lon_index - 1
    if(lon[lon_index]<lon_target):
        if(lon_index!=len(lon)):
            lon_index = lon_index + 1

    return [lat_index, lon_index]

[lat_index_min,lon_index_min] = check_latlon_bounds(lat, lon, lat_index_min, lon_index_min, lat_min, lon_min)   
[lat_index_max,lon_index_max] = check_latlon_bounds(lat, lon, lat_index_max, lon_index_max, lon_max, lon_max)

if(lat_index_min>lat_index_max):
     lat_index_range = range(lat_index_max, lat_index_min+1)
else:
     lat_index_range = range(lat_index_min, lat_index_max+1)
if(lon_index_min>lon_index_max):
     lon_index_range = range(lon_index_max, lon_index_min+1)
else:
     lon_index_range = range(lon_index_min, lon_index_max+1)
     
lat=lat[lat_index_range]
lon=lon[lon_index_range]

#============================
# subset in time
timehandle=filehandle.variables['time']
time=timehandle[:]
time_min = (date(year_start,month_start,1)-date(1900,1,1)).days
time_max = (date(year_end,month_end,1)-date(1900,1,1)).days 
time_index_min = (np.abs(time-time_min)).argmin()
time_index_max = (np.abs(time-time_max)).argmin()
time_index_range = range(time_index_min, time_index_max+1)
time = timehandle[time_index_range]

#============================
# subset data
datahandle = filehandle.variables[varname]
data = datahandle[time_index_range,lat_index_range,lon_index_range]
 

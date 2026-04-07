# example script for extracting list of points locations from terraclimate using OPeNDAP in Python 2.7
# For python3 anaconda users, be aware of bug
# https://www.unidata.ucar.edu/mailing_lists/archives/python-users/2017/msg00005.html
#
# Also, an alternative to netCDF4 is xarray, where here's a start:
#     http://climate.nkn.uidaho.edu/TERRACLIMATE/pages/guidance/CODE/terraclimate_opendap_points_python3.py
# author: Katherine Hegewisch (khegewisch@uidaho.edu)
#============================
# Required packages 
#============================
from netCDF4 import Dataset
import numpy as np
from datetime import date

#============================
# General Settings
#============================

# enter your bounding lat/lon for data extraction
latList = [41, 44, 41, 43.4]
lonList = [-100, -105, -110, -108]
NUM_POINTS = len(latList);

# enter your time start and time end
year_start = 1950
year_end = 2025
month_start=1
month_end=12

# enter variable name in the above opendap file
varname = 'tmin'  #units = deg C

# enter opendap filename
pathname = 'http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_terraclimate_'+varname+'_1950_CurrentYear_GLOBE.nc'
filehandle = Dataset(pathname,'r',format="NETCDF4")

#determine what the units are in the file
datahandle = filehandle.variables[varname]
#datahandle.variables   #look for units: deg_C

#determine what the scale and offset are for the variable
#datahandle.variables   #look for units: scale_factor: 0.01, add_offset: 0.0
scale_factor = datahandle.scale_factor
add_offset = datahandle.add_offset


#============================
# Data Subsetting 
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


# subset in space (lat/lon)
lathandle = filehandle.variables['lat']
lonhandle = filehandle.variables['lon']
lat=lathandle[:]
lon=lonhandle[:]

myLat =[]
myLon =[]
myData =[]
for i in range(NUM_POINTS):
   # find indices of target lat/lon/day
   lat_index = (np.abs(lat-latList[i])).argmin()
   lon_index = (np.abs(lon-lonList[i])).argmin()

   #get grid centers extracted
   myLat.append(lat[lat_index])
   myLon.append(lon[lon_index])

   # subset data, applying the scale_factor and add_offset
   myData.append(add_offset + scale_factor *datahandle[time_index_range,lat_index,lon_index])

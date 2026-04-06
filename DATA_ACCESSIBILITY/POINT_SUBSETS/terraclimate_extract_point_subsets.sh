#!/bin/sh
#GOAL: download set of point location(s) data from TerraClimate
#Author: Katherine Hegewisch (khegewisch@uidaho.edu)
#==========================================
#        PARAMETERS
#==========================================
#point location pairs
#lat domain -90.0 to 90.0 (North is positive, South is negative)
LATS=("45.4" "46.5")
#lon domain: -180.0 to 180.0 (East is positive, West is negative)
LONS=("-115" "-110.4")

#variable choices: tmax,tmin,ws,vpd,vap,swe,srad,soil,q,ppt,pet,def,aet,PDSI
VARIABLES=("tmax" "tmin")

#time range choices - 1950-01 to 2025-01
TIME_START="1950-01-01T00%3A00%3A00Z"
TIME_END="2025-12-01T00%3A00%3A00Z"
#==========================================
#       DOWNLOAD REQUESTS
#==========================================
ncssPath="http://thredds.northwestknowledge.net:8080/thredds/ncss"

for i in "${!LATS[@]}"; do
        lat="${LATS[$i]}"
        lon="${LONS[$i]}"
        for variable in "${VARIABLES[@]}"
        do
                filename="agg_terraclimate_${variable}_1950_CurrentYear_GLOBE.nc"
                queryString="$ncssPath/${filename}?"
                queryString="$queryString&var=${variable}"
                queryString="$queryString&latitude=${lat}&longitude=${lon}&horizStride=1"
                queryString="$queryString&time_start=${TIME_START}&time_end=${TIME_END}&timeStride=1"
                queryString="$queryString&addLatLon=true&accept=csv"

                echo $queryString

                newfilename="terraclimate_${variable}_${lat}N_${lon}E.nc"
                wget -nc -c -nd "$queryString" -O "$newfilename"
        done
done

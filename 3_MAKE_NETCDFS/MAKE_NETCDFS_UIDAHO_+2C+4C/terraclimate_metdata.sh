#!/bin/sh
#updates metadata in TerraClimate netcdfs according to suggestions at
#http://www.unidata.ucar.edu/software/thredds/current/netcdf-java/formats/DataDiscoveryAttConvention.html

#get arguments from bash script
YEAR_TC=$1
VAR_TC=$2
methodName="TerraClimate"
#pathToNetcdfData='/data/obs/obs/gridded/terraclim/NETCDF'
pathToNetcdfData='/data/code/USER_CODE/KATHERINE/DATASETS/TERRACLIMATE/MAKE_NETCDFS_UIDAHO/';
#===================
date=`date`
YEAR=`date +%Y` 
MONTH=`date +%m` 
DAY=`date +%d`

TITLE="TerraClimate: monthly climate and climatic water balance for global land surfaces";
VERSION='v1.1';

SUMMARY="This archive contains a dataset of high-spatial resolution (1/24°, ~4-km) monthly climate and climatic water balance for global terrestrial surfaces from 1950-present. These data were created by using climatically aided interpolation, combining high-spatial resolution climatological normals from the WorldClim version 1.4 and version 2 datasets, with coarser resolution time varying (i.e. monthly) data from ERA5 reanalyses produce a monthly dataset of precipitation, maximum and minimum temperature, wind speed, vapor pressure, and solar radiation. TerraClimate additionally produces monthly surface water balance datasets using a water balance model that incorporates reference evapotranspiration, precipitation, temperature, and interpolated plant extractable soil water capacity. Complementary datasets are also produced for 1950-2025 for counterfactual climate scenarios that remove the first-order influence of climate change, as well as a +2C and +4C scenario that apply a pseudo climate change experiment to observational data. These datasets preserve the observed variability during 1950-2025 but adjust individual climate variables monthly using ensemble median changes derived from CMIP6.';

KEYWORDS="WORLDCLIM,global,monthly, temperature,precipitation,wind,radiation,vapor pressure,evapotranspiration,water balance,soil water capacity,snow water equivalent,runoff"

ID="Blank"
NAMINGAUTHORITY="edu.uidaho.nkn"
KEYWORDS_VOCABULARY="None"
CDM_DATA_TYPE="GRID"
HISTORY="Created by John Abatzoglou, University of California Merced"
CONVENTIONS='CF-1.6';

DATE_CREATED="${YEAR}-${MONTH}-${DAY}"

CREATOR_NAME="John Abatzoglou";
CREATOR_URL="https://www.climatologylab.org/terraclimate.html"
CREATOR_ROLE="Principal Investigator";
CREATOR_EMAIL="jabatzoglou@ucmerced.edu";
INSTITUTION="University of California Merced"
PROCESSING_LEVEL="Gridded Climate Projections";
ACKNOWLEDGMENT="Please cite the references included herein. We also acknowledge the WorldClim datasets (Fick and Hijmans, 2017; Hijmans et al., 2005) and the ERA5 (Hersbach et al., 2020) datasets.";
REFERENCES="Abatzoglou, J.T., S.Z. Dobrowski, S.A. Parks, and K.C. Hegewisch, 2017, High-resolution global dataset of monthly climate and climatic water balance from 1958-2015, submitted to Scientific Data.";
SOURCE="WorldClim v2.0 (2.5m), ERA5";
STANDARD_NAME_VOCABULARY="CF-1.0";
LICENSE='No restrictions';


CONTRIBUTOR_NAME="Katherine Hegewisch";
CONTRIBUTOR_ROLE="Project Scientist";
CONTRIBUTOR_EMAIL="khegewisch@ucmerced.edu";
PUBLISHERNAME="Northwest Knowledge Network"
PUBLISHEREMAIL="info@northwestknowledge.net"
PUBLISHERURL="http://www.northwestknowledge.net"

DATE_MODIFIED=$DATE_CREATED
DATE_ISSUED=$DATE_CREATED

GEOSPATIAL_LAT_UNITS="decimal degrees north";
GEOSPATIAL_LON_UNITS="decimal degrees east";
GEOSPATIAL_VERTICAL_UNITS="None";
GEOSPATIAL_VERTICAL_POSITIVE="Up";

PROJECT="Global Dataset of Monthly Climate and Climatic Water Balance (1950-2025)"

PUBLISHERNAME="Northwest Knowledge Network"
PUBLISHEREMAIL="info@northwestknowledge.net"
PUBLISHERURL="http://www.northwestknowledge.net"

TIME_COVERAGE_START="${YEAR_TC}-01-01T00:0"
TIME_COVERAGE_END="${YEAR_TC}-12-01T00:0"
TIME_COVERAGE_DURATION="P1Y"
TIME_COVERAGE_RESOLUTION="P1M"

	cd ${pathToNetcdfData}
	 for i in ${methodName}_${VAR_TC}_${YEAR_TC}.nc;do
                echo $i
		
		#=============
		#  HIGHLY RECOMMENDED 
		#=============
                ncatted -O -h -a title,global,c,c,"$TITLE" $i
                ncatted -O -h -a summary,global,c,c,"$SUMMARY" $i
                ncatted -O -h -a keywords,global,c,c,"$KEYWORDS" $i

		#=============
		#  RECOMMENDED 
		#=============
                ncatted -O -h -a id,global,c,c,"$ID" $i
                ncatted -O -h -a naming_authority,global,c,c,"$NAMINGAUTHORITY" $i
                ncatted -O -h -a keywords_vocabulary,global,c,c,"$KEYWORDS_VOCABULARY" $i
                ncatted -O -h -a cdm_data_type,global,c,c,"$CDM_DATA_TYPE" $i
                ncatted -O -h -a history,global,c,c,"$HISTORY" $i

                ncatted -O -h -a date_created,global,c,c,"$DATE_CREATED" $i
                ncatted -O -h -a creator_name,global,c,c,"$CREATOR_NAME" $i
                ncatted -O -h -a creator_url,global,c,c,"$CREATOR_URL" $i
                ncatted -O -h -a creator_role,global,c,c,"$CREATOR_ROLE" $i
                ncatted -O -h -a creator_email,global,c,c,"$CREATOR_EMAIL" $i
                ncatted -O -h -a institution,global,c,c,"$INSTITUTION" $i
            
		ncatted -O -h -a project,global,c,c,"$PROJECT" $i
                ncatted -O -h -a processing_level,global,c,c,"$PROCESSING_LEVEL" $i
                ncatted -O -h -a acknowledgment,global,c,c,"$ACKNOWLEDGMENT" $i

		#hard code these values directly here
		ncatted -O -h -a geospatial_lat_min,global,c,f,-89.979166666666643 $i
                ncatted -O -h -a geospatial_lat_max,global,c,f,89.979166666666671 $i
                ncatted -O -h -a geospatial_lon_min,global,c,f,-179.9791666666667 $i
                ncatted -O -h -a geospatial_lon_max,global,c,f,179.9791666666667 $i
		ncatted -O -h -a geospatial_vertical_min,global,c,f,0 $i
                ncatted -O -h -a geospatial_vertical_max,global,c,f,0 $i

  		ncatted -O -h -a time_coverage_start,global,c,c,"$TIME_COVERAGE_START" $i
                ncatted -O -h -a time_coverage_end,global,c,c,"$TIME_COVERAGE_END" $i
  		ncatted -O -h -a time_coverage_duration,global,c,c,"$TIME_COVERAGE_DURATION" $i
                ncatted -O -h -a time_coverage_resolution,global,c,c,"$TIME_COVERAGE_RESOLUTION" $i

                ncatted -O -h -a standard_nam_vocabulary,global,c,c,"$STANDARD_NAME_VOCABULARY" $i
                ncatted -O -h -a license,global,c,c,"$LICENSE" $i

		#=============
		#   SUGGESTED
		#=============
                ncatted -O -h -a contributor_name,global,c,c,"$CONTRIBUTOR_NAME" $i
                ncatted -O -h -a contributor_role,global,c,c,"$CONTRIBUTOR_ROLE" $i
                ncatted -O -h -a contributor_email,global,c,c,"$CONTRIBUTOR_EMAIL" $i

		ncatted -O -h -a publisher_name,global,c,c,"$PUBLISHERNAME" $i
                ncatted -O -h -a publisher_url,global,c,c,"$PUBLISHERURL" $i
                ncatted -O -h -a publisher_email,global,c,c,"$PUBLISHEREMAIL" $i

                ncatted -O -h -a date_modified,global,c,c,"$DATE_MODIFIED" $i
                ncatted -O -h -a date_issued,global,c,c,"$DATE_ISSUED" $i

                ncatted -O -h -a geospatial_lat_units,global,c,c,"$GEOSPATIAL_LAT_UNITS" $i
                ncatted -O -h -a geospatial_lat_resolution,global,c,f,-0.041666666666667 $i
                ncatted -O -h -a geospatial_lon_units,global,c,c,"$GEOSPATIAL_LON_UNITS" $i
                ncatted -O -h -a geospatial_lon_resolution,global,c,f,0.041666666666667 $i
                ncatted -O -h -a geospatial_vertical_units,global,c,c,"$GEOSPATIAL_VERTICAL_UNITS" $i
                ncatted -O -h -a geospatial_vertical_resolution,global,c,f,0 $i
                ncatted -O -h -a geospatial_vertical_positive,global,c,c,"$GEOSPATIAL_VERTICAL_POSITIVE" $i

		#=============
		#  EXTRA 
		#=============
		#ncatted -a axis,lon,c,c,"X" $i
		#ncatted -a axis,lat,c,c,"Y" $i
                ncatted -O -h -a references,global,c,c,"$REFERENCES" $i
                ncatted -O -h -a source,global,c,c,"$SOURCE" $i
                ncatted -O -h -a version,global,c,c,"$VERSION" $i
                ncatted -O -h -a Conventions,global,c,c,"$CONVENTIONS" $i
        done
	cd $pathToNetcdfData

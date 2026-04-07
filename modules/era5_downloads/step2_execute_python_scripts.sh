#!/bin/sh

#This bash script executes all requsts for data 

#this python request uses authentication from /home/katherine/.cdsapirc  (on lightning only)

VARIABLES=("t" "u" "v" "dew" "p" "ssrd")
YEAR_START=2025
YEAR_END=2025

for variable in "${VARIABLES[@]}"
do
        for((year=$YEAR_START; year<=$YEAR_END; year++))
        do
                newfile="PYTHON_SCRIPTS/pyy_${variable}_${year}.py"

                #don't include the & at the end of this line or all of the scripts will be executed at once
                #leaving this off means that they will be executed sequentially one-after-another when the
                #previous one finishes

                #do include the & at the end of this next line if you want all of the requests to be executed at once
		
                python3.11 ${newfile} &
                echo "download done for ${variable}-${year}"
        done
done

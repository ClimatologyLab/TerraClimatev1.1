#!/bin/sh

# This bash script generates the python scripts for all variables for a set of years
# using templates in the folder PYTHON_TEMPLATES/

#Be careful in executing this script. This removes files in the PYTHONFILES directory.

# Instruction for each new year: change the YEAR_START, YEAR_END to the year to run

VARIABLES=("t" "u" "v" "dew" "p" "ssrd")
YEAR_START=2025
YEAR_END=2025

for variable in "${VARIABLES[@]}"
do
	for((year=$YEAR_START; year<=$YEAR_END; year++))
	do
			newfile="PYTHON_SCRIPTS/pyy_${variable}_${year}.py"
			rm $newfile
			sh PYTHON_TEMPLATES/template_${variable}.sh $year >> ${newfile}
			echo $newfile   
	done
done

#!/bin/bash

RH_EXPR="RH2=100*(PSFC*Q2/0.622)/(611.2*exp(17.67*(T2-273.15)/((T2-273.15)+243.5)))"
RAINSUM_EXPR="RAINSUM=RAINNC+RAINC"
SCRIPTDIR=$PWD/scripts

CFG=`head -n 1 inputs/arguments.txt`
OLD_IFS=$IFS
IFS='-' read -ra DOMAIN <<< $CFG
IFS=$OLD_IFS





if [[ $DOMAIN == "france" ]]; then
	NUMDOMAIN=02
fi

if [[ $DOMAIN == "italy" ]]; then
	NUMDOMAIN=03
fi

function regrid_date() {
	RUNDATE=$1
	SRC_DIR=$2

	cd $SRC_DIR;
	echo REGRIDDING $RUNDATE;
	

	if [ `ls -1 auxhist23_d${NUMDOMAIN}_* 2>/dev/null | wc -l ` -gt 0 ]; then
		echo	    
	else
	    echo ERROR: no aux files found for date $RUNDATE
	    return
	fi

	rm *.nc || echo no previous regridded files found

	auxfiles=`ls -fd auxhist23_d${NUMDOMAIN}_*`
	
	for auxf in $auxfiles; do
		echo regridding $auxf
		cdo -f nc4c setreftime,2000-01-01,00:00:00 -setcalendar,standard -remapbil,$SCRIPTDIR/$DOMAIN-cdo-d${NUMDOMAIN}-grid.txt -selgrid,1 $auxf regrid-$auxf.nc
	done


	# Merge all files into one that contains all simulation hours
	cdo -v mergetime regrid* raw-${RUNDATE}.nc
	
	# Calculate RH variable
	cdo -L -setrtoc,100,1.e99,100 -setunit,"%" -expr,$RH_EXPR raw-${RUNDATE}.nc rh-${RUNDATE}.nc

	# Merge source file and RH file
	cdo -v -z zip_2 merge raw-${RUNDATE}.nc rh-${RUNDATE}.nc lexis-$DOMAIN-${RUNDATE}.nc

	mv lexis-$DOMAIN-${RUNDATE}.nc $SCRIPTDIR/..
}

set -e

dates=`tail -n +2 inputs/arguments.txt | cut -c 1-8`
root=$PWD

echo DOMAIN $DOMAIN 
echo DATES $dates


for d in $dates; do
	regrid_date $d $root/$d/wrf00
done

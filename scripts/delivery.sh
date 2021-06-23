#!/bin/bash

RH_EXPR="RH2=100*(PSFC*Q2/0.622)/(611.2*exp(17.67*(T2-273.15)/((T2-273.15)+243.5)))"
RAINSUM_EXPR="RAINSUM=RAINNC+RAINC"
SCRIPTDIR=$PWD/scripts

function regrid_date() {
	RUNDATE=$1
	SRC_DIR=$2

	cd $SRC_DIR;
	echo $SRC_DIR;
	

	if [ `ls -1 auxhist23_d03_* 2>/dev/null | wc -l ` -gt 0 ]; then
		echo	    
	else
	    echo ERROR: no aux files found for date $RUNDATE
	    return
	fi

	rm *.nc || echo no previous regridded files found

	auxfiles=`ls -fd auxhist23_d03_*`
	
	for auxf in $auxfiles; do
		echo regridding $auxf
		cdo -f nc4c setreftime,2000-01-01,00:00:00 -setcalendar,standard -remapbil,$SCRIPTDIR/cdo-d03-grid.txt -selgrid,1 $auxf regrid-$auxf.nc
	done


	# Merge all files into one that contains all simulation hours
	cdo -v mergetime regrid* raw-${RUNDATE}.nc
	
	# Calculate RH variable
	cdo -L -setrtoc,100,1.e99,100 -setunit,"%" -expr,$RH_EXPR raw-${RUNDATE}.nc rh-${RUNDATE}.nc

	# Merge source file and RH file
	cdo -v -z zip_2 merge raw-${RUNDATE}.nc rh-${RUNDATE}.nc lexis-italy-${RUNDATE}.nc

	mv lexis-italy-${RUNDATE}.nc $SCRIPTDIR/..
}

set -e

dates=`ls -fd 2*`
root=$PWD

for d in $dates; do
	regrid_date $d $root/$d/wrf00
done

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

function move_aux() {
	RUNDATE=$1
	SRC_DIR=$2

	cd $SRC_DIR;
	echo MOVE AUX FOR $RUNDATE;

	AUX_DIR=$SCRIPTDIR/../results/aux/$RUNDATE

	mkdir -p $AUX_DIR
	mv auxhist23_d${NUMDOMAIN}_* $AUX_DIR
}

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
		cdo setreftime,2000-01-01,00:00:00 -setcalendar,standard -remapbil,$SCRIPTDIR/$DOMAIN-cdo-d${NUMDOMAIN}-grid.txt -selgrid,1 $auxf regrid-$auxf.nc
	done


	# Merge all files into one that contains all simulation hours
	cdo -v mergetime regrid* raw-${RUNDATE}.nc
	
	# Calculate RH variable
	cdo -L -setrtoc,100,1.e99,100 -setunit,"%" -expr,$RH_EXPR raw-${RUNDATE}.nc rh-${RUNDATE}.nc

	# Merge source file and RH file
	cdo -v merge raw-${RUNDATE}.nc rh-${RUNDATE}.nc lexis-$DOMAIN-${RUNDATE}.nc

	DEWETRA_DIR=$SCRIPTDIR/../results/dewetra/
		
	mkdir -p $DEWETRA_DIR
	mv lexis-$DOMAIN-${RUNDATE}.nc $DEWETRA_DIR
}

set -e

echo DOMAIN $DOMAIN 

i=0
root=$PWD

while read d; do
	if [[ $i != 0 ]]; then
		export hours=`echo $d | cut -c 12-13`
  		export date=`echo $d | cut -c 1-8`
  		#echo "line n.$i: date=$date hours=$hours"
  		if [[ $hours == 48 ]]; then
 	  		regrid_date $date $root/$date/wrf00
			move_aux $date $root/$date/wrf00
		else
			move_aux $date $root/$date/wrf00
  		fi
  	fi
 	(( i=i+1 ))
done < inputs/arguments.txt

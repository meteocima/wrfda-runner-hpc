#!/bin/bash

SCRIPTDIR=$PWD/scripts
PRG=/mnt/proj2/dd-20-34/BUILD-NOCOMP
NCO=$PRG/nco/
DEPS=$PRG/deps/out;

RH_EXPR="RH2=100*(PSFC*Q2/0.622)/(611.2*exp(17.67*(T2-273.15)/((T2-273.15)+243.5)))"
RAINSUM_EXPR="RAINSUM=RAINNC+RAINC"

CFG=`head -n 1 inputs/arguments.txt`
IFS='-' read -ra DOMAIN <<< $CFG

export LD_LIBRARY_PATH=$NCO/lib:$DEPS/lib
export PATH=$PATH:$NCO/bin

module purge
ml GSL/2.7-GCC-10.3.0 
ml UDUNITS/2.2.28-GCCcore-10.3.0 
ml netCDF/4.8.0-gompi-2021a
ml iccifort/2020.1.217
ml impi/2019.9.304-iccifort-2020.1.217
ml CDO/2.1.1-gompi-2021a

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

	rm *.nc *.2 *.3 || echo no previous regridded files found

	auxfiles=`ls -fd auxhist23_d${NUMDOMAIN}_*`
	
	for auxf in $auxfiles; do
		echo regridding $auxf
		ncks -A -v XLONG_U,XLAT_U,XLONG_V,XLAT_V wrfout_d03_* $auxf
		ncks -O -x -v P_PL,U_PL,T_PL,Q_PL,V_PL,GHT_PL,S_PL,RH_PL,TD_PL,C1H,C2H,C1F,C2F,C3H,C4H,C3F,C4F $auxf $auxf.2
		cdo -remapbil,$SCRIPTDIR/$DOMAIN-cdo-d${NUMDOMAIN}-grid.txt -selgrid,1,2,3 $auxf.2 $auxf.3
		date=$(basename $auxf | cut -c 15-24)
		time=$(basename $auxf | cut -c 26-34)
   		echo Fixing time for $(basename $auxf) to $date $time 
		cdo -O settaxis,$date,$time $auxf.3 regrid-$auxf.nc
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
		regrid_date $date $root/$date/wrf00
		move_aux $date $root/$date/wrf00
  	fi
 	(( i=i+1 ))
done < inputs/arguments.txt

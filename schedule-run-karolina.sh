#!/bin/bash
#PBS -q qprod
#PBS -N lexisda
#PBS -l select=4:ncpus=128
#PBS -l walltime=4:30:00
#PBS -A DD-22-29

#ml iccifort/2020.1.217;
#ml impi/2019.7.217-iccifort-2020.1.217
ml iccifort/2020.1.217
# ml impi/2019.7.217-iccifort-2020.1.217
ml impi/2019.9.304-iccifort-2020.1.217


if [[ $PBS_O_WORKDIR != '' ]]; then 
  WORKDIR=$PBS_O_WORKDIR
else
  WORKDIR=$PWD
fi

cd $WORKDIR

echo STARTING IN $WORKDIR


export SAVED_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

export DEPS=$WORKDIR/PRG/deps/out;
export LD_LIBRARY_PATH=$SAVED_LD_LIBRARY_PATH:$DEPS/lib
export NETCDF=$DEPS

ulimit -s unlimited
./wrfda-runner -p DA . 

export DEPS_CDO=$WORKDIR/PRG/cdo;
export LD_LIBRARY_PATH=$SAVED_LD_LIBRARY_PATH:$DEPS_CDO/lib
export PATH=$PATH:$DEPS_CDO/bin
./scripts/delivery.sh

# TODO: improve cd $SLURM_SUBMIT_DIR to use script file directory.

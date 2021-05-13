#!/bin/bash
#PBS -q qprod
#PBS -N lexisda
#PBS -l select=11:ncpus=36
#PBS -l walltime=02:40:00
#PBS -A DD-19-14

ml iccifort/2020.1.217;
ml impi/2019.7.217-iccifort-2020.1.217

export DEPS=$PBS_O_WORKDIR/PRG/deps/out;
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPS/lib
export NETCDF=$DEPS

if [[ $PBS_O_WORKDIR != '' ]]; then 
  echo STARTING IN $PBS_O_WORKDIR
  cd $PBS_O_WORKDIR
fi

ulimit -s unlimited
./wrfda-runner -p DA .

# TODO: improve cd $SLURM_SUBMIT_DIR to use script file directory.

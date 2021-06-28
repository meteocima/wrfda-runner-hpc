#!/bin/bash
#SBATCH -J da
#SBATCH --get-user-env
#SBATCH --output=da.out
#SBATCH --error=da.err
#SBATCH --nodes=13
#SBATCH --ntasks-per-node=28
#SBATCH --mail-type=all
#SBATCH --mail-user=andrea.parodi@cimafoundation.org
#SBATCH --time=04:40:00
#SBATCH --propagate=ALL
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_std
#SBATCH --qos=cm2_std

if [[ $SLURM_SUBMIT_DIR != '' ]]; then 
  WORKDIR=$SLURM_SUBMIT_DIR
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

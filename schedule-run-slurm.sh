#!/bin/bash
#SBATCH -J da
#SBATCH --get-user-env
#SBATCH --output=da.out
#SBATCH --error=da.err
#SBATCH --nodes=13
#SBATCH --ntasks-per-node=28
#SBATCH --mail-type=all
#SBATCH --mail-user=andrea.parodi@cimafoundation.org
#SBATCH --time=02:40:00
#SBATCH --propagate=ALL
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_std
#SBATCH --qos=cm2_std

export DEPS=$SLURM_SUBMIT_DIR/PRG/deps/out;
export SAVED_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$SAVED_LD_LIBRARY_PATH:$DEPS/lib
export NETCDF=$DEPS

if [[ $SLURM_SUBMIT_DIR != '' ]]; then 
  echo STARTING IN $SLURM_SUBMIT_DIR
  cd $SLURM_SUBMIT_DIR
fi

ulimit -s unlimited
./wrfda-runner -p DA .

export DEPS_CDO=$SLURM_SUBMIT_DIR/PRG/cdo;
export LD_LIBRARY_PATH=$SAVED_LD_LIBRARY_PATH:$DEPS_CDO/lib
./scripts/delivery.sh


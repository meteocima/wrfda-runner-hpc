#!/bin/bash
#SBATCH -J da
#SBATCH --get-user-env
#SBATCH --output=da.out
#SBATCH --error=da.err
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=28
#SBATCH --mail-type=all
#SBATCH --mail-user=andrea.parodi@cimafoundation.org
#SBATCH --time=04:00:00
#SBATCH --propagate=ALL
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_std
#SBATCH --qos=cm2_std

export DEPS=$SLURM_SUBMIT_DIR/PRG/deps/out;
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPS/lib
export NETCDF=$DEPS

if [[ $SLURM_SUBMIT_DIR != '' ]]; then 
  echo STARTING IN $SLURM_SUBMIT_DIR
  cd $SLURM_SUBMIT_DIR
fi

ulimit -s unlimited
./wrfda-runner -p DA .

# TODO: improve cd $SLURM_SUBMIT_DIR to use script file directory.

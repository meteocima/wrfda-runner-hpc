#!/bin/bash
#SBATCH -J da
#SBATCH --get-user-env
#SBATCH --output=da.out
#SBATCH --error=da.err
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=28
#SBATCH --mail-type=all
#SBATCH --mail-user=andrea.parodi@cimafoundation.org
#SBATCH --time=01:00:00
#SBATCH --propagate=ALL
#SBATCH --clusters=cm2
#SBATCH --partition=cm2_std
#SBATCH --qos=cm2_std

export DEPS=~/BUILD-NOCOMP/deps/out;
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPS/lib
export NETCDF=$DEPS

cd $SLURM_SUBMIT_DIR

ulimit -s unlimited
./wrfda-runner -p DA -i GFS .

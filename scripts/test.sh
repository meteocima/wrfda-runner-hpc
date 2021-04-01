#!/bin/bash
#SBATCH -J compile
#SBATCH --get-user-env
#SBATCH --output=compile.out
#SBATCH --error=compile.err
#SBATCH --clusters=mpp3
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=28
#SBATCH --mail-type=all
#SBATCH --mail-user=andrea.parodi@cimafoundation.org
#SBATCH --time=03:00:00

ml intel/pe-xe-2018--binary
ml intelmpi/2018--binaryjobs

export BUILD_DIR=~/BUILD
export DEPS=$BUILD_DIR/deps/out;

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPS/lib
export PATH=$DEPS/bin:$PATH

export NETCDF=$DEPS
export HDF5=$DEPS


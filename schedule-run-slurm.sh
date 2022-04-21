#!/bin/bash
#SBATCH -J da
#SBATCH --get-user-env
#SBATCH --output=da.out
#SBATCH --error=da.err
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=48
#SBATCH --mail-type=all
#SBATCH --mail-user=andrea.parodi@cimafoundation.org
#SBATCH --time=03:00:00
#SBATCH --propagate=ALL
#SBATCH --partition=wres

ml gcc-8.3.1/WRF-KIT
ml aocl-3.0-6_gcc

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

echo $SLURM_JOB_NODELIST	
ulimit -s unlimited
./wrfda-runner -p DA .  

#export DEPS_CDO=$WORKDIR/PRG/cdo;
#export LD_LIBRARY_PATH=$SAVED_LD_LIBRARY_PATH:$DEPS_CDO/lib
#export PATH=$PATH:$DEPS_CDO/bin
#./scripts/delivery.sh

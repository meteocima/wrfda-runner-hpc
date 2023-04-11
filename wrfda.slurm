#!/bin/bash

#####################################################################################
# This job will run a data assimilation (DA) phase with the 'wrfda-runner' program. #
# - The job will request to be executed on 4 nodes.                                 #
# - The job will take no longer than 5 hours on the 'alveo' partition.              #
# - The job will be named 'wrfda', and it will create an output file named          #
#   'wrfda-${job-name}.out' plus an error file 'wrfda-${job-name}.err'.             #
#                                                                                   #
# Enter 'sbatch wrfda.slurm' to submit this job to SLURM.                           #
#                                                                                   #
#####################################################################################

#SBATCH --job-name="wrfda"

#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err

#SBATCH --partition=alveo
#SBATCH --nodes=4
#SBATCH --tasks-per-node=91 
###SBATCH --time=05:00:00

###SBATCH --get-user-env
#[FIXME] #SBATCH --mail-type=BEGIN,END,FAIL
#[FIXME] #SBATCH --mail-user=fab@zurich.ibm.com

export BUILD_DIR=/scratch/slurm/and-runner/BUILD-WRF
export DEPS=$BUILD_DIR/deps/out;
export PATH=$DEPS/bin:$PATH;
export LD_LIBRARY_PATH=$DEPS/lib:$LD_LIBRARY_PATH;

export NETCDF=$DEPS

ulimit -s unlimited
./wrfda-runner -p DA .
./scripts/delivery.sh

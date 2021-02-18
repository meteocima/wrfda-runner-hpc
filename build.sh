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

source /etc/profile.d/modules.sh
module load slurm_setup
module load zlib/1.2.8 

NPROC=28
export F77=ifort;
export FC=ifort;
export CC=icc;
export CXX=icpc;
export FCFLAGS=-m64
export FFLAGS=-m64
export I_MPI_F90=ifort

export BUILD_DIR=~/BUILD
export DEPS=$BUILD_DIR/deps/out;
export DEPS_SRC=$BUILD_DIR/deps/src;
export PRG_SRC=$BUILD_DIR;

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPS/lib
export PATH=$DEPS/bin:$PATH

export NETCDF=$DEPS
export HDF5=$DEPS

export CFLAGS="-O3 -fPIC -I$DEPS/include"
export CPPFLAGS=-I$DEPS/include
export LDFLAGS="-L$DEPS/lib"

export WRF_DIR=$PRG_SRC/WRF-cima-4.1.5/
export JASPERLIB=$DEPS/lib
export JASPERINC=$DEPS/include
export J="-j $NPROC"
set -e
echo $J

#rm -rf $DEPS/*

#echo ZLIB
#cd $DEPS_SRC/zlib-1.2.5
#./configure --prefix=$DEPS > configure.out 2>  configure.err > configure.out 2>  configure.err
#make clean   > clean.out 2>  clean.err
#make -j $NPROC > compile.out 2>  compile.err
#make install  > install.out 2>  install.err

<< CM

echo LIBPNG
cd $DEPS_SRC/libpng-1.2.50
./configure --prefix=$DEPS > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo JASPER
cd $DEPS_SRC/jasper-1.900.1
./configure --prefix=$DEPS > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo HDF5
cd $DEPS_SRC/hdf5-1_8_9
./configure --prefix=$DEPS --with-zlib=$ZLIB_BASE --enable-fortran > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo NETCDF-C
cd $DEPS_SRC/netcdf-4.2.1.1
./configure --prefix=$DEPS --enable-netcdf-4 > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo NETCDF-FORTRAN
cd $DEPS_SRC/netcdf-fortran-4.2
./configure --prefix=$DEPS  > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

CM

echo WRF
cd $PRG_SRC/WRF-cima-4.1.5
./clean -a > clean.out 2>  clean.err
echo 15 | ./configure > configure.out 2>  configure.err
./compile em_real > compile.out 2>  compile.err

echo WRF - CUSTOM REGISTRY
cd $PRG_SRC/WRF-cima-registry-4.1.5
./clean -a > clean.out 2>  clean.err
echo 15 | ./configure > configure.out 2>  configure.err
./compile em_real > compile.out 2>  compile.err

echo WPS
cd $PRG_SRC/WPS-cima-4.1
./clean -a > clean.out 2>  clean.err
echo 19 | ./configure > configure.out 2>  configure.err
./compile > compile.out 2>  compile.err

echo WRFDA
cd $PRG_SRC/WRFDA-cima-4.1.5
./clean -a > clean.out 2>  clean.err
echo 15 | ./configure wrfda > configure.out 2>  configure.err
./compile all_wrfvar > compile.out 2>  compile.err


#!/bin/bash

ml iccifort/2020.1.217
ml impi/2019.7.217-iccifort-2020.1.217

export F77=ifort;
export FC=ifort;
export CC=icc;
export CXX=icpc;
export FCFLAGS=-m64
export FFLAGS=-m64
export I_MPI_F90=ifort

export BUILD_DIR=~/BUILD
export DEPS=$BUILD_DIR/cdo/;
export DEPS_SRC=$BUILD_DIR/deps/src;
export PRG_SRC=$BUILD_DIR;

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DEPS/lib
export PATH=$DEPS/bin:$PATH

export NETCDF=$DEPS
export HDF5=$DEPS

export CFLAGS="-O3 -fPIC -I$DEPS/include"
export CPPFLAGS=-I$DEPS/include
export LDFLAGS="-L$DEPS/lib"


set -e

rm -rf $DEPS/*

echo ZLIB
 cd $DEPS_SRC/zlib-1.2.5
./configure --prefix=$DEPS > configure.out 2>  configure.err > configure.out 2>  configure.err
make clean   > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install  > install.out 2>  install.err

echo HDF5
cd $DEPS_SRC/hdf5-1_8_9
./configure --prefix=$DEPS --with-zlib=$DEPS > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo NETCDF-C
cd $DEPS_SRC/netcdf-4.2.1.1
./configure --prefix=$DEPS > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo CDO
#cd $DEPS_SRC/cdo-1.9.10
cd $DEPS_SRC/cdo-1.7.2
./configure --disable-openmp --with-netcdf=$DEPS --prefix=$DEPS > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make > compile.out 2>  compile.err
make install > install.out 2>  install.err

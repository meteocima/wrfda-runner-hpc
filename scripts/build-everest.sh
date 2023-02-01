#!/bin/bash

export J="-j 10"

export F77=ifort;
export FC=ifort;
export CC=icc;
export CXX=icpc;
#export FCFLAGS=-m64
#export FFLAGS=-m64
export I_MPI_F90=ifort

export BUILD_DIR=/scratch/slurm/and-runner/BUILD-WRF
export DEPS=$BUILD_DIR/deps/out;
export PATH=$DEPS/bin:$PATH;
export LD_LIBRARY_PATH=$DEPS/lib:$LD_LIBRARY_PATH;
export DEPS_SRC=$BUILD_DIR/deps/src;
export NETCDF=$DEPS

export CPPFLAGS=-I$DEPS/include
export LDFLAGS="-L$DEPS/lib"

WRFIO_NCD_NO_LARGE_FILE_SUPPORT=1

echo flex
cd $DEPS_SRC/flex-2.6.4
./configure --prefix=$DEPS > configure.out 2>&1
make distclean > /dev/null 2>&1
make $J > make.out  2>&1
make install > install.out  2>&1

echo opensm
cd $DEPS_SRC/opensm-3.3.24
./configure --prefix=$DEPS > configure.out 2>&1
make distclean > /dev/null 2>&1
make $J > make.out  2>&1
make install > install.out  2>&1

echo openmpi
cd $DEPS_SRC/openmpi-4.1.4
./configure --prefix=$DEPS > configure.out 2>&1
make distclean > /dev/null 2>&1
make $J > make.out  2>&1
make install > install.out  2>&1

echo NETCDF-C
cd $DEPS_SRC/netcdf-4.2.1.1
./configure --prefix=$DEPS --disable-netcdf-4 > configure.out 2>&1
make distclean > /dev/null 2>&1
make $J > make.out  2>&1
make install > install.out  2>&1

echo NETCDF-FORTRAN
cd $DEPS_SRC/netcdf-fortran-4.2
./configure --prefix=$DEPS > configure.out 2>&1
make distclean > /dev/null 2>&1
make $J > make.out  2>&1
make install > install.out  2>&1

echo WRF
cd $BUILD_DIR/WRF-cima-4.1.5
./clean -a > /dev/null 2>&1
git clean -f > /dev/null 2>&1
echo 15 | ./configure > configure.out 2>&1
./compile em_real > make.out  2>&1

echo WRF - CUSTOM REGISTRY
cd $BUILD_DIR/WRF-cima-registry-4.1.5
./clean -a > /dev/null 2>&1
git clean -f > /dev/null 2>&1
echo 15 | ./configure > configure.out 2>&1
./compile em_real > make.out  2>&1

echo WRFDA
cd $BUILD_DIR/WRFDA-cima-4.1.5
./clean -a > /dev/null 2>&1
git clean -f > /dev/null 2>&1
echo 15 | ./configure wrfda > configure.out 2>&1
./compile all_wrfvar > make.out  2>&1

echo CDO
cd $DEPS_SRC/cdo-1.7.2
./configure --prefix=$DEPS --with-netcdf=yes > configure.out 2>&1
make distclean > /dev/null 2>&1
make $J > make.out  2>&1
make install > install.out  2>&1

cd $BUILD_DIR
find . -name '*.exe' -type f



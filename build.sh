#!/bin/bash

# This script build all necessary software to produce a 
# complete WRF simulation with data assimilation.
#
# It will compile WRF, WRF with custom registry, WRFDA, WPS,
# and all required dependency.
#
# You can use the create.sh script to build the directory
# structure used by this script and to download all needed 
# sources.
#
# Compilation use intel compilers, without any further 
# architecture specific optimization, using distributed memory 
# paradigm (WRF configure option 15)
# 
# Software is configured to use netcdf classic format,
# in case you wish to use netcdf format 4 with compression
# you can switch the argument on NETCDF-C block from 
# --disable-netcdf-4 to --enable-netcdf-4. 
#
# But beware, we weren't able to successfully run a simulation
# when using the new format. In case you'll be able to use it
# by tweaking some options here, please contribute back with A PR.
#
# Also beware, the version of WRF sources downloaded by `create.sh`
# contains custom changes made by CIMA. In case you need to 
# use the vanilla version, go to every directory in the sources 
# and issue this command: 
#
# git clean -f && git checkout . &&  git checkout <the version you need>
#

# The script has been tested on following HPC servers. 

# lrz linux cluster
# needed modules already loaded by default
#NPROC=28

# galileo
NPROC=36
ml intel/pe-xe-2018--binary
ml intelmpi/2018--binary

# barbora
#NPROC=28
#ml iccifort/2020.1.217
#ml impi/2019.7.217-iccifort-2020.1.217

# salomon
#NPROC=28
#ml iccifort/2020.1.217
#ml impi/2019.7.217-iccifort-2020.1.217

# lrz cloud docker (or every other place where inel compilers are loaded on default directory)
#NPROC=4
#source /opt/intel/parallel_studio_xe_2020/compilers_and_libraries_2020/linux/pkg_bin/compilervars.sh intel64
#source /opt/intel/parallel_studio_xe_2020/compilers_and_libraries_2020/linux/mpi/intel64/bin/mpivars.sh

export J="-j $NPROC"

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

# in case you prefer to use zlib provided by
# your system, commant the zlib block below, 
# and set ZLIB_BASE to your system directory
# whewre zlib is found.
export ZLIB_BASE=$DEPS

echo ZLIB
cd $DEPS_SRC/zlib-1.2.7
./configure --prefix=$DEPS > configure.out 2>  configure.err > configure.out 2>  configure.err
make clean   > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install  > install.out 2>  install.err

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
cd $DEPS_SRC/hdf5-hdf5-1_8_9
./configure --prefix=$DEPS --with-zlib=$ZLIB_BASE --enable-fortran > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo NETCDF-C
cd $DEPS_SRC/netcdf-4.2.1.1
#./configure --prefix=$DEPS --enable-netcdf-4 > configure.out 2>  configure.err
./configure --prefix=$DEPS --disable-netcdf-4 > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

echo NETCDF-FORTRAN
cd $DEPS_SRC/netcdf-fortran-4.2
./configure --prefix=$DEPS  > configure.out 2>  configure.err
make clean  > clean.out 2>  clean.err
make -j $NPROC > compile.out 2>  compile.err
make install > install.out 2>  install.err

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



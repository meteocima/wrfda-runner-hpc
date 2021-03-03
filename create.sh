#!/bin/bash

echo downloading WRF-cima-4.1.5 
git clone -qb v4.1.5-cima --single-branch https://github.com/meteocima/WRF.git WRF-cima-4.1.5 
cp WRF-cima-4.1.5/Registry/Registry.EM_COMMON_original_wrf.4.1.5 WRF-cima-4.1.5/Registry/Registry.EM_COMMON
echo downloading WRFDA-cima-4.1.5 
git clone -qb v4.1.5-cima --single-branch https://github.com/meteocima/WRF.git WRFDA-cima-4.1.5 
echo downloading WRF-cima-registry-4.1.5
git clone -qb v4.1.5-cima --single-branch https://github.com/meteocima/WRF.git WRF-cima-registry-4.1.5 
echo downloading WPS-cima-4.1
git clone -qb v4.1-smoothpasses-cima --single-branch https://github.com/meteocima/WPS.git WPS-cima-4.1

mkdir -p deps/src
mkdir -p deps/out
cd deps/src
echo downloading netcdf-fortran-4.2
wget -q ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.2.tar.gz
echo downloading netcdf-4.2.1.1
wget -q ftp://ftp.unidata.ucar.edu/pub/netcdf/old/netcdf-4.2.1.1.tar.gz
echo downloading hdf5-1_8_9
wget -q https://github.com/HDFGroup/hdf5/archive/hdf5-1_8_9.tar.gz
echo downloading jasper-1.900.1
wget -q https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
echo downloading libpng-1.2.50
wget -q https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
echo downloading zlib-1.2.7
wget -q https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz

echo decompressig hdf5-1_8_9
tar xf hdf5-1_8_9.tar.gz
echo decompressig jasper-1.900.1
tar xf jasper-1.900.1.tar.gz
echo decompressig libpng-1.2.50
tar xf libpng-1.2.50.tar.gz
echo decompressig netcdf-4.2.1.1
tar xf netcdf-4.2.1.1.tar.gz
echo decompressig netcdf-fortran-4.2
tar xf netcdf-fortran-4.2.tar.gz
echo decompressig zlib-1.2.7
tar xf zlib-1.2.7.tar.gz

rm hdf5-1_8_9.tar.gz
rm jasper-1.900.1.tar.gz
rm libpng-1.2.50.tar.gz
rm netcdf-4.2.1.1.tar.gz
rm netcdf-fortran-4.2.tar.gz
rm zlib-1.2.7.tar.gz


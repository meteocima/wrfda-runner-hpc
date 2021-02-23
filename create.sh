#!/bin/bash

git clone -b v4.1.5-cima --single-branch https://github.com/meteocima/WRF.git WRF-cima-4.1.5 
cp WRF-cima-4.1.5/Registry/Registry.EM_COMMON_original_wrf.4.1.5 WRF-cima-4.1.5/Registry/Registry.EM_COMMON
git clone -b v4.1.5-cima --single-branch https://github.com/meteocima/WRF.git WRFDA-cima-4.1.5 
git clone -b v4.1.5-cima --single-branch https://github.com/meteocima/WRF.git WRF-cima-registry-4.1.5 
git clone -b v4.1-smoothpasses-cima --single-branch https://github.com/meteocima/WPS.git WPS-cima-4.1

mkdir -p deps/src
mkdir -p deps/out
cd deps/src
wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/mpich-3.0.4.tar.gz
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.2.tar.gz
wget ftp://ftp.unidata.ucar.edu/pub/netcdf/old/netcdf-4.2.1.1.tar.gz
wget https://github.com/HDFGroup/hdf5/archive/hdf5-1_8_9.tar.gz
wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz

tar xvf hdf5-1_8_9.tar.gz
tar xvf jasper-1.900.1.tar.gz
tar xvf libpng-1.2.50.tar.gz
tar xvf mpich-3.0.4.tar.gz
tar xvf netcdf-4.2.1.1.tar.gz
tar xvf netcdf-fortran-4.2.tar.gz
tar xvf zlib-1.2.7.tar.gz

rm hdf5-1_8_9.tar.gz
rm jasper-1.900.1.tar.gz
rm libpng-1.2.50.tar.gz
rm mpich-3.0.4.tar.gz
rm netcdf-4.2.1.1.tar.gz
rm netcdf-fortran-4.2.tar.gz
rm zlib-1.2.7.tar.gz


# > > > test 

wget https://www2.mmm.ucar.edu/wrf/src/data/real4jan00.tar.gz
tar xvf real4jan00.tar.gz
rm real4jan00.tar.gz

cp ~/BUILD/WRF-cima-4.1.5/test/em_real/namelist.input.jan00 namelist.input

ln -s $WRF_DIR/main/wrf.exe wrf.exe
ln -s $WRF_DIR/run/LANDUSE.TBL LANDUSE.TBL
ln -s $WRF_DIR/run/ozone_plev.formatted ozone_plev.formatted
ln -s $WRF_DIR/run/ozone_lat.formatted ozone_lat.formatted
ln -s $WRF_DIR/run/ozone.formatted ozone.formatted
ln -s $WRF_DIR/run/RRTMG_LW_DATA RRTMG_LW_DATA
ln -s $WRF_DIR/run/RRTMG_SW_DATA RRTMG_SW_DATA
ln -s $WRF_DIR/run/VEGPARM.TBL VEGPARM.TBL
ln -s $WRF_DIR/run/SOILPARM.TBL SOILPARM.TBL
ln -s $WRF_DIR/run/GENPARM.TBL GENPARM.TBL
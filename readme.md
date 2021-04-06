# wrfda-runner-hpc

This repository contains informations and scripts to run a WRFDA simulation on HPC infrastructure.

These simulation has following charactertics:

1) The simulation is guided either by IFS or GFS datasets. These datasets should already be 
    prepared by one or more WPS processes. You can use one of our dockers to do this, either [wps-da.gfs](https://github.com/meteocima/wps-da.gfs)
    or [wps-da.ifs](https://github.com/meteocima/wps-da.ifs).

2) The simulation assimilates radars and/or weather stations data in three
    different cycles, with the first one starting 6 hour before the start of 
    the requested forecast, the second 3 hour before and the same instant of the 
    start of the requested forecast 
3) The simulation consists of one or more nested domain, and assimilation
    of each of this domains happens in a separate process.

## HOWTO: prepare a directory for a WRFDA simulation on your HPC server.

To run a simulation on your HPC premises you need to create a directory containig
following subdirs and files:


### wrfda-runner 

This command takes care of running all the various
WRF processes needed to complete a simulation with radars and weather
stations assimilation data.

The command is written in Go and sources can be found here: 
https://github.com/meteocima/wrfda-runner

Prebuilt binaries should be downloaded from
https://github.com/meteocima/wrfda-runner/releases/latest

### covar-matrices 

A directory containing pre-built dataset of data needed
by the assimilation process. This data is common between all runs of a certain 
domain (in other words, for all runs that share the same geographical area, 
grid definition etc.)

Moreover, these datasets contains informations that varies according to season.
wrfda-runner takes care of selecting the appropriate file for season of simulation
you're running, and in order to do so, files must have following names:

```
covar-matrices
covar-matrices/summer
covar-matrices/summer/be_2.5km_d03
covar-matrices/summer/be_2.5km_d01
covar-matrices/summer/be_2.5km_d02
covar-matrices/fall
covar-matrices/fall/be_2.5km_d03
covar-matrices/fall/be_2.5km_d01
covar-matrices/fall/be_2.5km_d02
covar-matrices/winter
covar-matrices/winter/be_2.5km_d03
covar-matrices/winter/be_2.5km_d01
covar-matrices/winter/be_2.5km_d02
covar-matrices/spring
covar-matrices/spring/be_2.5km_d03
covar-matrices/spring/be_2.5km_d01
covar-matrices/spring/be_2.5km_d02
```

which is, you have to provide a file ending in _d0N for every N domain in your
configuration, and you have to provide a dataset for each season (or at least,
for the season of the simulation you want tot run).

### inputs 

This directory must contains initial and boundary conditions for the 
simulation, as produced by WPS process. There should be a boundary file
for each of the 3 cycle of assimilation of your outhermost domain, and an initial 
condition for every nested files. In case you want to run simulation for multiple dates, 
in order e.g. to feed warmup data to dowstream simulation chains, you have to provide inputs for 
each one of the needed dates.

Files have to be organized in following way, to run simulations
for two different dates on a setup with 2 domains:

```
inputs/20201125/wrfbdy_d01_da03
inputs/20201125/wrfbdy_d01_da01
inputs/20201125/wrfbdy_d01_da02
inputs/20201125/wrfinput_d01
inputs/20201125/wrfinput_d02
inputs/20201125/wrfinput_d03
inputs/20201126/wrfbdy_d01_da03
inputs/20201126/wrfbdy_d01_da01
inputs/20201126/wrfbdy_d01_da02
inputs/20201126/wrfinput_d01
inputs/20201126/wrfinput_d02
inputs/20201126/wrfinput_d03
```

### namelists 

this directory must contains namelists for all the various processes
of the simulation you want to run.

The directory must contains following files, named in the same exact way:

    - namelist.step.wrf   - namelist to run a WRF step for a middle cycle of assimilation
    - namelist.run.wrf    - namelist to run last WRF step that produce or requested hours of forecast
    - namelist.d0<N>.wrfda  - namelist to run a WRFDA assimilation cycle in domain N. You must have of this file for each domain, replacing <N> with domain number.
    - parame.in           - ???
    - wrf_var.txt.wrf_01  - wrf_var.txt files for 1 cycle of assimiltion
    - wrf_var.txt.wrf_02  - wrf_var.txt files for 2 cycle of assimiltion
    - wrf_var.txt.wrf_03  - wrf_var.txt files for 3 cycle of assimiltion

### observations

This directory contains weather stations and radars datasets you want to 
ingest during the assimilation phase.

Files must be in WRF assimilation ascii format, and must be named in the following way:

```
observations/ob.radar.2020112609
observations/ob.radar.2020112606
observations/ob.ascii.2020112606
observations/ob.ascii.2020112609
```

The date of the files must indicates the year/month/day/hour of 
each one of the three steps. 

It's possible for WRF to assimilates data of instants slightly different from the nominal 
instant, but the name should nonetheless reflects the nominal instant, not the real one.

In other words, you are allowed to assimilate e.g. radar datas acquired at
2020-11-26 08:53, but the realtive file should be named 2020112609.

### wrfda-runner.cfg

This is the main configuration files used by https://github.com/meteocima/wrfda-runner
it could/should contains following configuration variables:


* _GeodataDir_  - path to a directory containing static geo data. 
* _CovarMatrixesDir_ - path to the directory containing covariance matrix. Default: ./covar-matrices
            _stuff inside this dir should be organized as explained in [covar-matrices](#covar-matrices)_
* _WPSPrg_ - path to the directory containing compiled WPS software. This should have been compiled from 
             https://github.com/meteocima/WPS/tree/v4.1-smoothpasses-cima in order to get custom cima changes
             from the off-the-shelve WPS software.
* _WRFDAPrg_ - path to the directory containing WRFDA software. This should have been compiled from 
             https://github.com/meteocima/WRF/tree/v4.1.5-cima in order to get custom cima changes
             from the off-the-shelve WPS software.
* _WRFMainRunPrg_ - path to the directory containing WRF software to use for 3 cycle. This should have been compiled from 
             https://github.com/meteocima/WRF/tree/v4.1.5-cima in order to get custom cima changes
             from the off-the-shelve WPS software.
* _WRFAssStepPrg_- path to the directory containing WRF software to use for 3 cycle. This should have been compiled from 
             https://github.com/meteocima/WRF/tree/v4.1.5-cima in order to get custom cima changes
             from the off-the-shelve WPS software.
* _GFSArchive_ - path to input data directory. Despite the name, you could use this configuration property both for GFS and IFS.  Default: ./input
            _stuff inside this dir should be organized as explained in [inputs](#inputs)_
* _ObservationsArchive_ - path to input observations data directory. 
            _stuff inside this dir should be organized as explained in [covar-matrices](#covar-matrices)_
* _NamelistsDir_ - path to namelists. Default: ./namelists
            _stuff inside this dir should be organized as explained in [namelists](#namelists)_


### schedule-run.sh

script to sbatch schedule the simulation. You'll probably have to change content
of this scripts in order to accomodate your particular server scheduler and configuration.


* r2w - https://github.com/meteocima/radar2wrf/
* dewetra2wrf - https://github.com/meteocima/dewetra2wrf

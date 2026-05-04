#!/bin/bash

# Bring in the read only libraries
git submodule update --init --recursive --remote

# Just in case some wierd versions are installed 
module unload cadence-SPECTRE cadence-IC cadence-PVS cadence-DDI cadence-XCELIUM

# Grab the correct versions of the tools
module load cadence-XCELIUM/22.09-2 cadence-DDI/23.1



#
# Special stuff for tad
#
#if [ `whoami` = "d66317d" ] ; then
#fi

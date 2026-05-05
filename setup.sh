#!/bin/bash

# Bring in the read only libraries
git submodule update --init --recursive --remote

# Just in case some wierd versions are installed 
module unload cadence-SPECTRE cadence-IC cadence-PVS cadence-DDI cadence-XCELIUM

# Grab the correct versions of the tools
module load cadence-XCELIUM/22.09-2 cadence-DDI/23.1

export RAK=/thayerfs/courses/26spring/engs084/workspace/rak/Genus_CUI_RAK

ln -sf $RAK/LEF labs/
ln -sf $RAK/LIB labs/
ln -sf $RAK/RTL labs/
ln -sf $RAK/constraints labs/



#
# Special stuff for tad
#
#if [ `whoami` = "d66317d" ] ; then
#fi

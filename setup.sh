#!/bin/bash

# Bring in the read only libraries
git submodule update --init --recursive --remote

# Just in case some wierd versions are installed 
module unload cadence-SPECTRE cadence-IC cadence-PVS cadence-DDI cadence-XCELIUM

# Grab the correct versions of the tools
module load cadence-XCELIUM/22.09-2 cadence-DDI/23.1 cadence-IC/23.100

export RAK=/thayerfs/courses/26spring/engs084/workspace/rak/Genus_CUI_RAK
export RAK2=/thayerfs/courses/26spring/engs084/workspace/rak/RAK_floorplanning_22.1

mkdir -p labs/genus
ln -sf $RAK/LEF labs/genus/
ln -sf $RAK/LIB labs/genus/
ln -sf $RAK/RTL labs/genus/
ln -sf $RAK/constraints labs/genus/
cp -r $RAK/LAB* labs/genus/

mkdir -p labs/innovus
ln -sf $RAK2/DATA labs/innovus/
ln -sf $RAK2/DBS labs/innovus/
ln -sf $RAK2/DOCs labs/innovus/
ln -sf $RAK2/libs labs/innovus/
ln -sf $RAK2/SCRIPTS labs/innovus/



#
# Special stuff for tad
#
#if [ `whoami` = "d66317d" ] ; then
#fi

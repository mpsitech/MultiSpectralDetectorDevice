#!/bin/bash
# file checkin.sh
# checkin script for Digilent Basys3 unit of Msdd embedded system code, release msdd_jack
# author Alexander Wirthmueller
# date created: 18 Oct 2018
# modified: 18 Oct 2018

export set REPROOT=/home/mpsitech/srcrep

cp bss3.srcs/constrs_1/imports/bss3/*.xdc $REPROOT/msdd/msdd/bss3/
cp bss3.srcs/sources_1/imports/bss3/*.vhd $REPROOT/msdd/msdd/bss3/


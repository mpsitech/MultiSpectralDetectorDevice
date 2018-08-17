#!/bin/bash
# file checkin.sh
# checkin script for ZedBoard unit of Msdd embedded system code, release msdd_jack
# author Alexander Wirthmueller
# date created: 12 Aug 2018
# modified: 12 Aug 2018

export set REPROOT=/home/mpsitech/srcrep

cp zedb.srcs/constrs_1/imports/zedb/*.xdc $REPROOT/msdd/msdd/zedb/
cp zedb.srcs/sources_1/imports/zedb/*.vhd $REPROOT/msdd/msdd/zedb/


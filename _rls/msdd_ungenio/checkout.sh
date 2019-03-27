#!/bin/bash
# file checkout.sh
# checkout script for Msdd embedded system code, release msdd_ungenio
# author Alexander Wirthmueller
# date created: 18 Oct 2018
# modified: 18 Oct 2018

export set FPGAROOT=

if [ $? -ne 0 ]; then
	exit
fi

if [ "$1" = "all" ]; then
	unts=("bss3" "zedb")
else
	unts=("$@")
fi;

for var in "${unts[@]}"
do
	cp checkin_"$var".sh $FPGAROOT/"$var"/checkin.sh
	if [ 0 == 1 ]; then
		cp ../../msdd/"$var"/*.ucf $FPGAROOT/"$var"/
		cp ../../msdd/"$var"/*.vhd $FPGAROOT/"$var"/
	else
		cp ../../msdd/"$var"/*.xdc $FPGAROOT/"$var"/"$var".srcs/constrs_1/imports/"$var"/
		cp ../../msdd/"$var"/*.vhd $FPGAROOT/"$var"/"$var".srcs/sources_1/imports/"$var"/
	fi
done


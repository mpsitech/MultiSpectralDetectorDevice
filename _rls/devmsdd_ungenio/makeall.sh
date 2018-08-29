#!/bin/bash
# file makeall.sh
# make script for Msdd device access library, release devmsdd_ungenio
# author Alexander Wirthmueller
# date created: 26 Aug 2018
# modified: 26 Aug 2018

make DevMsdd.h.gch
if [ $? -ne 0 ]; then
	exit
fi

make -j2
if [ $? -ne 0 ]; then
	exit
fi

make install


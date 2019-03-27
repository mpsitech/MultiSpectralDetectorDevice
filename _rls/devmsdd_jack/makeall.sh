#!/bin/bash
# file makeall.sh
# make script for Msdd device access library, release devmsdd_jack
# author Alexander Wirthmueller
# date created: 18 Oct 2018
# modified: 18 Oct 2018

make DevMsdd.h.gch
if [ $? -ne 0 ]; then
	exit
fi

make -j16
if [ $? -ne 0 ]; then
	exit
fi

make install


# file checkout.sh
# checkout script for Msdd device access library sources, release devmsdd_zedboard
# author Alexander Wirthmueller
# date created: 26 Aug 2018
# modified: 26 Aug 2018

export set SRCROOT=/home/mpsitech/emb/zedboard/avnet-digilent-zedboard-2017.2/build/tmp/sysroots/plnx_arm/home/root/src

mkdir $SRCROOT/devmsdd

cp makeall.sh $SRCROOT/devmsdd/

cp Makefile $SRCROOT/devmsdd/

cp ../../devmsdd/*.h $SRCROOT/devmsdd/
cp ../../devmsdd/*.cpp $SRCROOT/devmsdd/

cp ../../devmsdd/UntMsddBss3/*.h $SRCROOT/devmsdd/
cp ../../devmsdd/UntMsddBss3/*.cpp $SRCROOT/devmsdd/

cp ../../devmsdd/UntMsddZedb/*.h $SRCROOT/devmsdd/
cp ../../devmsdd/UntMsddZedb/*.cpp $SRCROOT/devmsdd/


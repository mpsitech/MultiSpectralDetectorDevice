# file checkout.sh
# checkout script for Msdd device access library sources, release devmsdd_jack
# author Alexander Wirthmueller
# date created: 18 Oct 2018
# modified: 18 Oct 2018

export set SRCROOT=/home/mpsitech/src

mkdir $SRCROOT/devmsdd

cp makeall.sh $SRCROOT/devmsdd/

cp Makefile $SRCROOT/devmsdd/

cp ../../devmsdd/*.h $SRCROOT/devmsdd/
cp ../../devmsdd/*.cpp $SRCROOT/devmsdd/

cp ../../devmsdd/UntMsddBss3/*.h $SRCROOT/devmsdd/
cp ../../devmsdd/UntMsddBss3/*.cpp $SRCROOT/devmsdd/

cp ../../devmsdd/UntMsddZedb/*.h $SRCROOT/devmsdd/
cp ../../devmsdd/UntMsddZedb/*.cpp $SRCROOT/devmsdd/


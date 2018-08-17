# file Makefile
# make file for Msdd device access library, release devmsdd_ungenio
# author Alexander Wirthmueller
# date created: 12 Aug 2018
# modified: 12 Aug 2018

SRCROOT = /Users/mpsitech/src
LIBROOT = /Users/mpsitech/lib

CPP = g++
CPPFLAGS = -std=c++11 -g -Wall -Os -pthread

STATLIB = ar
STATLIBFLAGS = rcs

INCPATH = -I$(SRCROOT)
INCPATH = -I/usr/local/include -I/usr/local/include/libxml2

PCHS = DevMsdd.h.gch

OBJS = Msdd.o
OBJS +=
OBJS += UntMsddBss3.o UntMsddBss3_vecs.o CtrMsddBss3Adxl.o CtrMsddBss3Align.o CtrMsddBss3Led.o CtrMsddBss3Lwiracq.o CtrMsddBss3Lwirif.o CtrMsddBss3Servo.o CtrMsddBss3State.o CtrMsddBss3Tkclksrc.o CtrMsddBss3Trigger.o CtrMsddBss3Vgaacq.o
OBJS += UntMsddZedb.o UntMsddZedb_vecs.o CtrMsddZedbAdxl.o CtrMsddZedbAlign.o CtrMsddZedbLed.o CtrMsddZedbLwiracq.o CtrMsddZedbLwirif.o CtrMsddZedbServo.o CtrMsddZedbState.o CtrMsddZedbTkclksrc.o CtrMsddZedbTrigger.o CtrMsddZedbVgaacq.o

LIB = libdevmsdd

.SUFFIXES: .h .h.gch .cpp

.h.h.gch :
	$(CPP) $(CPPFLAGS) $(INCPATH) -o $@ -c $<

.cpp.o:
	$(CPP) $(CPPFLAGS) $(INCPATH) -o $@ -c $<

all:	$(LIB)

$(LIB):	$(PCHS) $(OBJS)
	$(STATLIB) $(STATLIBFLAGS) $(LIB).a $(OBJS)
	rm -f *.o

install:
	mv $(LIB).a $(LIBROOT)/

clean: 
	rm -f *.gch
	rm -f *.o


# file Makefile
# make file for Msdd device access library, release devmsdd_zedboard
# author Alexander Wirthmueller
# date created: 12 Aug 2018
# modified: 12 Aug 2018

SRCROOT = /home/root/src
LIBROOT = /home/mpsitech/emb/zedboard/avnet-digilent-zedboard-2017.2/build/tmp/sysroots/plnx_arm/home/root/lib

CPP = /opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-g++
CPPFLAGS = --sysroot=/home/mpsitech/emb/zedboard/avnet-digilent-zedboard-2017.2/build/tmp/sysroots/plnx_arm -std=c++11 -mfloat-abi=hard -g -Wall -Os -pthread

STATLIB = /opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-ar
STATLIBFLAGS = rcs

INCPATH = -I$(SRCROOT)
INCPATH = -I=/usr/include/libxml2 -I=/usr/local/include
INCPATH += -I/opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/include -I/opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/include/c++/5.2.1 -I/opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/include/c++/5.2.1/arm-linux-gnueabihf -I/opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/include/c++/5.2.1/backward -I/opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/arm-linux-gnueabihf/libc/usr/include -I/opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/lib/gcc/arm-linux-gnueabihf/5.2.1/include -I/opt/Xilinx/petalinux-v2017.2/tools/linux-i386/gcc-arm-linux-gnueabi/lib/gcc/arm-linux-gnueabihf/5.2.1/include-fixed

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


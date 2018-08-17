/**
  * \file UntMsddBss3.h
  * Digilent Basys3 unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#ifndef UNTMSDDBSS3_H
#define UNTMSDDBSS3_H

#include "Msdd.h"

#include "UntMsddBss3_vecs.h"

#include "CtrMsddBss3Adxl.h"
#include "CtrMsddBss3Align.h"
#include "CtrMsddBss3Led.h"
#include "CtrMsddBss3Lwiracq.h"
#include "CtrMsddBss3Lwirif.h"
#include "CtrMsddBss3Servo.h"
#include "CtrMsddBss3State.h"
#include "CtrMsddBss3Tkclksrc.h"
#include "CtrMsddBss3Trigger.h"
#include "CtrMsddBss3Vgaacq.h"

// IP custInclude --- IBEGIN
#ifdef __linux__
	#include <fcntl.h>
	#include <errno.h>
	#include <stdio.h>
	#include <string.h>
	#include <termios.h>
	#include <unistd.h>

	#include <linux/serial_core.h>
	#include <sys/ioctl.h>
#endif
// IP custInclude --- IEND

/**
	* UntMsddBss3
	*/
class UntMsddBss3 : public UntMsdd {

public:
	static constexpr unsigned int sizeRxbuf = 35;
	static constexpr unsigned int sizeTxbuf = 11;

public:
	UntMsddBss3();
	~UntMsddBss3();

public:
	// IP custVar --- IBEGIN
	string path;
	unsigned int bps;

	int fd;
	// IP custVar --- IEND

public:
	CtrMsddBss3Adxl* adxl;
	CtrMsddBss3Align* align;
	CtrMsddBss3Led* led;
	CtrMsddBss3Lwiracq* lwiracq;
	CtrMsddBss3Lwirif* lwirif;
	CtrMsddBss3Servo* servo;
	CtrMsddBss3State* state;
	CtrMsddBss3Tkclksrc* tkclksrc;
	CtrMsddBss3Trigger* trigger;
	CtrMsddBss3Vgaacq* vgaacq;

public:
	void init(const string& _path, const unsigned int _bps); // IP init --- RLINE
	void term();

public:
	bool rx(unsigned char* buf, const size_t reqlen);
	bool tx(unsigned char* buf, const size_t reqlen);

	void flush();

public:
	utinyint getTixVControllerBySref(const string& sref);
	string getSrefByTixVController(const utinyint tixVController);
	void fillFeedFController(Feed& feed);

	utinyint getTixWBufferBySref(const string& sref);
	string getSrefByTixWBuffer(const utinyint tixWBuffer);
	void fillFeedFBuffer(Feed& feed);

	utinyint getTixVCommandBySref(const utinyint tixVController, const string& sref);
	string getSrefByTixVCommand(const utinyint tixVController, const utinyint tixVCommand);
	void fillFeedFCommand(const utinyint tixVController, Feed& feed);

	Bufxf* getNewBufxf(const utinyint tixWBuffer, const size_t reqlen);
	Cmd* getNewCmd(const utinyint tixVController, const utinyint tixVCommand);

	Bufxf* getNewBufxfAbufFromLwiracq(const size_t reqlen);
	void readAbufFromLwiracq(const size_t reqlen, unsigned char*& data, size_t& datalen);

	Bufxf* getNewBufxfAbufFromVgaacq(const size_t reqlen);
	void readAbufFromVgaacq(const size_t reqlen, unsigned char*& data, size_t& datalen);

	Bufxf* getNewBufxfBbufFromLwiracq(const size_t reqlen);
	void readBbufFromLwiracq(const size_t reqlen, unsigned char*& data, size_t& datalen);

	Bufxf* getNewBufxfBbufFromVgaacq(const size_t reqlen);
	void readBbufFromVgaacq(const size_t reqlen, unsigned char*& data, size_t& datalen);

};

#endif


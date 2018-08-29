/**
  * \file UntMsddZedb.h
  * ZedBoard unit (declarations)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#ifndef UNTMSDDZEDB_H
#define UNTMSDDZEDB_H

#include "Msdd.h"

#include "UntMsddZedb_vecs.h"

#include "CtrMsddZedbAdxl.h"
#include "CtrMsddZedbAlign.h"
#include "CtrMsddZedbLed.h"
#include "CtrMsddZedbLwiracq.h"
#include "CtrMsddZedbLwirif.h"
#include "CtrMsddZedbServo.h"
#include "CtrMsddZedbState.h"
#include "CtrMsddZedbTkclksrc.h"
#include "CtrMsddZedbTrigger.h"
#include "CtrMsddZedbVgaacq.h"

// IP custInclude --- INSERT

/**
	* UntMsddZedb
	*/
class UntMsddZedb : public UntMsdd {

public:
	static constexpr unsigned int sizeRxbuf = 35;
	static constexpr unsigned int sizeTxbuf = 11;

public:
	UntMsddZedb();
	~UntMsddZedb();

public:
	// IP custVar --- IBEGIN
	string path;
	int fd;
	// IP custVar --- IEND

public:
	CtrMsddZedbAdxl* adxl;
	CtrMsddZedbAlign* align;
	CtrMsddZedbLed* led;
	CtrMsddZedbLwiracq* lwiracq;
	CtrMsddZedbLwirif* lwirif;
	CtrMsddZedbServo* servo;
	CtrMsddZedbState* state;
	CtrMsddZedbTkclksrc* tkclksrc;
	CtrMsddZedbTrigger* trigger;
	CtrMsddZedbVgaacq* vgaacq;

public:
	void init(const string& _path); // IP init --- RLINE
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

	Bufxf* getNewBufxf(const utinyint tixWBuffer, const size_t reqlen, unsigned char* buf);
	Cmd* getNewCmd(const utinyint tixVController, const utinyint tixVCommand);

	Bufxf* getNewBufxfAbufFromLwiracq(const size_t reqlen, unsigned char* buf);
	void readAbufFromLwiracq(const size_t reqlen, unsigned char*& data, size_t& datalen);

	Bufxf* getNewBufxfAbufFromVgaacq(const size_t reqlen, unsigned char* buf);
	void readAbufFromVgaacq(const size_t reqlen, unsigned char*& data, size_t& datalen);

	Bufxf* getNewBufxfBbufFromLwiracq(const size_t reqlen, unsigned char* buf);
	void readBbufFromLwiracq(const size_t reqlen, unsigned char*& data, size_t& datalen);

	Bufxf* getNewBufxfBbufFromVgaacq(const size_t reqlen, unsigned char* buf);
	void readBbufFromVgaacq(const size_t reqlen, unsigned char*& data, size_t& datalen);

};

#endif




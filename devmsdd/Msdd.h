/**
  * \file Msdd.h
  * Msdd global functionality and unit/controller exchange (declarations)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#ifndef MSDD_H
#define MSDD_H

#include <string>

using namespace std;

#include <sbecore/Mt.h>

#include <dbecore/Bufxf.h>
#include <dbecore/Cmd.h>
#include <dbecore/Crc.h>

/**
	* UntMsdd
	*/
class UntMsdd {

public:
	UntMsdd();
	virtual ~UntMsdd();

public:
	void lockAccess(const string& who);
	void unlockAccess(const string& who);

	void reset();

	bool runBufxf(Bufxf* bufxf);
	bool runBufxfFromBuf(Bufxf* bufxf);
	bool runBufxfToBuf(Bufxf* bufxf);

	bool runCmd(Cmd* cmd);
	bool runCmdInvToVoid(Cmd* cmd);
	bool runCmdVoidToRet(Cmd* cmd);

	void setBuffer(const utinyint tixWBuffer);
	void setController(const utinyint tixVController);
	void setCommand(const utinyint tixVCommand);
	void setLength(const size_t length);
	void setCrc(const usmallint crc, unsigned char* ptr = NULL);

public:
	virtual bool rx(unsigned char* buf, const size_t reqlen);
	virtual bool tx(unsigned char* buf, const size_t reqlen);

	virtual void flush();

	virtual utinyint getTixVControllerBySref(const string& sref);
	virtual string getSrefByTixVController(const utinyint tixVController);
	virtual void fillFeedFController(Feed& feed);

	virtual utinyint getTixWBufferBySref(const string& sref);
	virtual string getSrefByTixWBuffer(const utinyint tixWBuffer);
	virtual void fillFeedFBuffer(Feed& feed);

	virtual utinyint getTixVCommandBySref(const utinyint tixVController, const string& sref);
	virtual string getSrefByTixVCommand(const utinyint tixVController, const utinyint tixVCommand);
	virtual void fillFeedFCommand(const utinyint tixVController, Feed& feed);

	virtual Bufxf* getNewBufxf(const utinyint tixWBuffer, const size_t reqlen);
	virtual Cmd* getNewCmd(const utinyint tixVController, const utinyint tixVCommand);

	string getCmdInvTemplate(const utinyint tixVController, const utinyint tixVCommand);

public:
	bool initdone;

	bool txburst;
	bool rxtxdump;

	unsigned int Nretry;
	unsigned int to;

	unsigned char* rxbuf;
	unsigned char* txbuf;

	Mutex mAccess;
};

/**
	* CtrMsdd
	*/
class CtrMsdd {

public:
	CtrMsdd(UntMsdd* unt);
	virtual ~CtrMsdd();

public:
	UntMsdd* unt;
};

#endif


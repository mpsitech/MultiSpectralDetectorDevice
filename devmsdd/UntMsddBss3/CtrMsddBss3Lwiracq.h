/**
  * \file CtrMsddBss3Lwiracq.h
  * lwiracq controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDBSS3LWIRACQ_H
#define CTRMSDDBSS3LWIRACQ_H

#include "Msdd.h"

#define CmdMsddBss3LwiracqGetInfo CtrMsddBss3Lwiracq::CmdGetInfo

#define VecVMsddBss3LwiracqBufstate CtrMsddBss3Lwiracq::VecVBufstate
#define VecVMsddBss3LwiracqCommand CtrMsddBss3Lwiracq::VecVCommand

/**
	* CtrMsddBss3Lwiracq
	*/
class CtrMsddBss3Lwiracq : public CtrMsdd {

public:
	/**
		* VecVBufstate (full: VecVMsddBss3LwiracqBufstate)
		*/
	class VecVBufstate {

	public:
		static const utinyint IDLE = 0x00;
		static const utinyint EMPTY = 0x01;
		static const utinyint ABUF = 0x02;
		static const utinyint BBUF = 0x03;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

	/**
		* VecVCommand (full: VecVMsddBss3LwiracqCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETRNG = 0x00;
		static const utinyint GETINFO = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddBss3Lwiracq(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x04;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetRng();
	void setRng(const bool rng);

	static Cmd* getNewCmdGetInfo();
	void getInfo(utinyint& tixVBufstate, uint& tkst, usmallint& min, usmallint& max);

};

#endif


/**
  * \file CtrMsddZedbLwiracq.h
  * lwiracq controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#ifndef CTRMSDDZEDBLWIRACQ_H
#define CTRMSDDZEDBLWIRACQ_H

#include "Msdd.h"

#define CmdMsddZedbLwiracqGetInfo CtrMsddZedbLwiracq::CmdGetInfo

#define VecVMsddZedbLwiracqBufstate CtrMsddZedbLwiracq::VecVBufstate
#define VecVMsddZedbLwiracqCommand CtrMsddZedbLwiracq::VecVCommand

/**
	* CtrMsddZedbLwiracq
	*/
class CtrMsddZedbLwiracq : public CtrMsdd {

public:
	/**
		* VecVBufstate (full: VecVMsddZedbLwiracqBufstate)
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
		* VecVCommand (full: VecVMsddZedbLwiracqCommand)
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
	CtrMsddZedbLwiracq(UntMsdd* unt);

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


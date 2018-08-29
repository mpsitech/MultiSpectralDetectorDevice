/**
  * \file CtrMsddBss3Vgaacq.h
  * vgaacq controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#ifndef CTRMSDDBSS3VGAACQ_H
#define CTRMSDDBSS3VGAACQ_H

#include "Msdd.h"

#define CmdMsddBss3VgaacqGetInfo CtrMsddBss3Vgaacq::CmdGetInfo

#define VecVMsddBss3VgaacqBufstate CtrMsddBss3Vgaacq::VecVBufstate
#define VecVMsddBss3VgaacqCommand CtrMsddBss3Vgaacq::VecVCommand

/**
	* CtrMsddBss3Vgaacq
	*/
class CtrMsddBss3Vgaacq : public CtrMsdd {

public:
	/**
		* VecVBufstate (full: VecVMsddBss3VgaacqBufstate)
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
		* VecVCommand (full: VecVMsddBss3VgaacqCommand)
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
	CtrMsddBss3Vgaacq(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x0A;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetRng();
	void setRng(const bool rng);

	static Cmd* getNewCmdGetInfo();
	void getInfo(utinyint& tixVBufstate, uint& tkst);

};

#endif


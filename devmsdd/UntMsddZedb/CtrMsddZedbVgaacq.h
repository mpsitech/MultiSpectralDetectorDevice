/**
  * \file CtrMsddZedbVgaacq.h
  * vgaacq controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDZEDBVGAACQ_H
#define CTRMSDDZEDBVGAACQ_H

#include "Msdd.h"

#define CmdMsddZedbVgaacqGetInfo CtrMsddZedbVgaacq::CmdGetInfo

#define VecVMsddZedbVgaacqBufstate CtrMsddZedbVgaacq::VecVBufstate
#define VecVMsddZedbVgaacqCommand CtrMsddZedbVgaacq::VecVCommand

/**
	* CtrMsddZedbVgaacq
	*/
class CtrMsddZedbVgaacq : public CtrMsdd {

public:
	/**
		* VecVBufstate (full: VecVMsddZedbVgaacqBufstate)
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
		* VecVCommand (full: VecVMsddZedbVgaacqCommand)
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
	CtrMsddZedbVgaacq(UntMsdd* unt);

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


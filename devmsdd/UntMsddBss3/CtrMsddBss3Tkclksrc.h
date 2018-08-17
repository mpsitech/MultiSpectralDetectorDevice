/**
  * \file CtrMsddBss3Tkclksrc.h
  * tkclksrc controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#ifndef CTRMSDDBSS3TKCLKSRC_H
#define CTRMSDDBSS3TKCLKSRC_H

#include "Msdd.h"

#define CmdMsddBss3TkclksrcGetTkst CtrMsddBss3Tkclksrc::CmdGetTkst

#define VecVMsddBss3TkclksrcCommand CtrMsddBss3Tkclksrc::VecVCommand

/**
	* CtrMsddBss3Tkclksrc
	*/
class CtrMsddBss3Tkclksrc : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3TkclksrcCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETTKST = 0x00;
		static const utinyint SETTKST = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddBss3Tkclksrc(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x08;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdGetTkst();
	void getTkst(uint& tkst);

	static Cmd* getNewCmdSetTkst();
	void setTkst(const uint tkst);

};

#endif


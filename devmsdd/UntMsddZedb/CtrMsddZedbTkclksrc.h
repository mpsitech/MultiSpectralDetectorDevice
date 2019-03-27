/**
  * \file CtrMsddZedbTkclksrc.h
  * tkclksrc controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDZEDBTKCLKSRC_H
#define CTRMSDDZEDBTKCLKSRC_H

#include "Msdd.h"

#define CmdMsddZedbTkclksrcGetTkst CtrMsddZedbTkclksrc::CmdGetTkst

#define VecVMsddZedbTkclksrcCommand CtrMsddZedbTkclksrc::VecVCommand

/**
	* CtrMsddZedbTkclksrc
	*/
class CtrMsddZedbTkclksrc : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddZedbTkclksrcCommand)
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
	CtrMsddZedbTkclksrc(UntMsdd* unt);

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


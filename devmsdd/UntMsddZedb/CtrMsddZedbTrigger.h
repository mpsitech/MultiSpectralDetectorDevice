/**
  * \file CtrMsddZedbTrigger.h
  * trigger controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#ifndef CTRMSDDZEDBTRIGGER_H
#define CTRMSDDZEDBTRIGGER_H

#include "Msdd.h"

#define VecVMsddZedbTriggerCommand CtrMsddZedbTrigger::VecVCommand

/**
	* CtrMsddZedbTrigger
	*/
class CtrMsddZedbTrigger : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddZedbTriggerCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETRNG = 0x00;
		static const utinyint SETTDLYLWIR = 0x01;
		static const utinyint SETTDLYVISR = 0x02;
		static const utinyint SETTFRM = 0x03;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddZedbTrigger(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x09;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetRng();
	void setRng(const bool rng, const bool btnNotTfrm);

	static Cmd* getNewCmdSetTdlyLwir();
	void setTdlyLwir(const usmallint tdlyLwir);

	static Cmd* getNewCmdSetTdlyVisr();
	void setTdlyVisr(const usmallint tdlyVisr);

	static Cmd* getNewCmdSetTfrm();
	void setTfrm(const usmallint Tfrm);

};

#endif


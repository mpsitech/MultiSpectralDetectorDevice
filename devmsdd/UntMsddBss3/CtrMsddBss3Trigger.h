/**
  * \file CtrMsddBss3Trigger.h
  * trigger controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDBSS3TRIGGER_H
#define CTRMSDDBSS3TRIGGER_H

#include "Msdd.h"

#define VecVMsddBss3TriggerCommand CtrMsddBss3Trigger::VecVCommand

/**
	* CtrMsddBss3Trigger
	*/
class CtrMsddBss3Trigger : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3TriggerCommand)
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
	CtrMsddBss3Trigger(UntMsdd* unt);

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


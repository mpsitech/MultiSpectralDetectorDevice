/**
  * \file CtrMsddBss3State.h
  * state controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDBSS3STATE_H
#define CTRMSDDBSS3STATE_H

#include "Msdd.h"

#include "UntMsddBss3_vecs.h"

#define CmdMsddBss3StateGet CtrMsddBss3State::CmdGet

#define VecVMsddBss3StateCommand CtrMsddBss3State::VecVCommand

/**
	* CtrMsddBss3State
	*/
class CtrMsddBss3State : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3StateCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GET = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddBss3State(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x07;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdGet();
	void get(utinyint& tixVBss3State);

};

#endif


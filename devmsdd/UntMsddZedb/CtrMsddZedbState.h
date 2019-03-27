/**
  * \file CtrMsddZedbState.h
  * state controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDZEDBSTATE_H
#define CTRMSDDZEDBSTATE_H

#include "Msdd.h"

#include "UntMsddZedb_vecs.h"

#define CmdMsddZedbStateGet CtrMsddZedbState::CmdGet

#define VecVMsddZedbStateCommand CtrMsddZedbState::VecVCommand

/**
	* CtrMsddZedbState
	*/
class CtrMsddZedbState : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddZedbStateCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GET = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddZedbState(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x07;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdGet();
	void get(utinyint& tixVZedbState);

};

#endif


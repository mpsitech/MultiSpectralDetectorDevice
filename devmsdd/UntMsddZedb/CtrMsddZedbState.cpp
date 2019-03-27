/**
  * \file CtrMsddZedbState.cpp
  * state controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "CtrMsddZedbState.h"

/******************************************************************************
 class CtrMsddZedbState::VecVCommand
 ******************************************************************************/

utinyint CtrMsddZedbState::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "get") return GET;

	return(0);
};

string CtrMsddZedbState::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GET) return("get");

	return("");
};

void CtrMsddZedbState::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {GET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbState
 ******************************************************************************/

CtrMsddZedbState::CtrMsddZedbState(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddZedbState::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddZedbState::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddZedbState::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddZedbState::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GET) cmd = getNewCmdGet();

	return cmd;
};

Cmd* CtrMsddZedbState::getNewCmdGet() {
	Cmd* cmd = new Cmd(0x07, VecVCommand::GET, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("tixVZedbState", Par::VecVType::TIX, VecVMsddZedbState::getTix, VecVMsddZedbState::getSref, VecVMsddZedbState::fillFeed);

	return cmd;
};

void CtrMsddZedbState::get(
			utinyint& tixVZedbState
		) {
	Cmd* cmd = getNewCmdGet();

	if (unt->runCmd(cmd)) {
		tixVZedbState = cmd->parsRet["tixVZedbState"].getTix();
	} else {
		delete cmd;
		throw DbeException("error running get");
	};

	delete cmd;
};


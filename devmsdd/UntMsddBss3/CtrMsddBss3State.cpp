/**
  * \file CtrMsddBss3State.cpp
  * state controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#include "CtrMsddBss3State.h"

/******************************************************************************
 class CtrMsddBss3State::VecVCommand
 ******************************************************************************/

utinyint CtrMsddBss3State::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "get") return GET;

	return(0);
};

string CtrMsddBss3State::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GET) return("get");

	return("");
};

void CtrMsddBss3State::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {GET};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3State
 ******************************************************************************/

CtrMsddBss3State::CtrMsddBss3State(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddBss3State::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddBss3State::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddBss3State::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddBss3State::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GET) cmd = getNewCmdGet();

	return cmd;
};

Cmd* CtrMsddBss3State::getNewCmdGet() {
	Cmd* cmd = new Cmd(0x07, VecVCommand::GET, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("tixVBss3State", Par::VecVType::TIX, VecVMsddBss3State::getTix, VecVMsddBss3State::getSref, VecVMsddBss3State::fillFeed);

	return cmd;
};

void CtrMsddBss3State::get(
			utinyint& tixVBss3State
		) {
	Cmd* cmd = getNewCmdGet();

	if (unt->runCmd(cmd)) {
		tixVBss3State = cmd->parsRet["tixVBss3State"].getTix();
	} else {
		delete cmd;
		throw DbeException("error running get");
	};

	delete cmd;
};


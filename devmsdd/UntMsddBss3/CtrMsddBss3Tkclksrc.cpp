/**
  * \file CtrMsddBss3Tkclksrc.cpp
  * tkclksrc controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "CtrMsddBss3Tkclksrc.h"

/******************************************************************************
 class CtrMsddBss3Tkclksrc::VecVCommand
 ******************************************************************************/

utinyint CtrMsddBss3Tkclksrc::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "gettkst") return GETTKST;
	else if (s == "settkst") return SETTKST;

	return(0);
};

string CtrMsddBss3Tkclksrc::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETTKST) return("getTkst");
	else if (tix == SETTKST) return("setTkst");

	return("");
};

void CtrMsddBss3Tkclksrc::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {GETTKST,SETTKST};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Tkclksrc
 ******************************************************************************/

CtrMsddBss3Tkclksrc::CtrMsddBss3Tkclksrc(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddBss3Tkclksrc::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddBss3Tkclksrc::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddBss3Tkclksrc::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddBss3Tkclksrc::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETTKST) cmd = getNewCmdGetTkst();
	else if (tixVCommand == VecVCommand::SETTKST) cmd = getNewCmdSetTkst();

	return cmd;
};

Cmd* CtrMsddBss3Tkclksrc::getNewCmdGetTkst() {
	Cmd* cmd = new Cmd(0x08, VecVCommand::GETTKST, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("tkst", Par::VecVType::UINT);

	return cmd;
};

void CtrMsddBss3Tkclksrc::getTkst(
			uint& tkst
		) {
	Cmd* cmd = getNewCmdGetTkst();

	if (unt->runCmd(cmd)) {
		tkst = cmd->parsRet["tkst"].getUint();
	} else {
		delete cmd;
		throw DbeException("error running getTkst");
	};

	delete cmd;
};

Cmd* CtrMsddBss3Tkclksrc::getNewCmdSetTkst() {
	Cmd* cmd = new Cmd(0x08, VecVCommand::SETTKST, Cmd::VecVRettype::VOID);

	cmd->addParInv("tkst", Par::VecVType::UINT);

	return cmd;
};

void CtrMsddBss3Tkclksrc::setTkst(
			const uint tkst
		) {
	Cmd* cmd = getNewCmdSetTkst();

	cmd->parsInv["tkst"].setUint(tkst);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setTkst");
	};

	delete cmd;
};


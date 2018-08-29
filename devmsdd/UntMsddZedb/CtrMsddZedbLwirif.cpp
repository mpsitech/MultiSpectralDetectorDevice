/**
  * \file CtrMsddZedbLwirif.cpp
  * lwirif controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#include "CtrMsddZedbLwirif.h"

/******************************************************************************
 class CtrMsddZedbLwirif::VecVCommand
 ******************************************************************************/

utinyint CtrMsddZedbLwirif::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;

	return(0);
};

string CtrMsddZedbLwirif::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");

	return("");
};

void CtrMsddZedbLwirif::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETRNG};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbLwirif
 ******************************************************************************/

CtrMsddZedbLwirif::CtrMsddZedbLwirif(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddZedbLwirif::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddZedbLwirif::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddZedbLwirif::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddZedbLwirif::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();

	return cmd;
};

Cmd* CtrMsddZedbLwirif::getNewCmdSetRng() {
	Cmd* cmd = new Cmd(0x05, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	return cmd;
};

void CtrMsddZedbLwirif::setRng(
			const bool rng
		) {
	Cmd* cmd = getNewCmdSetRng();

	cmd->parsInv["rng"].setBool(rng);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setRng");
	};

	delete cmd;
};


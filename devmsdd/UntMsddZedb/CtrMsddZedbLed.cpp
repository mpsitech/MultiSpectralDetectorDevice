/**
  * \file CtrMsddZedbLed.cpp
  * led controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "CtrMsddZedbLed.h"

/******************************************************************************
 class CtrMsddZedbLed::VecVCommand
 ******************************************************************************/

utinyint CtrMsddZedbLed::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setton15") return SETTON15;
	else if (s == "setton60") return SETTON60;

	return(0);
};

string CtrMsddZedbLed::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETTON15) return("setTon15");
	else if (tix == SETTON60) return("setTon60");

	return("");
};

void CtrMsddZedbLed::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETTON15,SETTON60};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbLed
 ******************************************************************************/

CtrMsddZedbLed::CtrMsddZedbLed(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddZedbLed::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddZedbLed::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddZedbLed::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddZedbLed::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETTON15) cmd = getNewCmdSetTon15();
	else if (tixVCommand == VecVCommand::SETTON60) cmd = getNewCmdSetTon60();

	return cmd;
};

Cmd* CtrMsddZedbLed::getNewCmdSetTon15() {
	Cmd* cmd = new Cmd(0x03, VecVCommand::SETTON15, Cmd::VecVRettype::VOID);

	cmd->addParInv("ton15", Par::VecVType::UTINYINT);

	return cmd;
};

void CtrMsddZedbLed::setTon15(
			const utinyint ton15
		) {
	Cmd* cmd = getNewCmdSetTon15();

	cmd->parsInv["ton15"].setUtinyint(ton15);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setTon15");
	};

	delete cmd;
};

Cmd* CtrMsddZedbLed::getNewCmdSetTon60() {
	Cmd* cmd = new Cmd(0x03, VecVCommand::SETTON60, Cmd::VecVRettype::VOID);

	cmd->addParInv("ton60", Par::VecVType::UTINYINT);

	return cmd;
};

void CtrMsddZedbLed::setTon60(
			const utinyint ton60
		) {
	Cmd* cmd = getNewCmdSetTon60();

	cmd->parsInv["ton60"].setUtinyint(ton60);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setTon60");
	};

	delete cmd;
};


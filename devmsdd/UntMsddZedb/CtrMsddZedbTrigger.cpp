/**
  * \file CtrMsddZedbTrigger.cpp
  * trigger controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#include "CtrMsddZedbTrigger.h"

/******************************************************************************
 class CtrMsddZedbTrigger::VecVCommand
 ******************************************************************************/

utinyint CtrMsddZedbTrigger::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;
	else if (s == "settdlylwir") return SETTDLYLWIR;
	else if (s == "settdlyvisr") return SETTDLYVISR;
	else if (s == "settfrm") return SETTFRM;

	return(0);
};

string CtrMsddZedbTrigger::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");
	else if (tix == SETTDLYLWIR) return("setTdlyLwir");
	else if (tix == SETTDLYVISR) return("setTdlyVisr");
	else if (tix == SETTFRM) return("setTfrm");

	return("");
};

void CtrMsddZedbTrigger::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETRNG,SETTDLYLWIR,SETTDLYVISR,SETTFRM};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbTrigger
 ******************************************************************************/

CtrMsddZedbTrigger::CtrMsddZedbTrigger(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddZedbTrigger::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddZedbTrigger::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddZedbTrigger::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddZedbTrigger::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::SETTDLYLWIR) cmd = getNewCmdSetTdlyLwir();
	else if (tixVCommand == VecVCommand::SETTDLYVISR) cmd = getNewCmdSetTdlyVisr();
	else if (tixVCommand == VecVCommand::SETTFRM) cmd = getNewCmdSetTfrm();

	return cmd;
};

Cmd* CtrMsddZedbTrigger::getNewCmdSetRng() {
	Cmd* cmd = new Cmd(0x09, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);
	cmd->addParInv("btnNotTfrm", Par::VecVType::_BOOL);

	return cmd;
};

void CtrMsddZedbTrigger::setRng(
			const bool rng
			, const bool btnNotTfrm
		) {
	Cmd* cmd = getNewCmdSetRng();

	cmd->parsInv["rng"].setBool(rng);
	cmd->parsInv["btnNotTfrm"].setBool(btnNotTfrm);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setRng");
	};

	delete cmd;
};

Cmd* CtrMsddZedbTrigger::getNewCmdSetTdlyLwir() {
	Cmd* cmd = new Cmd(0x09, VecVCommand::SETTDLYLWIR, Cmd::VecVRettype::VOID);

	cmd->addParInv("tdlyLwir", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrMsddZedbTrigger::setTdlyLwir(
			const usmallint tdlyLwir
		) {
	Cmd* cmd = getNewCmdSetTdlyLwir();

	cmd->parsInv["tdlyLwir"].setUsmallint(tdlyLwir);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setTdlyLwir");
	};

	delete cmd;
};

Cmd* CtrMsddZedbTrigger::getNewCmdSetTdlyVisr() {
	Cmd* cmd = new Cmd(0x09, VecVCommand::SETTDLYVISR, Cmd::VecVRettype::VOID);

	cmd->addParInv("tdlyVisr", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrMsddZedbTrigger::setTdlyVisr(
			const usmallint tdlyVisr
		) {
	Cmd* cmd = getNewCmdSetTdlyVisr();

	cmd->parsInv["tdlyVisr"].setUsmallint(tdlyVisr);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setTdlyVisr");
	};

	delete cmd;
};

Cmd* CtrMsddZedbTrigger::getNewCmdSetTfrm() {
	Cmd* cmd = new Cmd(0x09, VecVCommand::SETTFRM, Cmd::VecVRettype::VOID);

	cmd->addParInv("Tfrm", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrMsddZedbTrigger::setTfrm(
			const usmallint Tfrm
		) {
	Cmd* cmd = getNewCmdSetTfrm();

	cmd->parsInv["Tfrm"].setUsmallint(Tfrm);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setTfrm");
	};

	delete cmd;
};


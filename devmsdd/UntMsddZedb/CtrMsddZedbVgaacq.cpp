/**
  * \file CtrMsddZedbVgaacq.cpp
  * vgaacq controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#include "CtrMsddZedbVgaacq.h"

/******************************************************************************
 class CtrMsddZedbVgaacq::VecVBufstate
 ******************************************************************************/

utinyint CtrMsddZedbVgaacq::VecVBufstate::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "idle") return IDLE;
	else if (s == "empty") return EMPTY;
	else if (s == "abuf") return ABUF;
	else if (s == "bbuf") return BBUF;

	return(0);
};

string CtrMsddZedbVgaacq::VecVBufstate::getSref(
			const utinyint tix
		) {
	if (tix == IDLE) return("idle");
	else if (tix == EMPTY) return("empty");
	else if (tix == ABUF) return("abuf");
	else if (tix == BBUF) return("bbuf");

	return("");
};

void CtrMsddZedbVgaacq::VecVBufstate::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {IDLE,EMPTY,ABUF,BBUF};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbVgaacq::VecVCommand
 ******************************************************************************/

utinyint CtrMsddZedbVgaacq::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;
	else if (s == "getinfo") return GETINFO;

	return(0);
};

string CtrMsddZedbVgaacq::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");
	else if (tix == GETINFO) return("getInfo");

	return("");
};

void CtrMsddZedbVgaacq::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETRNG,GETINFO};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbVgaacq
 ******************************************************************************/

CtrMsddZedbVgaacq::CtrMsddZedbVgaacq(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddZedbVgaacq::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddZedbVgaacq::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddZedbVgaacq::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddZedbVgaacq::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::GETINFO) cmd = getNewCmdGetInfo();

	return cmd;
};

Cmd* CtrMsddZedbVgaacq::getNewCmdSetRng() {
	Cmd* cmd = new Cmd(0x0A, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	return cmd;
};

void CtrMsddZedbVgaacq::setRng(
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

Cmd* CtrMsddZedbVgaacq::getNewCmdGetInfo() {
	Cmd* cmd = new Cmd(0x0A, VecVCommand::GETINFO, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("tixVBufstate", Par::VecVType::TIX, CtrMsddZedbVgaacq::VecVBufstate::getTix, CtrMsddZedbVgaacq::VecVBufstate::getSref, CtrMsddZedbVgaacq::VecVBufstate::fillFeed);
	cmd->addParRet("tkst", Par::VecVType::UINT);

	return cmd;
};

void CtrMsddZedbVgaacq::getInfo(
			utinyint& tixVBufstate
			, uint& tkst
		) {
	Cmd* cmd = getNewCmdGetInfo();

	if (unt->runCmd(cmd)) {
		tixVBufstate = cmd->parsRet["tixVBufstate"].getTix();
		tkst = cmd->parsRet["tkst"].getUint();
	} else {
		delete cmd;
		throw DbeException("error running getInfo");
	};

	delete cmd;
};


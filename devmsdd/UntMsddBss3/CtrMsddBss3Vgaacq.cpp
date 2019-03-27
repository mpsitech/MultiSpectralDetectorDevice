/**
  * \file CtrMsddBss3Vgaacq.cpp
  * vgaacq controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "CtrMsddBss3Vgaacq.h"

/******************************************************************************
 class CtrMsddBss3Vgaacq::VecVBufstate
 ******************************************************************************/

utinyint CtrMsddBss3Vgaacq::VecVBufstate::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "idle") return IDLE;
	else if (s == "empty") return EMPTY;
	else if (s == "abuf") return ABUF;
	else if (s == "bbuf") return BBUF;

	return(0);
};

string CtrMsddBss3Vgaacq::VecVBufstate::getSref(
			const utinyint tix
		) {
	if (tix == IDLE) return("idle");
	else if (tix == EMPTY) return("empty");
	else if (tix == ABUF) return("abuf");
	else if (tix == BBUF) return("bbuf");

	return("");
};

void CtrMsddBss3Vgaacq::VecVBufstate::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {IDLE,EMPTY,ABUF,BBUF};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Vgaacq::VecVCommand
 ******************************************************************************/

utinyint CtrMsddBss3Vgaacq::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;
	else if (s == "getinfo") return GETINFO;

	return(0);
};

string CtrMsddBss3Vgaacq::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");
	else if (tix == GETINFO) return("getInfo");

	return("");
};

void CtrMsddBss3Vgaacq::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETRNG,GETINFO};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Vgaacq
 ******************************************************************************/

CtrMsddBss3Vgaacq::CtrMsddBss3Vgaacq(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddBss3Vgaacq::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddBss3Vgaacq::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddBss3Vgaacq::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddBss3Vgaacq::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::GETINFO) cmd = getNewCmdGetInfo();

	return cmd;
};

Cmd* CtrMsddBss3Vgaacq::getNewCmdSetRng() {
	Cmd* cmd = new Cmd(0x0A, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	return cmd;
};

void CtrMsddBss3Vgaacq::setRng(
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

Cmd* CtrMsddBss3Vgaacq::getNewCmdGetInfo() {
	Cmd* cmd = new Cmd(0x0A, VecVCommand::GETINFO, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("tixVBufstate", Par::VecVType::TIX, CtrMsddBss3Vgaacq::VecVBufstate::getTix, CtrMsddBss3Vgaacq::VecVBufstate::getSref, CtrMsddBss3Vgaacq::VecVBufstate::fillFeed);
	cmd->addParRet("tkst", Par::VecVType::UINT);

	return cmd;
};

void CtrMsddBss3Vgaacq::getInfo(
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


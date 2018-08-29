/**
  * \file CtrMsddBss3Lwiracq.cpp
  * lwiracq controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#include "CtrMsddBss3Lwiracq.h"

/******************************************************************************
 class CtrMsddBss3Lwiracq::VecVBufstate
 ******************************************************************************/

utinyint CtrMsddBss3Lwiracq::VecVBufstate::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "idle") return IDLE;
	else if (s == "empty") return EMPTY;
	else if (s == "abuf") return ABUF;
	else if (s == "bbuf") return BBUF;

	return(0);
};

string CtrMsddBss3Lwiracq::VecVBufstate::getSref(
			const utinyint tix
		) {
	if (tix == IDLE) return("idle");
	else if (tix == EMPTY) return("empty");
	else if (tix == ABUF) return("abuf");
	else if (tix == BBUF) return("bbuf");

	return("");
};

void CtrMsddBss3Lwiracq::VecVBufstate::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {IDLE,EMPTY,ABUF,BBUF};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Lwiracq::VecVCommand
 ******************************************************************************/

utinyint CtrMsddBss3Lwiracq::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setrng") return SETRNG;
	else if (s == "getinfo") return GETINFO;

	return(0);
};

string CtrMsddBss3Lwiracq::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETRNG) return("setRng");
	else if (tix == GETINFO) return("getInfo");

	return("");
};

void CtrMsddBss3Lwiracq::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETRNG,GETINFO};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Lwiracq
 ******************************************************************************/

CtrMsddBss3Lwiracq::CtrMsddBss3Lwiracq(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddBss3Lwiracq::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddBss3Lwiracq::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddBss3Lwiracq::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddBss3Lwiracq::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETRNG) cmd = getNewCmdSetRng();
	else if (tixVCommand == VecVCommand::GETINFO) cmd = getNewCmdGetInfo();

	return cmd;
};

Cmd* CtrMsddBss3Lwiracq::getNewCmdSetRng() {
	Cmd* cmd = new Cmd(0x04, VecVCommand::SETRNG, Cmd::VecVRettype::VOID);

	cmd->addParInv("rng", Par::VecVType::_BOOL);

	return cmd;
};

void CtrMsddBss3Lwiracq::setRng(
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

Cmd* CtrMsddBss3Lwiracq::getNewCmdGetInfo() {
	Cmd* cmd = new Cmd(0x04, VecVCommand::GETINFO, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("tixVBufstate", Par::VecVType::TIX, CtrMsddBss3Lwiracq::VecVBufstate::getTix, CtrMsddBss3Lwiracq::VecVBufstate::getSref, CtrMsddBss3Lwiracq::VecVBufstate::fillFeed);
	cmd->addParRet("tkst", Par::VecVType::UINT);
	cmd->addParRet("min", Par::VecVType::USMALLINT);
	cmd->addParRet("max", Par::VecVType::USMALLINT);

	return cmd;
};

void CtrMsddBss3Lwiracq::getInfo(
			utinyint& tixVBufstate
			, uint& tkst
			, usmallint& min
			, usmallint& max
		) {
	Cmd* cmd = getNewCmdGetInfo();

	if (unt->runCmd(cmd)) {
		tixVBufstate = cmd->parsRet["tixVBufstate"].getTix();
		tkst = cmd->parsRet["tkst"].getUint();
		min = cmd->parsRet["min"].getUsmallint();
		max = cmd->parsRet["max"].getUsmallint();
	} else {
		delete cmd;
		throw DbeException("error running getInfo");
	};

	delete cmd;
};


/**
  * \file CtrMsddBss3Adxl.cpp
  * adxl controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#include "CtrMsddBss3Adxl.h"

/******************************************************************************
 class CtrMsddBss3Adxl::VecVCommand
 ******************************************************************************/

utinyint CtrMsddBss3Adxl::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getax") return GETAX;
	else if (s == "getay") return GETAY;
	else if (s == "getaz") return GETAZ;

	return(0);
};

string CtrMsddBss3Adxl::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETAX) return("getAx");
	else if (tix == GETAY) return("getAy");
	else if (tix == GETAZ) return("getAz");

	return("");
};

void CtrMsddBss3Adxl::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {GETAX,GETAY,GETAZ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Adxl
 ******************************************************************************/

CtrMsddBss3Adxl::CtrMsddBss3Adxl(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddBss3Adxl::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddBss3Adxl::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddBss3Adxl::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddBss3Adxl::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETAX) cmd = getNewCmdGetAx();
	else if (tixVCommand == VecVCommand::GETAY) cmd = getNewCmdGetAy();
	else if (tixVCommand == VecVCommand::GETAZ) cmd = getNewCmdGetAz();

	return cmd;
};

Cmd* CtrMsddBss3Adxl::getNewCmdGetAx() {
	Cmd* cmd = new Cmd(0x01, VecVCommand::GETAX, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("ax", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddBss3Adxl::getAx(
			smallint& ax
		) {
	Cmd* cmd = getNewCmdGetAx();

	if (unt->runCmd(cmd)) {
		ax = cmd->parsRet["ax"].getSmallint();
	} else {
		delete cmd;
		throw DbeException("error running getAx");
	};

	delete cmd;
};

Cmd* CtrMsddBss3Adxl::getNewCmdGetAy() {
	Cmd* cmd = new Cmd(0x01, VecVCommand::GETAY, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("ay", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddBss3Adxl::getAy(
			smallint& ay
		) {
	Cmd* cmd = getNewCmdGetAy();

	if (unt->runCmd(cmd)) {
		ay = cmd->parsRet["ay"].getSmallint();
	} else {
		delete cmd;
		throw DbeException("error running getAy");
	};

	delete cmd;
};

Cmd* CtrMsddBss3Adxl::getNewCmdGetAz() {
	Cmd* cmd = new Cmd(0x01, VecVCommand::GETAZ, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("az", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddBss3Adxl::getAz(
			smallint& az
		) {
	Cmd* cmd = getNewCmdGetAz();

	if (unt->runCmd(cmd)) {
		az = cmd->parsRet["az"].getSmallint();
	} else {
		delete cmd;
		throw DbeException("error running getAz");
	};

	delete cmd;
};


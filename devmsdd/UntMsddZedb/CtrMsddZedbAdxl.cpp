/**
  * \file CtrMsddZedbAdxl.cpp
  * adxl controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "CtrMsddZedbAdxl.h"

/******************************************************************************
 class CtrMsddZedbAdxl::VecVCommand
 ******************************************************************************/

utinyint CtrMsddZedbAdxl::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "getax") return GETAX;
	else if (s == "getay") return GETAY;
	else if (s == "getaz") return GETAZ;

	return(0);
};

string CtrMsddZedbAdxl::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == GETAX) return("getAx");
	else if (tix == GETAY) return("getAy");
	else if (tix == GETAZ) return("getAz");

	return("");
};

void CtrMsddZedbAdxl::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {GETAX,GETAY,GETAZ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbAdxl
 ******************************************************************************/

CtrMsddZedbAdxl::CtrMsddZedbAdxl(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddZedbAdxl::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddZedbAdxl::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddZedbAdxl::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddZedbAdxl::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::GETAX) cmd = getNewCmdGetAx();
	else if (tixVCommand == VecVCommand::GETAY) cmd = getNewCmdGetAy();
	else if (tixVCommand == VecVCommand::GETAZ) cmd = getNewCmdGetAz();

	return cmd;
};

Cmd* CtrMsddZedbAdxl::getNewCmdGetAx() {
	Cmd* cmd = new Cmd(0x01, VecVCommand::GETAX, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("ax", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddZedbAdxl::getAx(
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

Cmd* CtrMsddZedbAdxl::getNewCmdGetAy() {
	Cmd* cmd = new Cmd(0x01, VecVCommand::GETAY, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("ay", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddZedbAdxl::getAy(
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

Cmd* CtrMsddZedbAdxl::getNewCmdGetAz() {
	Cmd* cmd = new Cmd(0x01, VecVCommand::GETAZ, Cmd::VecVRettype::IMMSNG);

	cmd->addParRet("az", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddZedbAdxl::getAz(
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


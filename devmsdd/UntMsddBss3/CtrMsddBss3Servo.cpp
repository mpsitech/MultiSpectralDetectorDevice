/**
  * \file CtrMsddBss3Servo.cpp
  * servo controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#include "CtrMsddBss3Servo.h"

/******************************************************************************
 class CtrMsddBss3Servo::VecVCommand
 ******************************************************************************/

utinyint CtrMsddBss3Servo::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "settheta") return SETTHETA;
	else if (s == "setphi") return SETPHI;

	return(0);
};

string CtrMsddBss3Servo::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETTHETA) return("setTheta");
	else if (tix == SETPHI) return("setPhi");

	return("");
};

void CtrMsddBss3Servo::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETTHETA,SETPHI};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Servo
 ******************************************************************************/

CtrMsddBss3Servo::CtrMsddBss3Servo(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddBss3Servo::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddBss3Servo::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddBss3Servo::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddBss3Servo::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETTHETA) cmd = getNewCmdSetTheta();
	else if (tixVCommand == VecVCommand::SETPHI) cmd = getNewCmdSetPhi();

	return cmd;
};

Cmd* CtrMsddBss3Servo::getNewCmdSetTheta() {
	Cmd* cmd = new Cmd(0x06, VecVCommand::SETTHETA, Cmd::VecVRettype::VOID);

	cmd->addParInv("theta", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddBss3Servo::setTheta(
			const smallint theta
		) {
	Cmd* cmd = getNewCmdSetTheta();

	cmd->parsInv["theta"].setSmallint(theta);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setTheta");
	};

	delete cmd;
};

Cmd* CtrMsddBss3Servo::getNewCmdSetPhi() {
	Cmd* cmd = new Cmd(0x06, VecVCommand::SETPHI, Cmd::VecVRettype::VOID);

	cmd->addParInv("phi", Par::VecVType::SMALLINT);

	return cmd;
};

void CtrMsddBss3Servo::setPhi(
			const smallint phi
		) {
	Cmd* cmd = getNewCmdSetPhi();

	cmd->parsInv["phi"].setSmallint(phi);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setPhi");
	};

	delete cmd;
};


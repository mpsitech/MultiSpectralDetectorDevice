/**
  * \file CtrMsddBss3Align.cpp
  * align controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "CtrMsddBss3Align.h"

/******************************************************************************
 class CtrMsddBss3Align::VecVCommand
 ******************************************************************************/

utinyint CtrMsddBss3Align::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setseq") return SETSEQ;

	return(0);
};

string CtrMsddBss3Align::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETSEQ) return("setSeq");

	return("");
};

void CtrMsddBss3Align::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETSEQ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddBss3Align
 ******************************************************************************/

CtrMsddBss3Align::CtrMsddBss3Align(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddBss3Align::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddBss3Align::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddBss3Align::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddBss3Align::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETSEQ) cmd = getNewCmdSetSeq();

	return cmd;
};

Cmd* CtrMsddBss3Align::getNewCmdSetSeq() {
	Cmd* cmd = new Cmd(0x02, VecVCommand::SETSEQ, Cmd::VecVRettype::VOID);

	cmd->addParInv("seq", Par::VecVType::VBLOB, NULL, NULL, NULL, 32);

	return cmd;
};

void CtrMsddBss3Align::setSeq(
			const unsigned char* seq
			, const size_t seqlen
		) {
	Cmd* cmd = getNewCmdSetSeq();

	cmd->parsInv["seq"].setVblob(seq, seqlen);

	if (unt->runCmd(cmd)) {
	} else {
		delete cmd;
		throw DbeException("error running setSeq");
	};

	delete cmd;
};


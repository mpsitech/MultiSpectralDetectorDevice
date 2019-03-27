/**
  * \file CtrMsddZedbAlign.cpp
  * align controller (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "CtrMsddZedbAlign.h"

/******************************************************************************
 class CtrMsddZedbAlign::VecVCommand
 ******************************************************************************/

utinyint CtrMsddZedbAlign::VecVCommand::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "setseq") return SETSEQ;

	return(0);
};

string CtrMsddZedbAlign::VecVCommand::getSref(
			const utinyint tix
		) {
	if (tix == SETSEQ) return("setSeq");

	return("");
};

void CtrMsddZedbAlign::VecVCommand::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {SETSEQ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 class CtrMsddZedbAlign
 ******************************************************************************/

CtrMsddZedbAlign::CtrMsddZedbAlign(
			UntMsdd* unt
		) : CtrMsdd(unt) {
};

utinyint CtrMsddZedbAlign::getTixVCommandBySref(
			const string& sref
		) {
	return VecVCommand::getTix(sref);
};

string CtrMsddZedbAlign::getSrefByTixVCommand(
			const utinyint tixVCommand
		) {
	return VecVCommand::getSref(tixVCommand);
};

void CtrMsddZedbAlign::fillFeedFCommand(
			Feed& feed
		) {
	VecVCommand::fillFeed(feed);
};

Cmd* CtrMsddZedbAlign::getNewCmd(
			const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVCommand == VecVCommand::SETSEQ) cmd = getNewCmdSetSeq();

	return cmd;
};

Cmd* CtrMsddZedbAlign::getNewCmdSetSeq() {
	Cmd* cmd = new Cmd(0x02, VecVCommand::SETSEQ, Cmd::VecVRettype::VOID);

	cmd->addParInv("seq", Par::VecVType::VBLOB, NULL, NULL, NULL, 32);

	return cmd;
};

void CtrMsddZedbAlign::setSeq(
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


/**
  * \file UntMsddZedb_vecs.cpp
  * ZedBoard unit vectors (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "UntMsddZedb_vecs.h"

/******************************************************************************
 namespace VecVMsddZedbController
 ******************************************************************************/

utinyint VecVMsddZedbController::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "adxl") return ADXL;
	else if (s == "align") return ALIGN;
	else if (s == "led") return LED;
	else if (s == "lwiracq") return LWIRACQ;
	else if (s == "lwirif") return LWIRIF;
	else if (s == "servo") return SERVO;
	else if (s == "state") return STATE;
	else if (s == "tkclksrc") return TKCLKSRC;
	else if (s == "trigger") return TRIGGER;
	else if (s == "vgaacq") return VGAACQ;

	return(0);
};

string VecVMsddZedbController::getSref(
			const utinyint tix
		) {
	if (tix == ADXL) return("adxl");
	else if (tix == ALIGN) return("align");
	else if (tix == LED) return("led");
	else if (tix == LWIRACQ) return("lwiracq");
	else if (tix == LWIRIF) return("lwirif");
	else if (tix == SERVO) return("servo");
	else if (tix == STATE) return("state");
	else if (tix == TKCLKSRC) return("tkclksrc");
	else if (tix == TRIGGER) return("trigger");
	else if (tix == VGAACQ) return("vgaacq");

	return("");
};

void VecVMsddZedbController::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {ADXL,ALIGN,LED,LWIRACQ,LWIRIF,SERVO,STATE,TKCLKSRC,TRIGGER,VGAACQ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 namespace VecVMsddZedbState
 ******************************************************************************/

utinyint VecVMsddZedbState::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "nc") return NC;
	else if (s == "ready") return READY;
	else if (s == "active") return ACTIVE;

	return(0);
};

string VecVMsddZedbState::getSref(
			const utinyint tix
		) {
	if (tix == NC) return("nc");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("active");

	return("");
};

string VecVMsddZedbState::getTitle(
			const utinyint tix
		) {
	if (tix == NC) return("offline");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("acquisition running");

	return("");
};

void VecVMsddZedbState::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {NC,READY,ACTIVE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 namespace VecWMsddZedbBuffer
 ******************************************************************************/

utinyint VecWMsddZedbBuffer::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "cmdrettohostif") return CMDRETTOHOSTIF;
	else if (s == "hostiftocmdinv") return HOSTIFTOCMDINV;
	else if (s == "abuflwiracqtohostif") return ABUFLWIRACQTOHOSTIF;
	else if (s == "abufvgaacqtohostif") return ABUFVGAACQTOHOSTIF;
	else if (s == "bbuflwiracqtohostif") return BBUFLWIRACQTOHOSTIF;
	else if (s == "bbufvgaacqtohostif") return BBUFVGAACQTOHOSTIF;

	return(0);
};

string VecWMsddZedbBuffer::getSref(
			const utinyint tix
		) {
	if (tix == CMDRETTOHOSTIF) return("cmdretToHostif");
	else if (tix == HOSTIFTOCMDINV) return("hostifToCmdinv");
	else if (tix == ABUFLWIRACQTOHOSTIF) return("abufLwiracqToHostif");
	else if (tix == ABUFVGAACQTOHOSTIF) return("abufVgaacqToHostif");
	else if (tix == BBUFLWIRACQTOHOSTIF) return("bbufLwiracqToHostif");
	else if (tix == BBUFVGAACQTOHOSTIF) return("bbufVgaacqToHostif");

	return("");
};

void VecWMsddZedbBuffer::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {CMDRETTOHOSTIF,HOSTIFTOCMDINV,ABUFLWIRACQTOHOSTIF,ABUFVGAACQTOHOSTIF,BBUFLWIRACQTOHOSTIF,BBUFVGAACQTOHOSTIF};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};


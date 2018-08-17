/**
  * \file UntMsddBss3_vecs.cpp
  * Digilent Basys3 unit vectors (implementation)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#include "UntMsddBss3_vecs.h"

/******************************************************************************
 namespace VecVMsddBss3Controller
 ******************************************************************************/

utinyint VecVMsddBss3Controller::getTix(
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

string VecVMsddBss3Controller::getSref(
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

void VecVMsddBss3Controller::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {ADXL,ALIGN,LED,LWIRACQ,LWIRIF,SERVO,STATE,TKCLKSRC,TRIGGER,VGAACQ};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};

/******************************************************************************
 namespace VecVMsddBss3State
 ******************************************************************************/

utinyint VecVMsddBss3State::getTix(
			const string& sref
		) {
	string s = StrMod::lc(sref);

	if (s == "nc") return NC;
	else if (s == "ready") return READY;
	else if (s == "active") return ACTIVE;

	return(0);
};

string VecVMsddBss3State::getSref(
			const utinyint tix
		) {
	if (tix == NC) return("nc");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("active");

	return("");
};

string VecVMsddBss3State::getTitle(
			const utinyint tix
		) {
	if (tix == NC) return("offline");
	else if (tix == READY) return("ready");
	else if (tix == ACTIVE) return("acquisition running");

	return("");
};

void VecVMsddBss3State::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {NC,READY,ACTIVE};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getTitle(*it));
};

/******************************************************************************
 namespace VecWMsddBss3Buffer
 ******************************************************************************/

utinyint VecWMsddBss3Buffer::getTix(
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

string VecWMsddBss3Buffer::getSref(
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

void VecWMsddBss3Buffer::fillFeed(
			Feed& feed
		) {
	feed.clear();

	std::set<utinyint> items = {CMDRETTOHOSTIF,HOSTIFTOCMDINV,ABUFLWIRACQTOHOSTIF,ABUFVGAACQTOHOSTIF,BBUFLWIRACQTOHOSTIF,BBUFVGAACQTOHOSTIF};

	for (auto it=items.begin();it!=items.end();it++) feed.appendIxSrefTitles(*it, getSref(*it), getSref(*it));
};


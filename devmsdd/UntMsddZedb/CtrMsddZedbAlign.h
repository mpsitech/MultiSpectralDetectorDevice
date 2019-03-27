/**
  * \file CtrMsddZedbAlign.h
  * align controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDZEDBALIGN_H
#define CTRMSDDZEDBALIGN_H

#include "Msdd.h"

#define VecVMsddZedbAlignCommand CtrMsddZedbAlign::VecVCommand

/**
	* CtrMsddZedbAlign
	*/
class CtrMsddZedbAlign : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddZedbAlignCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETSEQ = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddZedbAlign(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x02;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetSeq();
	void setSeq(const unsigned char* seq, const size_t seqlen);

};

#endif


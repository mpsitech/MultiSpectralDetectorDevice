/**
  * \file CtrMsddBss3Align.h
  * align controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#ifndef CTRMSDDBSS3ALIGN_H
#define CTRMSDDBSS3ALIGN_H

#include "Msdd.h"

#define VecVMsddBss3AlignCommand CtrMsddBss3Align::VecVCommand

/**
	* CtrMsddBss3Align
	*/
class CtrMsddBss3Align : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3AlignCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETSEQ = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddBss3Align(UntMsdd* unt);

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


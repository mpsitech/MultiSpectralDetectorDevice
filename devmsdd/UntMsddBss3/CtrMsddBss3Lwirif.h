/**
  * \file CtrMsddBss3Lwirif.h
  * lwirif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#ifndef CTRMSDDBSS3LWIRIF_H
#define CTRMSDDBSS3LWIRIF_H

#include "Msdd.h"

#define VecVMsddBss3LwirifCommand CtrMsddBss3Lwirif::VecVCommand

/**
	* CtrMsddBss3Lwirif
	*/
class CtrMsddBss3Lwirif : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3LwirifCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETRNG = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddBss3Lwirif(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x05;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetRng();
	void setRng(const bool rng);

};

#endif


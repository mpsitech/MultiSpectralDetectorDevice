/**
  * \file CtrMsddZedbLwirif.h
  * lwirif controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDZEDBLWIRIF_H
#define CTRMSDDZEDBLWIRIF_H

#include "Msdd.h"

#define VecVMsddZedbLwirifCommand CtrMsddZedbLwirif::VecVCommand

/**
	* CtrMsddZedbLwirif
	*/
class CtrMsddZedbLwirif : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddZedbLwirifCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETRNG = 0x00;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddZedbLwirif(UntMsdd* unt);

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


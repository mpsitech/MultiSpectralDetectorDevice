/**
  * \file CtrMsddZedbAdxl.h
  * adxl controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#ifndef CTRMSDDZEDBADXL_H
#define CTRMSDDZEDBADXL_H

#include "Msdd.h"

#define CmdMsddZedbAdxlGetAx CtrMsddZedbAdxl::CmdGetAx
#define CmdMsddZedbAdxlGetAy CtrMsddZedbAdxl::CmdGetAy
#define CmdMsddZedbAdxlGetAz CtrMsddZedbAdxl::CmdGetAz

#define VecVMsddZedbAdxlCommand CtrMsddZedbAdxl::VecVCommand

/**
	* CtrMsddZedbAdxl
	*/
class CtrMsddZedbAdxl : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddZedbAdxlCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint GETAX = 0x00;
		static const utinyint GETAY = 0x01;
		static const utinyint GETAZ = 0x02;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddZedbAdxl(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x01;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdGetAx();
	void getAx(smallint& ax);

	static Cmd* getNewCmdGetAy();
	void getAy(smallint& ay);

	static Cmd* getNewCmdGetAz();
	void getAz(smallint& az);

};

#endif


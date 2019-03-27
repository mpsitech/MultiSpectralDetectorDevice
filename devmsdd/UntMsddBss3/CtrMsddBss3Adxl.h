/**
  * \file CtrMsddBss3Adxl.h
  * adxl controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef CTRMSDDBSS3ADXL_H
#define CTRMSDDBSS3ADXL_H

#include "Msdd.h"

#define CmdMsddBss3AdxlGetAx CtrMsddBss3Adxl::CmdGetAx
#define CmdMsddBss3AdxlGetAy CtrMsddBss3Adxl::CmdGetAy
#define CmdMsddBss3AdxlGetAz CtrMsddBss3Adxl::CmdGetAz

#define VecVMsddBss3AdxlCommand CtrMsddBss3Adxl::VecVCommand

/**
	* CtrMsddBss3Adxl
	*/
class CtrMsddBss3Adxl : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3AdxlCommand)
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
	CtrMsddBss3Adxl(UntMsdd* unt);

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


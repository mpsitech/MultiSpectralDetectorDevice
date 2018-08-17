/**
  * \file CtrMsddBss3Led.h
  * led controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#ifndef CTRMSDDBSS3LED_H
#define CTRMSDDBSS3LED_H

#include "Msdd.h"

#define VecVMsddBss3LedCommand CtrMsddBss3Led::VecVCommand

/**
	* CtrMsddBss3Led
	*/
class CtrMsddBss3Led : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3LedCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETTON15 = 0x00;
		static const utinyint SETTON60 = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddBss3Led(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x03;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetTon15();
	void setTon15(const utinyint ton15);

	static Cmd* getNewCmdSetTon60();
	void setTon60(const utinyint ton60);

};

#endif


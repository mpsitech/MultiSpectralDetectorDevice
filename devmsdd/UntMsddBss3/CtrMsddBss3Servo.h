/**
  * \file CtrMsddBss3Servo.h
  * servo controller (declarations)
  * \author Alexander Wirthmueller
  * \date created: 26 Aug 2018
  * \date modified: 26 Aug 2018
  */

#ifndef CTRMSDDBSS3SERVO_H
#define CTRMSDDBSS3SERVO_H

#include "Msdd.h"

#define VecVMsddBss3ServoCommand CtrMsddBss3Servo::VecVCommand

/**
	* CtrMsddBss3Servo
	*/
class CtrMsddBss3Servo : public CtrMsdd {

public:
	/**
		* VecVCommand (full: VecVMsddBss3ServoCommand)
		*/
	class VecVCommand {

	public:
		static const utinyint SETTHETA = 0x00;
		static const utinyint SETPHI = 0x01;

		static utinyint getTix(const string& sref);
		static string getSref(const utinyint tix);

		static void fillFeed(Feed& feed);
	};

public:
	CtrMsddBss3Servo(UntMsdd* unt);

public:
	static const utinyint tixVController = 0x06;

public:
	static utinyint getTixVCommandBySref(const string& sref);
	static string getSrefByTixVCommand(const utinyint tixVCommand);
	static void fillFeedFCommand(Feed& feed);

	static Cmd* getNewCmd(const utinyint tixVCommand);

	static Cmd* getNewCmdSetTheta();
	void setTheta(const smallint theta);

	static Cmd* getNewCmdSetPhi();
	void setPhi(const smallint phi);

};

#endif


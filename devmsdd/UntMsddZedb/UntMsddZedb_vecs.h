/**
  * \file UntMsddZedb_vecs.h
  * ZedBoard unit vectors (declarations)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#ifndef UNTMSDDZEDB_VECS_H
#define UNTMSDDZEDB_VECS_H

#include <sbecore/Xmlio.h>

using namespace Xmlio;

/**
	* VecVMsddZedbController
	*/
namespace VecVMsddZedbController {
	const utinyint ADXL = 0x01;
	const utinyint ALIGN = 0x02;
	const utinyint LED = 0x03;
	const utinyint LWIRACQ = 0x04;
	const utinyint LWIRIF = 0x05;
	const utinyint SERVO = 0x06;
	const utinyint STATE = 0x07;
	const utinyint TKCLKSRC = 0x08;
	const utinyint TRIGGER = 0x09;
	const utinyint VGAACQ = 0x0A;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecVMsddZedbState
	*/
namespace VecVMsddZedbState {
	const utinyint NC = 0x00;
	const utinyint READY = 0x01;
	const utinyint ACTIVE = 0x02;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	string getTitle(const utinyint tix);

	void fillFeed(Feed& feed);
};

/**
	* VecWMsddZedbBuffer
	*/
namespace VecWMsddZedbBuffer {
	const utinyint CMDRETTOHOSTIF = 0x01;
	const utinyint HOSTIFTOCMDINV = 0x02;
	const utinyint ABUFLWIRACQTOHOSTIF = 0x04;
	const utinyint ABUFVGAACQTOHOSTIF = 0x08;
	const utinyint BBUFLWIRACQTOHOSTIF = 0x10;
	const utinyint BBUFVGAACQTOHOSTIF = 0x20;

	utinyint getTix(const string& sref);
	string getSref(const utinyint tix);

	void fillFeed(Feed& feed);
};

#endif


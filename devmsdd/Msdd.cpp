/**
  * \file Msdd.cpp
  * Msdd global functionality and unit/controller exchange (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "Msdd.h"

/******************************************************************************
 class UntMsdd
 ******************************************************************************/

UntMsdd::UntMsdd()
		:
			mAccess("mAccess", "UntMsdd", "UntMsdd")
		{
	initdone = false;;

	txburst = false;
	rxtxdump = false;

	Nretry = 0;
	to = 0;

	rxbuf = NULL;
	txbuf = NULL;
};

UntMsdd::~UntMsdd() {
	if (rxbuf) delete[] rxbuf;
	if (txbuf) delete[] txbuf;

	mAccess.lock("UntMsdd", "~UntMsdd");
	mAccess.unlock("UntMsdd", "~UntMsdd");
};

void UntMsdd::lockAccess(
			const string& who
		) {
	mAccess.lock(who);
};

void UntMsdd::unlockAccess(
			const string& who
		) {
	mAccess.unlock(who);
};

void UntMsdd::reset() {
	txbuf[0] = 0xFF;
	tx(txbuf, 1);
};

bool UntMsdd::runBufxf(
			Bufxf* bufxf
		) {
	bool success = false;

	timespec deltat;

	// single try: invoke status command on failure
	if (bufxf->writeNotRead) success = runBufxfToBuf(bufxf);
	else success = runBufxfFromBuf(bufxf);

	if (!success) {
		// wait for FPGA system to time out (10ms+)
		deltat.tv_sec = 0;
		deltat.tv_nsec = 11 * 1000000;

		nanosleep(&deltat, NULL);
	};

	return success;
};

bool UntMsdd::runBufxfFromBuf(
			Bufxf* bufxf
		) {
	bool success = false;

	if (!initdone) return false;
	lockAccess("runBufxfFromBuf");

	Crc crc(0x8005, false);

	flush();

	setBuffer(bufxf->tixWBuffer);
	setController(0x00);
	setCommand(0x00);
	setLength(bufxf->reqlen+2);

	crc.reset();
	crc.includeBytes(txbuf, 1+1+1+2);
	crc.finalize();
	setCrc(crc.crc);

	success = tx(txbuf, 1+1+1+2+2);

	if (success) success = rx(bufxf->data, bufxf->reqlen+2);

	if (success) bufxf->ptr = bufxf->reqlen;

	if (success) {
		// received CRC bytes are bit-inverted
		bufxf->data[bufxf->reqlen] = ~(bufxf->data[bufxf->reqlen]);
		bufxf->data[bufxf->reqlen+1] = ~(bufxf->data[bufxf->reqlen+1]);

		crc.reset();
		crc.includeBytes(bufxf->data, bufxf->reqlen+2);
		crc.finalize();

		success = (crc.crc == 0x0000);
	};

	unlockAccess("runBufxfFromBuf");

	return success;
};

bool UntMsdd::runBufxfToBuf(
			Bufxf* bufxf
		) {
	bool success = false;

	if (!initdone) return false;
	lockAccess("runBufxfToBuf");

	Crc crc(0x8005, false);

	flush();

	setBuffer(bufxf->tixWBuffer);
	setController(0x00);
	setCommand(0x00);
	setLength(bufxf->reqlen+2);

	crc.reset();
	crc.includeBytes(txbuf, 1+1+1+2);
	crc.finalize();
	setCrc(crc.crc);

	if (txburst) {
		memcpy(bufxf->data, txbuf, 1+1+1+2);
		
		crc.reset();
		crc.includeBytes(&(bufxf->data[7]), bufxf->reqlen);
		crc.finalize();
		setCrc(crc.crc, &(bufxf->data[7+bufxf->reqlen]));

		success = tx(bufxf->data, 1+1+1+2+2 + bufxf->reqlen+2);

	} else {
		success = tx(txbuf, 1+1+1+2+2);

		if (success) {
			crc.reset();
			crc.includeBytes(bufxf->data, bufxf->reqlen);
			crc.finalize();
			setCrc(crc.crc, &(bufxf->data[bufxf->reqlen]));

			success = tx(bufxf->data, bufxf->reqlen+2);
		};
	};

	if (success) success = rx(rxbuf, 2); // expect CRC of empty buffer (~0x0000 = 0xFFFF)

	if (success) success = ((rxbuf[0] == 0xFF) && (rxbuf[1] == 0xFF));

	unlockAccess("runBufxfToBuf");

	return success;
};

bool UntMsdd::runCmd(
			Cmd* cmd
		) {
	bool success = false;

	timespec deltat;

	if (!initdone) return false;
	lockAccess("runCmd");

	for (unsigned int i=0;i<Nretry;i++) {
		if (cmd->parsInv.empty() && !cmd->parsRet.empty()) success = runCmdVoidToRet(cmd);
		else success = runCmdInvToVoid(cmd); // allow voidToVoid as well

		if (success) break;

		// wait for FPGA system to time out (10ms+)
		deltat.tv_sec = 0;
		deltat.tv_nsec = 11 * 1000000;

		nanosleep(&deltat, NULL);
	};

	unlockAccess("runCmd");

	return success;
};

bool UntMsdd::runCmdInvToVoid(
			Cmd* cmd
		) {
	bool success;

	unsigned char* buf = NULL;
	size_t buflen;

	Crc crc(0x8005, false);

	flush();

	setBuffer(0x02); // hostifToCmdinv
	setController(cmd->tixVController);
	setCommand(cmd->tixVCommand);
	setLength(cmd->getInvBuflen()+2);

	crc.reset();
	crc.includeBytes(txbuf, 1+1+1+2);
	crc.finalize();
	setCrc(crc.crc);

	cmd->parsInvToBuf(&buf, buflen);
	if (buf) {
		crc.reset();
		crc.includeBytes(buf, cmd->getInvBuflen());
		crc.finalize();
	};

	if (txburst) {
		if (buf) memcpy(&(txbuf[7]), buf, buflen);
		setCrc(crc.crc, &(txbuf[7+cmd->getInvBuflen()]));

		success = tx(txbuf, 1+1+1+2+2 + cmd->getInvBuflen()+2);

	} else {
		success = tx(txbuf, 1+1+1+2+2);

		if (success) {
			if (buf) memcpy(txbuf, buf, buflen);
			setCrc(crc.crc, &(txbuf[cmd->getInvBuflen()]));

			success = tx(txbuf, cmd->getInvBuflen()+2);
		};
	};

	if (success) success = rx(rxbuf, 2); // expect CRC of empty buffer (~0x0000 = 0xFFFF)

	if (success) success = ((rxbuf[0] == 0xFF) && (rxbuf[1] == 0xFF));

	if (buf) delete[] buf;

	return success;
};

bool UntMsdd::runCmdVoidToRet(
			Cmd* cmd
		) {
	bool success;

	Crc crc(0x8005, false);

	flush();

	setBuffer(0x01); // cmdretToHostif
	setController(cmd->tixVController);
	setCommand(cmd->tixVCommand);
	setLength(cmd->getRetBuflen()+2);

	crc.reset();
	crc.includeBytes(txbuf, 1+1+1+2);
	crc.finalize();
	setCrc(crc.crc);

	success = tx(txbuf, 1+1+1+2+2);

	if (success) success = rx(rxbuf, cmd->getRetBuflen()+2);

	if (success) {
		// received CRC bytes are bit-inverted
		rxbuf[cmd->getRetBuflen()] = ~(rxbuf[cmd->getRetBuflen()]);
		rxbuf[cmd->getRetBuflen()+1] = ~(rxbuf[cmd->getRetBuflen()+1]);

		crc.reset();
		crc.includeBytes(rxbuf, cmd->getRetBuflen()+2);
		crc.finalize();

		success = (crc.crc == 0x0000);
	};

	if (success) cmd->bufToParsRet(rxbuf, cmd->getRetBuflen());

	return success;
};

void UntMsdd::setBuffer(
			const utinyint tixWBuffer
		) {
	// txbuf byte 0
	txbuf[0] = tixWBuffer;
};

void UntMsdd::setController(
			const utinyint tixVController
		) {
	// txbuf byte 1
	txbuf[1] = tixVController;
};

void UntMsdd::setCommand(
			const utinyint tixVCommand
		) {
	// txbuf byte 2
	txbuf[2] = tixVCommand;
};

void UntMsdd::setLength(
			const size_t length
		) {
	// txbuf bytes 3..4
	unsigned short _length = length;

	unsigned char* ptr = (unsigned char*) &_length;

	const size_t ofs = 3;

	if (Dbe::bigendian()) {
		txbuf[ofs] = ptr[0];
		txbuf[ofs+1] = ptr[1];
	} else {
		txbuf[ofs] = ptr[1];
		txbuf[ofs+1] = ptr[0];
	};
};

void UntMsdd::setCrc(
			const usmallint crc
			, unsigned char* ptr
		) {
	// txbuf bytes 5..6 by default
	if (!ptr) ptr = &(txbuf[5]);

	unsigned char* crcptr = (unsigned char*) &crc;

	if (Dbe::bigendian()) {
		ptr[0] = crcptr[0];
		ptr[1] = crcptr[1];
	} else {
		ptr[0] = crcptr[1];
		ptr[1] = crcptr[0];
	};
};

bool UntMsdd::rx(
			unsigned char* buf
			, const size_t reqlen
		) {
	return false;
};

bool UntMsdd::tx(
			unsigned char* buf
			, const size_t reqlen
		) {
	return false;
};

void UntMsdd::flush() {
};

utinyint UntMsdd::getTixVControllerBySref(
			const string& sref
		) {
	return 0;
};

string UntMsdd::getSrefByTixVController(
			const utinyint tixVController
		) {
	return("");
};

void UntMsdd::fillFeedFController(
			Feed& feed
		) {
};

utinyint UntMsdd::getTixWBufferBySref(
			const string& sref
		) {
	return 0;
};

string UntMsdd::getSrefByTixWBuffer(
			const utinyint tixWBuffer
		) {
	return("");
};

void UntMsdd::fillFeedFBuffer(
			Feed& feed
		) {
};

utinyint UntMsdd::getTixVCommandBySref(
			const utinyint tixVController
			, const string& sref
		) {
	return 0;
};

string UntMsdd::getSrefByTixVCommand(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	return("");
};

void UntMsdd::fillFeedFCommand(
			const utinyint tixVController
			, Feed& feed
		) {
};

Bufxf* UntMsdd::getNewBufxf(
			const utinyint tixWBuffer
			, const size_t reqlen
		) {
	return NULL;
};

Cmd* UntMsdd::getNewCmd(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	return NULL;
};

string UntMsdd::getCmdInvTemplate(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string retval;

	Cmd* cmd = getNewCmd(tixVController, tixVCommand);

	if (cmd) {
		retval = getSrefByTixVController(tixVController);
		if (retval != "") retval += ".";
		retval += getSrefByTixVCommand(tixVController, tixVCommand);

		retval += "(" + cmd->parsInvToTemplate() + ")";

		delete cmd;
	};

	return retval;
};

/******************************************************************************
 class CtrMsdd
 ******************************************************************************/

CtrMsdd::CtrMsdd(
			UntMsdd* unt
		) {
	this->unt = unt;
};

CtrMsdd::~CtrMsdd() {
};


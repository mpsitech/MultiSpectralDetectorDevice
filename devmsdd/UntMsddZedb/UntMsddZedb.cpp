/**
  * \file UntMsddZedb.cpp
  * ZedBoard unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 12 Aug 2018
  * \date modified: 12 Aug 2018
  */

#include "UntMsddZedb.h"

UntMsddZedb::UntMsddZedb() : UntMsdd() {
	// IP constructor --- IBEGIN
	fd = 0;
	// IP constructor --- IEND
};

UntMsddZedb::~UntMsddZedb() {
	if (initdone) term();
};

// IP init.hdr --- RBEGIN
void UntMsddZedb::init(
			const string& _path
		) {
// IP init.hdr --- REND
	adxl = new CtrMsddZedbAdxl(this);
	align = new CtrMsddZedbAlign(this);
	led = new CtrMsddZedbLed(this);
	lwiracq = new CtrMsddZedbLwiracq(this);
	lwirif = new CtrMsddZedbLwirif(this);
	servo = new CtrMsddZedbServo(this);
	state = new CtrMsddZedbState(this);
	tkclksrc = new CtrMsddZedbTkclksrc(this);
	trigger = new CtrMsddZedbTrigger(this);
	vgaacq = new CtrMsddZedbVgaacq(this);

	// IP init.cust --- IBEGIN
	path = _path;

	Nretry = 5;

	const size_t sizeRxbuf = 1024;
	rxbuf = new unsigned char[sizeRxbuf];

	const size_t sizeTxbuf = 1024;
	txbuf = new unsigned char[sizeTxbuf];

	// open character device
	fd = open(path.c_str(), O_RDWR);
	if (fd == -1) {
		fd = 0;
		throw DbeException("error opening device " + path + "");
	};
	// IP init.cust --- IEND

	initdone = true;
};

void UntMsddZedb::term() {
	// IP term.cust --- IBEGIN
	if (fd) {
		close(fd);
		fd = 0;
	};
	// IP term.cust --- IEND

	delete adxl;
	delete align;
	delete led;
	delete lwiracq;
	delete lwirif;
	delete servo;
	delete state;
	delete tkclksrc;
	delete trigger;
	delete vgaacq;

	initdone = false;
};

bool UntMsddZedb::rx(
			unsigned char* buf
			, const size_t reqlen
		) {
	bool retval = (reqlen == 0);

	// IP rx --- IBEGIN
	if (reqlen != 0) {
		fd_set fds;
		timeval timeout;
		int s;

		size_t nleft;
		int n;

		int en;

		FD_ZERO(&fds);
		FD_SET(fd, &fds);

		timeout.tv_sec = 0;
		timeout.tv_usec = to;

		if (rxtxdump) cout << "rx ";

		nleft = reqlen;
		en = 0;

		while (nleft > 0) {
			s = select(fd+1, &fds, NULL, NULL, &timeout);

			if (s > 0) {
				n = read(fd, &(buf[reqlen-nleft]), nleft);

				if (n >= 0) nleft -= n;
				else {
					en = errno;
					break;
				};

			} else if (s == 0) {
				en = ETIMEDOUT;
				break;
			} else {
				en = errno;
			};
		};

		retval = (nleft == 0);

		if (rxtxdump) {
			if (nleft == 0) cout << "0x" << Dbe::bufToHex(buf, reqlen, true) << endl;
			else cout << string(strerror(en)) << endl;
		};
	};
	// IP rx --- IEND

	return retval;
};

bool UntMsddZedb::tx(
			unsigned char* buf
			, const size_t reqlen
		) {
	bool retval = (reqlen == 0);

	// IP tx --- IBEGIN
	if (reqlen != 0) {
		size_t nleft;
		int n;

		if (rxtxdump) cout << "tx ";

		nleft = reqlen;
		n = 0;

		while (nleft > 0) {
			n = write(fd, &(buf[reqlen-nleft]), nleft);

			if (n >= 0) nleft -= n;
			else break;
		};

		retval = (nleft == 0);

		if (rxtxdump) {
			if (nleft == 0) cout << "0x" << Dbe::bufToHex(buf, reqlen, true) << endl;
			else cout << string(strerror(n)) << endl;
		};
	};
	// IP tx --- IEND

	return retval;
};

void UntMsddZedb::flush() {
	// IP flush --- INSERT
};

utinyint UntMsddZedb::getTixVControllerBySref(
			const string& sref
		) {
	return VecVMsddZedbController::getTix(sref);
};

string UntMsddZedb::getSrefByTixVController(
			const utinyint tixVController
		) {
	return VecVMsddZedbController::getSref(tixVController);
};

void UntMsddZedb::fillFeedFController(
			Feed& feed
		) {
	VecVMsddZedbController::fillFeed(feed);
};

utinyint UntMsddZedb::getTixWBufferBySref(
			const string& sref
		) {
	return VecWMsddZedbBuffer::getTix(sref);
};

string UntMsddZedb::getSrefByTixWBuffer(
			const utinyint tixWBuffer
		) {
	return VecWMsddZedbBuffer::getSref(tixWBuffer);
};

void UntMsddZedb::fillFeedFBuffer(
			Feed& feed
		) {
	VecWMsddZedbBuffer::fillFeed(feed);
};

utinyint UntMsddZedb::getTixVCommandBySref(
			const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (tixVController == VecVMsddZedbController::ADXL) tixVCommand = VecVMsddZedbAdxlCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::ALIGN) tixVCommand = VecVMsddZedbAlignCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::LED) tixVCommand = VecVMsddZedbLedCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::LWIRACQ) tixVCommand = VecVMsddZedbLwiracqCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::LWIRIF) tixVCommand = VecVMsddZedbLwirifCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::SERVO) tixVCommand = VecVMsddZedbServoCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::STATE) tixVCommand = VecVMsddZedbStateCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::TKCLKSRC) tixVCommand = VecVMsddZedbTkclksrcCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::TRIGGER) tixVCommand = VecVMsddZedbTriggerCommand::getTix(sref);
	else if (tixVController == VecVMsddZedbController::VGAACQ) tixVCommand = VecVMsddZedbVgaacqCommand::getTix(sref);

	return tixVCommand;
};

string UntMsddZedb::getSrefByTixVCommand(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (tixVController == VecVMsddZedbController::ADXL) sref = VecVMsddZedbAdxlCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::ALIGN) sref = VecVMsddZedbAlignCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::LED) sref = VecVMsddZedbLedCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::LWIRACQ) sref = VecVMsddZedbLwiracqCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::LWIRIF) sref = VecVMsddZedbLwirifCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::SERVO) sref = VecVMsddZedbServoCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::STATE) sref = VecVMsddZedbStateCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::TKCLKSRC) sref = VecVMsddZedbTkclksrcCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::TRIGGER) sref = VecVMsddZedbTriggerCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddZedbController::VGAACQ) sref = VecVMsddZedbVgaacqCommand::getSref(tixVCommand);

	return sref;
};

void UntMsddZedb::fillFeedFCommand(
			const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (tixVController == VecVMsddZedbController::ADXL) VecVMsddZedbAdxlCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::ALIGN) VecVMsddZedbAlignCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::LED) VecVMsddZedbLedCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::LWIRACQ) VecVMsddZedbLwiracqCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::LWIRIF) VecVMsddZedbLwirifCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::SERVO) VecVMsddZedbServoCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::STATE) VecVMsddZedbStateCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::TKCLKSRC) VecVMsddZedbTkclksrcCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::TRIGGER) VecVMsddZedbTriggerCommand::fillFeed(feed);
	else if (tixVController == VecVMsddZedbController::VGAACQ) VecVMsddZedbVgaacqCommand::fillFeed(feed);
};

Bufxf* UntMsddZedb::getNewBufxf(
			const utinyint tixWBuffer
			, const size_t reqlen
		) {
	Bufxf* bufxf = NULL;

	if (tixWBuffer == VecWMsddZedbBuffer::ABUFLWIRACQTOHOSTIF) bufxf = getNewBufxfAbufFromLwiracq(reqlen);
	else if (tixWBuffer == VecWMsddZedbBuffer::ABUFVGAACQTOHOSTIF) bufxf = getNewBufxfAbufFromVgaacq(reqlen);
	else if (tixWBuffer == VecWMsddZedbBuffer::BBUFLWIRACQTOHOSTIF) bufxf = getNewBufxfBbufFromLwiracq(reqlen);
	else if (tixWBuffer == VecWMsddZedbBuffer::BBUFVGAACQTOHOSTIF) bufxf = getNewBufxfBbufFromVgaacq(reqlen);

	return bufxf;
};

Cmd* UntMsddZedb::getNewCmd(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVController == VecVMsddZedbController::ADXL) cmd = CtrMsddZedbAdxl::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::ALIGN) cmd = CtrMsddZedbAlign::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::LED) cmd = CtrMsddZedbLed::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::LWIRACQ) cmd = CtrMsddZedbLwiracq::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::LWIRIF) cmd = CtrMsddZedbLwirif::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::SERVO) cmd = CtrMsddZedbServo::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::STATE) cmd = CtrMsddZedbState::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::TKCLKSRC) cmd = CtrMsddZedbTkclksrc::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::TRIGGER) cmd = CtrMsddZedbTrigger::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddZedbController::VGAACQ) cmd = CtrMsddZedbVgaacq::getNewCmd(tixVCommand);

	return cmd;
};

Bufxf* UntMsddZedb::getNewBufxfAbufFromLwiracq(
			const size_t reqlen
		) {
	return(new Bufxf(VecWMsddZedbBuffer::ABUFLWIRACQTOHOSTIF, false, reqlen, 0, 2));
};

void UntMsddZedb::readAbufFromLwiracq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfAbufFromLwiracq(reqlen);

	if (runBufxf(bufxf)) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		data = NULL;
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readAbufFromLwiracq");
	};

	delete bufxf;
};

Bufxf* UntMsddZedb::getNewBufxfAbufFromVgaacq(
			const size_t reqlen
		) {
	return(new Bufxf(VecWMsddZedbBuffer::ABUFVGAACQTOHOSTIF, false, reqlen, 0, 2));
};

void UntMsddZedb::readAbufFromVgaacq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfAbufFromVgaacq(reqlen);

	if (runBufxf(bufxf)) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		data = NULL;
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readAbufFromVgaacq");
	};

	delete bufxf;
};

Bufxf* UntMsddZedb::getNewBufxfBbufFromLwiracq(
			const size_t reqlen
		) {
	return(new Bufxf(VecWMsddZedbBuffer::BBUFLWIRACQTOHOSTIF, false, reqlen, 0, 2));
};

void UntMsddZedb::readBbufFromLwiracq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfBbufFromLwiracq(reqlen);

	if (runBufxf(bufxf)) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		data = NULL;
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readBbufFromLwiracq");
	};

	delete bufxf;
};

Bufxf* UntMsddZedb::getNewBufxfBbufFromVgaacq(
			const size_t reqlen
		) {
	return(new Bufxf(VecWMsddZedbBuffer::BBUFVGAACQTOHOSTIF, false, reqlen, 0, 2));
};

void UntMsddZedb::readBbufFromVgaacq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfBbufFromVgaacq(reqlen);

	if (runBufxf(bufxf)) {
		data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		data = NULL;
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readBbufFromVgaacq");
	};

	delete bufxf;
};




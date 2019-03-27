/**
  * \file UntMsddBss3.cpp
  * Digilent Basys3 unit (implementation)
  * \author Alexander Wirthmueller
  * \date created: 18 Oct 2018
  * \date modified: 18 Oct 2018
  */

#include "UntMsddBss3.h"

UntMsddBss3::UntMsddBss3() : UntMsdd() {
	// IP constructor --- IBEGIN
	bps = 0;

	fd = 0;
	// IP constructor --- IEND
};

UntMsddBss3::~UntMsddBss3() {
	if (initdone) term();
};

// IP init.hdr --- RBEGIN
void UntMsddBss3::init(
			const string& _path
			, const unsigned int _bps
		) {
// IP init.hdr --- REND
	adxl = new CtrMsddBss3Adxl(this);
	align = new CtrMsddBss3Align(this);
	led = new CtrMsddBss3Led(this);
	lwiracq = new CtrMsddBss3Lwiracq(this);
	lwirif = new CtrMsddBss3Lwirif(this);
	servo = new CtrMsddBss3Servo(this);
	state = new CtrMsddBss3State(this);
	tkclksrc = new CtrMsddBss3Tkclksrc(this);
	trigger = new CtrMsddBss3Trigger(this);
	vgaacq = new CtrMsddBss3Vgaacq(this);

	// IP init.cust --- IBEGIN
	path = _path;
	bps = _bps;

	Nretry = 50;
	to = 25000; // in us

	const size_t sizeRxbuf = 1024;
	rxbuf = new unsigned char[sizeRxbuf];

	const size_t sizeTxbuf = 1024;
	txbuf = new unsigned char[sizeTxbuf];

#ifdef __linux__
	// open character device
	fd = open(path.c_str(), O_RDWR | O_NOCTTY);
	if (fd == -1) {
		fd = 0;
		throw DbeException("error opening device " + path + "");
	};
	
	termios term;
	serial_struct ss;

	memset(&term, 0, sizeof(term));
	if (tcgetattr(fd, &term) != 0) throw DbeException("error getting terminal attributes");

	// 38400 8N1, no flow control, read blocking with 100ms timeout
	cfmakeraw(&term);

	cfsetispeed(&term, B38400);
	cfsetospeed(&term, B38400);

	term.c_iflag = 0;
	term.c_oflag = 0;

	term.c_cflag &= ~(CRTSCTS | CSIZE | CSTOPB);
	term.c_cflag |= (CLOCAL | CREAD | CS8);

	//term.c_lflag = 0;

	term.c_cc[VMIN] = 1;
	term.c_cc[VTIME] = 1;

	tcflush(fd, TCIOFLUSH);
	if (tcsetattr(fd, TCSANOW, &term) != 0) throw DbeException("error setting terminal attributes");

	if (ioctl(fd, TIOCGSERIAL, &ss) == -1) throw DbeException("error getting serial struct");

	//cout << "ss.baud_base=" << ss.baud_base << endl; // should be 60'000'000

	ss.flags &= ~ASYNC_SPD_MASK;
	ss.flags |= ASYNC_SPD_CUST;

	int div = ss.baud_base/bps; // down to 12 or up to 5MHz works
	ss.custom_divisor = div; // set to 10Mbps or 1MByte/s ; for 640*480*14/8=537.6kByte/s FLIR => more than 1 image per second

	if (ioctl(fd, TIOCSSERIAL, &ss) == -1) throw DbeException("error setting serial struct");
#endif
	// IP init.cust --- IEND

	initdone = true;
};

void UntMsddBss3::term() {
	// IP term.cust --- IBEGIN
#ifdef __linux__
	if (fd) {
		close(fd);
		fd = 0;
	};
#endif
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

bool UntMsddBss3::rx(
			unsigned char* buf
			, const size_t reqlen
		) {
	bool retval = (reqlen == 0);

	// IP rx --- IBEGIN
#ifdef __linux__
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
#endif
	// IP rx --- IEND

	return retval;
};

bool UntMsddBss3::tx(
			unsigned char* buf
			, const size_t reqlen
		) {
	bool retval = (reqlen == 0);

	// IP tx --- IBEGIN
#ifdef __linux__
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
#endif
	// IP tx --- IEND

	return retval;
};

void UntMsddBss3::flush() {
	tcflush(fd, TCIOFLUSH); // IP flush --- ILINE
};

utinyint UntMsddBss3::getTixVControllerBySref(
			const string& sref
		) {
	return VecVMsddBss3Controller::getTix(sref);
};

string UntMsddBss3::getSrefByTixVController(
			const utinyint tixVController
		) {
	return VecVMsddBss3Controller::getSref(tixVController);
};

void UntMsddBss3::fillFeedFController(
			Feed& feed
		) {
	VecVMsddBss3Controller::fillFeed(feed);
};

utinyint UntMsddBss3::getTixWBufferBySref(
			const string& sref
		) {
	return VecWMsddBss3Buffer::getTix(sref);
};

string UntMsddBss3::getSrefByTixWBuffer(
			const utinyint tixWBuffer
		) {
	return VecWMsddBss3Buffer::getSref(tixWBuffer);
};

void UntMsddBss3::fillFeedFBuffer(
			Feed& feed
		) {
	VecWMsddBss3Buffer::fillFeed(feed);
};

utinyint UntMsddBss3::getTixVCommandBySref(
			const utinyint tixVController
			, const string& sref
		) {
	utinyint tixVCommand = 0;

	if (tixVController == VecVMsddBss3Controller::ADXL) tixVCommand = VecVMsddBss3AdxlCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::ALIGN) tixVCommand = VecVMsddBss3AlignCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::LED) tixVCommand = VecVMsddBss3LedCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::LWIRACQ) tixVCommand = VecVMsddBss3LwiracqCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::LWIRIF) tixVCommand = VecVMsddBss3LwirifCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::SERVO) tixVCommand = VecVMsddBss3ServoCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::STATE) tixVCommand = VecVMsddBss3StateCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::TKCLKSRC) tixVCommand = VecVMsddBss3TkclksrcCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::TRIGGER) tixVCommand = VecVMsddBss3TriggerCommand::getTix(sref);
	else if (tixVController == VecVMsddBss3Controller::VGAACQ) tixVCommand = VecVMsddBss3VgaacqCommand::getTix(sref);

	return tixVCommand;
};

string UntMsddBss3::getSrefByTixVCommand(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	string sref;

	if (tixVController == VecVMsddBss3Controller::ADXL) sref = VecVMsddBss3AdxlCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::ALIGN) sref = VecVMsddBss3AlignCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::LED) sref = VecVMsddBss3LedCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::LWIRACQ) sref = VecVMsddBss3LwiracqCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::LWIRIF) sref = VecVMsddBss3LwirifCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::SERVO) sref = VecVMsddBss3ServoCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::STATE) sref = VecVMsddBss3StateCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::TKCLKSRC) sref = VecVMsddBss3TkclksrcCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::TRIGGER) sref = VecVMsddBss3TriggerCommand::getSref(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::VGAACQ) sref = VecVMsddBss3VgaacqCommand::getSref(tixVCommand);

	return sref;
};

void UntMsddBss3::fillFeedFCommand(
			const utinyint tixVController
			, Feed& feed
		) {
	feed.clear();

	if (tixVController == VecVMsddBss3Controller::ADXL) VecVMsddBss3AdxlCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::ALIGN) VecVMsddBss3AlignCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::LED) VecVMsddBss3LedCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::LWIRACQ) VecVMsddBss3LwiracqCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::LWIRIF) VecVMsddBss3LwirifCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::SERVO) VecVMsddBss3ServoCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::STATE) VecVMsddBss3StateCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::TKCLKSRC) VecVMsddBss3TkclksrcCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::TRIGGER) VecVMsddBss3TriggerCommand::fillFeed(feed);
	else if (tixVController == VecVMsddBss3Controller::VGAACQ) VecVMsddBss3VgaacqCommand::fillFeed(feed);
};

Bufxf* UntMsddBss3::getNewBufxf(
			const utinyint tixWBuffer
			, const size_t reqlen
			, unsigned char* buf
		) {
	Bufxf* bufxf = NULL;

	if (tixWBuffer == VecWMsddBss3Buffer::ABUFLWIRACQTOHOSTIF) bufxf = getNewBufxfAbufFromLwiracq(reqlen, buf);
	else if (tixWBuffer == VecWMsddBss3Buffer::ABUFVGAACQTOHOSTIF) bufxf = getNewBufxfAbufFromVgaacq(reqlen, buf);
	else if (tixWBuffer == VecWMsddBss3Buffer::BBUFLWIRACQTOHOSTIF) bufxf = getNewBufxfBbufFromLwiracq(reqlen, buf);
	else if (tixWBuffer == VecWMsddBss3Buffer::BBUFVGAACQTOHOSTIF) bufxf = getNewBufxfBbufFromVgaacq(reqlen, buf);

	return bufxf;
};

Cmd* UntMsddBss3::getNewCmd(
			const utinyint tixVController
			, const utinyint tixVCommand
		) {
	Cmd* cmd = NULL;

	if (tixVController == VecVMsddBss3Controller::ADXL) cmd = CtrMsddBss3Adxl::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::ALIGN) cmd = CtrMsddBss3Align::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::LED) cmd = CtrMsddBss3Led::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::LWIRACQ) cmd = CtrMsddBss3Lwiracq::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::LWIRIF) cmd = CtrMsddBss3Lwirif::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::SERVO) cmd = CtrMsddBss3Servo::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::STATE) cmd = CtrMsddBss3State::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::TKCLKSRC) cmd = CtrMsddBss3Tkclksrc::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::TRIGGER) cmd = CtrMsddBss3Trigger::getNewCmd(tixVCommand);
	else if (tixVController == VecVMsddBss3Controller::VGAACQ) cmd = CtrMsddBss3Vgaacq::getNewCmd(tixVCommand);

	return cmd;
};

Bufxf* UntMsddBss3::getNewBufxfAbufFromLwiracq(
			const size_t reqlen
			, unsigned char* buf
		) {
	return(new Bufxf(VecWMsddBss3Buffer::ABUFLWIRACQTOHOSTIF, false, reqlen, 0, 2, buf));
};

void UntMsddBss3::readAbufFromLwiracq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfAbufFromLwiracq(reqlen, data);

	if (runBufxf(bufxf)) {
		if (!data) data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readAbufFromLwiracq");
	};

	delete bufxf;
};

Bufxf* UntMsddBss3::getNewBufxfAbufFromVgaacq(
			const size_t reqlen
			, unsigned char* buf
		) {
	return(new Bufxf(VecWMsddBss3Buffer::ABUFVGAACQTOHOSTIF, false, reqlen, 0, 2, buf));
};

void UntMsddBss3::readAbufFromVgaacq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfAbufFromVgaacq(reqlen, data);

	if (runBufxf(bufxf)) {
		if (!data) data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readAbufFromVgaacq");
	};

	delete bufxf;
};

Bufxf* UntMsddBss3::getNewBufxfBbufFromLwiracq(
			const size_t reqlen
			, unsigned char* buf
		) {
	return(new Bufxf(VecWMsddBss3Buffer::BBUFLWIRACQTOHOSTIF, false, reqlen, 0, 2, buf));
};

void UntMsddBss3::readBbufFromLwiracq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfBbufFromLwiracq(reqlen, data);

	if (runBufxf(bufxf)) {
		if (!data) data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readBbufFromLwiracq");
	};

	delete bufxf;
};

Bufxf* UntMsddBss3::getNewBufxfBbufFromVgaacq(
			const size_t reqlen
			, unsigned char* buf
		) {
	return(new Bufxf(VecWMsddBss3Buffer::BBUFVGAACQTOHOSTIF, false, reqlen, 0, 2, buf));
};

void UntMsddBss3::readBbufFromVgaacq(
			const size_t reqlen
			, unsigned char*& data
			, size_t& datalen
		) {
	Bufxf* bufxf = getNewBufxfBbufFromVgaacq(reqlen, data);

	if (runBufxf(bufxf)) {
		if (!data) data = bufxf->getReadData();
		datalen = bufxf->getReadDatalen();

	} else {
		datalen = 0;

		delete bufxf;
		throw DbeException("error running readBbufFromVgaacq");
	};

	delete bufxf;
};





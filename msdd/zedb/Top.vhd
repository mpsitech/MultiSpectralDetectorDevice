-- file Top.vhd
-- Top top_v1_0 top implementation
-- author Alexander Wirthmueller
-- date created: 18 Oct 2018
-- date modified: 18 Oct 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;
use work.Oled128x32_v1_0_lib.all;

entity Top is
	generic (
		fExtclk: natural range 1 to 1000000 := 100000;
		fMclk: natural range 1 to 1000000 := 50000
	);
	port (
		sw: in std_logic_vector(7 downto 0);
		gnd: out std_logic_vector(1 downto 0);
		JA: out std_logic_vector(7 downto 0);
		nxss: out std_logic;
		xsck: out std_logic;
		xmosi: out std_logic;
		xmiso: in std_logic;
		nass: out std_logic;
		asck: out std_logic;
		amosi: out std_logic;
		btnC: in std_logic;
		btnL: in std_logic;
		btnR: in std_logic;

		enRx: in std_logic;
		rx: in std_logic_vector(31 downto 0);
		strbRx: in std_logic;

		enTx: in std_logic;
		tx: out std_logic_vector(31 downto 0);
		strbTx: in std_logic;

		d60pwm: out std_logic;
		d15pwm: out std_logic;
		niss: out std_logic;
		isck: out std_logic;
		irxd: in std_logic;
		nirst: out std_logic;
		imclk: out std_logic;
		iscl: out std_logic;
		isda: inout std_logic;
		extclk: in std_logic;
		oledVdd: out std_logic;
		oledVbat: out std_logic;
		oledRes: out std_logic;
		oledDc: out std_logic;
		oledSclk: out std_logic;
		oledSdin: out std_logic;
		tpwm: out std_logic;
		ppwm: out std_logic;
		sgrn: out std_logic;
		sred: out std_logic;
		lmio: out std_logic_vector(1 downto 0);
		rmio: out std_logic_vector(1 downto 0);
		itxd: out std_logic
	);
end Top;

architecture Top of Top is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Adxl is
		generic (
			res: std_logic_vector(1 downto 0) := "01";
			rate: std_logic_vector(3 downto 0) := "1010";

			Tsmp: natural range 10 to 10000 := 100;
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			getAxAx: out std_logic_vector(15 downto 0);

			getAyAy: out std_logic_vector(15 downto 0);

			getAzAz: out std_logic_vector(15 downto 0);

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	component Align is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			reqInvSetSeq: in std_logic;
			ackInvSetSeq: out std_logic;

			setSeqLenSeq: in std_logic_vector(7 downto 0);
			setSeqSeq: in std_logic_vector(255 downto 0);

			trigrng: in std_logic;
			strbVisl: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic
		);
	end component;

	component Debounce_v1_0 is
		generic (
			tdead: natural range 1 to 10000 := 100
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			noisy: in std_logic;
			clean: out std_logic
		);
	end component;

	component Hostif is
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;
			commok: out std_logic;

			btnReset: in std_logic;
			reqReset: out std_logic;

			adxlGetAxAx: in std_logic_vector(15 downto 0);

			adxlGetAyAy: in std_logic_vector(15 downto 0);

			adxlGetAzAz: in std_logic_vector(15 downto 0);

			reqInvAlignSetSeq: out std_logic;
			ackInvAlignSetSeq: in std_logic;

			alignSetSeqLenSeq: out std_logic_vector(7 downto 0);
			alignSetSeqSeq: out std_logic_vector(255 downto 0);

			reqInvLedSetTon15: out std_logic;
			ackInvLedSetTon15: in std_logic;

			ledSetTon15Ton15: out std_logic_vector(7 downto 0);

			reqInvLedSetTon60: out std_logic;
			ackInvLedSetTon60: in std_logic;

			ledSetTon60Ton60: out std_logic_vector(7 downto 0);

			reqInvLwirifSetRng: out std_logic;
			ackInvLwirifSetRng: in std_logic;

			lwirifSetRngRng: out std_logic_vector(7 downto 0);

			reqInvLwiracqSetRng: out std_logic;
			ackInvLwiracqSetRng: in std_logic;

			lwiracqSetRngRng: out std_logic_vector(7 downto 0);

			lwiracqGetInfoTixVBufstate: in std_logic_vector(7 downto 0);
			lwiracqGetInfoTkst: in std_logic_vector(31 downto 0);
			lwiracqGetInfoMin: in std_logic_vector(15 downto 0);
			lwiracqGetInfoMax: in std_logic_vector(15 downto 0);

			reqInvServoSetTheta: out std_logic;
			ackInvServoSetTheta: in std_logic;

			servoSetThetaTheta: out std_logic_vector(15 downto 0);

			reqInvServoSetPhi: out std_logic;
			ackInvServoSetPhi: in std_logic;

			servoSetPhiPhi: out std_logic_vector(15 downto 0);

			stateGetTixVZedbState: in std_logic_vector(7 downto 0);

			tkclksrcGetTkstTkst: in std_logic_vector(31 downto 0);

			reqInvTkclksrcSetTkst: out std_logic;
			ackInvTkclksrcSetTkst: in std_logic;

			tkclksrcSetTkstTkst: out std_logic_vector(31 downto 0);

			reqInvTriggerSetRng: out std_logic;
			ackInvTriggerSetRng: in std_logic;

			triggerSetRngRng: out std_logic_vector(7 downto 0);
			triggerSetRngBtnNotTfrm: out std_logic_vector(7 downto 0);

			reqInvTriggerSetTdlyLwir: out std_logic;
			ackInvTriggerSetTdlyLwir: in std_logic;

			triggerSetTdlyLwirTdlyLwir: out std_logic_vector(15 downto 0);

			reqInvTriggerSetTdlyVisr: out std_logic;
			ackInvTriggerSetTdlyVisr: in std_logic;

			triggerSetTdlyVisrTdlyVisr: out std_logic_vector(15 downto 0);

			reqInvTriggerSetTfrm: out std_logic;
			ackInvTriggerSetTfrm: in std_logic;

			triggerSetTfrmTfrm: out std_logic_vector(15 downto 0);

			reqInvVgaacqSetRng: out std_logic;
			ackInvVgaacqSetRng: in std_logic;

			vgaacqSetRngRng: out std_logic_vector(7 downto 0);

			vgaacqGetInfoTixVBufstate: in std_logic_vector(7 downto 0);
			vgaacqGetInfoTkst: in std_logic_vector(31 downto 0);

			reqAbufFromLwiracq: out std_logic;

			reqBbufFromLwiracq: out std_logic;

			reqAbufFromVgaacq: out std_logic;

			ackAbufFromLwiracq: in std_logic;

			ackBbufFromLwiracq: in std_logic;

			ackAbufFromVgaacq: in std_logic;

			dneAbufFromLwiracq: out std_logic;

			dneBbufFromLwiracq: out std_logic;

			dneAbufFromVgaacq: out std_logic;

			avllenAbufFromLwiracq: in std_logic_vector(15 downto 0);
			avllenBbufFromLwiracq: in std_logic_vector(15 downto 0);
			avllenAbufFromVgaacq: in std_logic_vector(15 downto 0);

			dAbufFromLwiracq: in std_logic_vector(7 downto 0);

			dBbufFromLwiracq: in std_logic_vector(7 downto 0);

			dAbufFromVgaacq: in std_logic_vector(7 downto 0);

			strbDAbufFromLwiracq: out std_logic;

			strbDBbufFromLwiracq: out std_logic;

			strbDAbufFromVgaacq: out std_logic;

			reqBbufFromVgaacq: out std_logic;
			ackBbufFromVgaacq: in std_logic;
			dneBbufFromVgaacq: out std_logic;

			avllenBbufFromVgaacq: in std_logic_vector(15 downto 0);

			dBbufFromVgaacq: in std_logic_vector(7 downto 0);
			strbDBbufFromVgaacq: out std_logic;

			enRx: in std_logic;
			rx: in std_logic_vector(31 downto 0);
			strbRx: in std_logic;

			enTx: in std_logic;
			tx: out std_logic_vector(31 downto 0);
			strbTx: in std_logic;

			stateOp_dbg: out std_logic_vector(7 downto 0)
		);
	end component;

	component Led is
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			reqInvSetTon15: in std_logic;
			ackInvSetTon15: out std_logic;

			setTon15Ton15: in std_logic_vector(7 downto 0);

			reqInvSetTon60: in std_logic;
			ackInvSetTon60: out std_logic;

			setTon60Ton60: in std_logic_vector(7 downto 0);

			d15pwm: out std_logic;
			d60pwm: out std_logic
		);
	end component;

	component Lwiracq is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;
			lwirrng: in std_logic;
			strbLwir: in std_logic;
			tkclksrcGetTkstTkst: in std_logic_vector(31 downto 0);

			reqInvSetRng: in std_logic;
			ackInvSetRng: out std_logic;

			setRngRng: in std_logic_vector(7 downto 0);

			getInfoTixVBufstate: out std_logic_vector(7 downto 0);
			getInfoTkst: out std_logic_vector(31 downto 0);
			getInfoMin: out std_logic_vector(15 downto 0);
			getInfoMax: out std_logic_vector(15 downto 0);

			reqAbufToHostif: in std_logic;

			reqBbufToHostif: in std_logic;

			ackAbufToHostif: out std_logic;

			ackBbufToHostif: out std_logic;

			dneAbufToHostif: in std_logic;

			dneBbufToHostif: in std_logic;

			avllenAbufToHostif: out std_logic_vector(15 downto 0);
			avllenBbufToHostif: out std_logic_vector(15 downto 0);

			dAbufToHostif: out std_logic_vector(7 downto 0);

			dBbufToHostif: out std_logic_vector(7 downto 0);

			strbDAbufToHostif: in std_logic;

			strbDBbufToHostif: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			miso: in std_logic;

			abbufLock_dbg: out std_logic_vector(7 downto 0);
			stateBuf_dbg: out std_logic_vector(7 downto 0);
			stateBufB_dbg: out std_logic_vector(7 downto 0);
			stateOp_dbg: out std_logic_vector(7 downto 0)
		);
	end component;

	component Lwirif is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;
			rng: out std_logic;

			reqInvSetRng: in std_logic;
			ackInvSetRng: out std_logic;

			setRngRng: in std_logic_vector(7 downto 0);

			nirst: out std_logic;
			imclk: out std_logic;

			scl: out std_logic;
			sda: inout std_logic
		);
	end component;

	component Mmcm_div2 is
		port (
			reset: in std_logic;
			clk_out1: out std_logic;
			clk_in1: in std_logic
		);
	end component;

	component Oled128x32_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			textNotBitmap: std_logic := '0';
			numNotChar: std_logic := '0';
			binNotHex: std_logic := '0';

			Tfrm: natural range 10 to 1000 := 100
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;
			run: in std_logic;

			bitmap: in bitmap32x128_t;
			char: in char4x20_t;
			hex: in hex4x16_t;
			bin: in bin4x16_t;

			vdd: out std_logic;
			vbat: out std_logic;

			nres: out std_logic;
			dNotC: out std_logic;

			sclk: out std_logic;
			mosi: out std_logic
		);
	end component;

	component Servo is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			reqInvSetTheta: in std_logic;
			ackInvSetTheta: out std_logic;

			setThetaTheta: in std_logic_vector(15 downto 0);

			reqInvSetPhi: in std_logic;
			ackInvSetPhi: out std_logic;

			setPhiPhi: in std_logic_vector(15 downto 0);

			tpwm: out std_logic;
			ppwm: out std_logic
		);
	end component;

	component State is
		port (
			reset: in std_logic;
			tkclk: in std_logic;

			getTixVZedbState: out std_logic_vector(7 downto 0);

			lwirrng: in std_logic;
			commok: in std_logic;

			ledg: out std_logic;
			ledr: out std_logic
		);
	end component;

	component Tkclksrc is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: out std_logic;

			getTkstTkst: out std_logic_vector(31 downto 0);

			reqInvSetTkst: in std_logic;
			ackInvSetTkst: out std_logic;

			setTkstTkst: in std_logic_vector(31 downto 0)
		);
	end component;

	component Trigger is
		generic (
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			reqInvSetRng: in std_logic;
			ackInvSetRng: out std_logic;

			setRngRng: in std_logic_vector(7 downto 0);
			setRngBtnNotTfrm: in std_logic_vector(7 downto 0);

			reqInvSetTdlyLwir: in std_logic;
			ackInvSetTdlyLwir: out std_logic;

			setTdlyLwirTdlyLwir: in std_logic_vector(15 downto 0);

			reqInvSetTdlyVisr: in std_logic;
			ackInvSetTdlyVisr: out std_logic;

			setTdlyVisrTdlyVisr: in std_logic_vector(15 downto 0);

			reqInvSetTfrm: in std_logic;
			ackInvSetTfrm: out std_logic;

			setTfrmTfrm: in std_logic_vector(15 downto 0);

			rng: out std_logic;
			strbLwir: out std_logic;
			strbVisl: out std_logic;
			btn: in std_logic;
			trigVisl: out std_logic;
			trigVisr: out std_logic
		);
	end component;

	component Vgaacq is
		generic (
			fMclk: natural range 1 to 1000000
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			reqInvSetRng: in std_logic;
			ackInvSetRng: out std_logic;

			setRngRng: in std_logic_vector(7 downto 0);

			getInfoTixVBufstate: out std_logic_vector(7 downto 0);
			getInfoTkst: out std_logic_vector(31 downto 0);

			reqAbufToHostif: in std_logic;

			reqBbufToHostif: in std_logic;

			ackAbufToHostif: out std_logic;

			ackBbufToHostif: out std_logic;

			dneAbufToHostif: in std_logic;

			dneBbufToHostif: in std_logic;

			avllenAbufToHostif: out std_logic_vector(15 downto 0);
			avllenBbufToHostif: out std_logic_vector(15 downto 0);

			dAbufToHostif: out std_logic_vector(7 downto 0);

			dBbufToHostif: out std_logic_vector(7 downto 0);

			strbDAbufToHostif: in std_logic;

			strbDBbufToHostif: in std_logic;

			rxd: in std_logic;
			txd: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- reset (rst)
	type stateRst_t is (
		stateRstReset,
		stateRstRun
	);
	signal stateRst: stateRst_t := stateRstReset;

	signal reset: std_logic;

	---- myAdxl
	signal adxlGetAxAx: std_logic_vector(15 downto 0);

	signal adxlGetAyAy: std_logic_vector(15 downto 0);

	signal adxlGetAzAz: std_logic_vector(15 downto 0);

	---- myDebounceBtnc
	signal btnC_sig: std_logic;

	---- myDebounceBtnl
	signal btnL_sig: std_logic;

	---- myDebounceBtnr
	signal btnR_sig: std_logic;

	---- myHostif
	signal commok: std_logic;

	signal alignSetSeqLenSeq: std_logic_vector(7 downto 0);
	signal alignSetSeqSeq: std_logic_vector(255 downto 0);

	signal ledSetTon15Ton15: std_logic_vector(7 downto 0);

	signal ledSetTon60Ton60: std_logic_vector(7 downto 0);

	signal lwirifSetRngRng: std_logic_vector(7 downto 0);

	signal lwiracqSetRngRng: std_logic_vector(7 downto 0);

	signal servoSetThetaTheta: std_logic_vector(15 downto 0);

	signal servoSetPhiPhi: std_logic_vector(15 downto 0);

	signal tkclksrcSetTkstTkst: std_logic_vector(31 downto 0);

	signal triggerSetRngRng: std_logic_vector(7 downto 0);
	signal triggerSetRngBtnNotTfrm: std_logic_vector(7 downto 0);

	signal triggerSetTdlyLwirTdlyLwir: std_logic_vector(15 downto 0);

	signal triggerSetTdlyVisrTdlyVisr: std_logic_vector(15 downto 0);

	signal triggerSetTfrmTfrm: std_logic_vector(15 downto 0);

	signal vgaacqSetRngRng: std_logic_vector(7 downto 0);

	signal strbDAbufLwiracqToHostif: std_logic;

	signal strbDBbufLwiracqToHostif: std_logic;

	signal strbDAbufVgaacqToHostif: std_logic;

	signal strbDBbufVgaacqToHostif: std_logic;

	---- myLwiracq
	signal lwiracqGetInfoTixVBufstate: std_logic_vector(7 downto 0);
	signal lwiracqGetInfoTkst: std_logic_vector(31 downto 0);
	signal lwiracqGetInfoMin: std_logic_vector(15 downto 0);
	signal lwiracqGetInfoMax: std_logic_vector(15 downto 0);

	signal avllenAbufLwiracqToHostif: std_logic_vector(15 downto 0);
	signal avllenBbufLwiracqToHostif: std_logic_vector(15 downto 0);

	signal dAbufLwiracqToHostif: std_logic_vector(7 downto 0);

	signal dBbufLwiracqToHostif: std_logic_vector(7 downto 0);

	---- myLwirif
	signal lwirrng: std_logic;

	---- myMmcmMclk
	signal mclk: std_logic;

	---- myState
	signal stateGetTixVZedbState: std_logic_vector(7 downto 0);

	---- myTkclksrc
	signal tkclk: std_logic;

	signal tkclksrcGetTkstTkst: std_logic_vector(31 downto 0);

	---- myTrigger
	signal trigrng: std_logic;
	signal strbLwir: std_logic;
	signal strbVisl: std_logic;

	---- myVgaacq
	signal vgaacqGetInfoTixVBufstate: std_logic_vector(7 downto 0);
	signal vgaacqGetInfoTkst: std_logic_vector(31 downto 0);

	signal avllenAbufVgaacqToHostif: std_logic_vector(15 downto 0);

	signal dAbufVgaacqToHostif: std_logic_vector(7 downto 0);

	signal avllenBbufVgaacqToHostif: std_logic_vector(15 downto 0);

	signal dBbufVgaacqToHostif: std_logic_vector(7 downto 0);

	---- handshake
	-- myHostif to myAlign
	signal reqInvAlignSetSeq: std_logic;
	signal ackInvAlignSetSeq: std_logic;

	-- myHostif to myLed
	signal reqInvLedSetTon15: std_logic;
	signal ackInvLedSetTon15: std_logic;

	-- myHostif to myLed
	signal reqInvLedSetTon60: std_logic;
	signal ackInvLedSetTon60: std_logic;

	-- myHostif to myLwirif
	signal reqInvLwirifSetRng: std_logic;
	signal ackInvLwirifSetRng: std_logic;

	-- myHostif to myLwiracq
	signal reqInvLwiracqSetRng: std_logic;
	signal ackInvLwiracqSetRng: std_logic;

	-- myHostif to myServo
	signal reqInvServoSetTheta: std_logic;
	signal ackInvServoSetTheta: std_logic;

	-- myHostif to myServo
	signal reqInvServoSetPhi: std_logic;
	signal ackInvServoSetPhi: std_logic;

	-- myHostif to myTkclksrc
	signal reqInvTkclksrcSetTkst: std_logic;
	signal ackInvTkclksrcSetTkst: std_logic;

	-- myHostif to myTrigger
	signal reqInvTriggerSetRng: std_logic;
	signal ackInvTriggerSetRng: std_logic;

	-- myHostif to myTrigger
	signal reqInvTriggerSetTdlyLwir: std_logic;
	signal ackInvTriggerSetTdlyLwir: std_logic;

	-- myHostif to myTrigger
	signal reqInvTriggerSetTdlyVisr: std_logic;
	signal ackInvTriggerSetTdlyVisr: std_logic;

	-- myHostif to myTrigger
	signal reqInvTriggerSetTfrm: std_logic;
	signal ackInvTriggerSetTfrm: std_logic;

	-- myHostif to myVgaacq
	signal reqInvVgaacqSetRng: std_logic;
	signal ackInvVgaacqSetRng: std_logic;

	-- myHostif to myLwiracq
	signal reqAbufLwiracqToHostif: std_logic;
	signal ackAbufLwiracqToHostif: std_logic;
	signal dneAbufLwiracqToHostif: std_logic;

	-- myHostif to myLwiracq
	signal reqBbufLwiracqToHostif: std_logic;
	signal ackBbufLwiracqToHostif: std_logic;
	signal dneBbufLwiracqToHostif: std_logic;

	-- myHostif to myVgaacq
	signal reqAbufVgaacqToHostif: std_logic;
	signal ackAbufVgaacqToHostif: std_logic;
	signal dneAbufVgaacqToHostif: std_logic;

	-- myHostif to myVgaacq
	signal reqBbufVgaacqToHostif: std_logic;
	signal ackBbufVgaacqToHostif: std_logic;
	signal dneBbufVgaacqToHostif: std_logic;

	---- other
	signal reqReset: std_logic := '0';
	signal hex: hex4x16_t;
	signal hostifStateOp_dbg: std_logic_vector(7 downto 0);
	signal lwiracqAbbufLock_dbg: std_logic_vector(7 downto 0);
	signal lwiracqStateBuf_dbg: std_logic_vector(7 downto 0);
	signal lwiracqStateBufB_dbg: std_logic_vector(7 downto 0);
	signal lwiracqStateOp_dbg: std_logic_vector(7 downto 0);
	signal lmio_sig: std_logic_vector(1 downto 0) := "00";
	signal rmio_sig: std_logic_vector(1 downto 0) := "00";
	-- IP sigs.oth.cust --- IBEGIN
	signal hostifStateOp_dbg: std_logic_vector(7 downto 0);

	signal lwiracqAbbufLock_dbg: std_logic_vector(7 downto 0);
	signal lwiracqStateBuf_dbg: std_logic_vector(7 downto 0);
	signal lwiracqStateBufB_dbg: std_logic_vector(7 downto 0);
	signal lwiracqStateOp_dbg: std_logic_vector(7 downto 0);
	-- IP sigs.oth.cust --- IEND

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myAdxl : Adxl
		generic map (
			res => "01",
			rate => "1010",

			Tsmp => 100, -- in tkclk periods
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			getAxAx => adxlGetAxAx,

			getAyAy => adxlGetAyAy,

			getAzAz => adxlGetAzAz,

			nss => nxss,
			sclk => xsck,
			mosi => xmosi,
			miso => xmiso
		);

	myAlign : Align
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk,

			reqInvSetSeq => reqInvAlignSetSeq,
			ackInvSetSeq => ackInvAlignSetSeq,

			setSeqLenSeq => alignSetSeqLenSeq,
			setSeqSeq => alignSetSeqSeq,

			trigrng => trigrng,
			strbVisl => strbVisl,

			nss => nass,
			sclk => asck,
			mosi => amosi
		);

	myDebounceBtnc : Debounce_v1_0
		generic map (
			tdead => 100
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			noisy => btnC,
			clean => btnC_sig
		);

	myDebounceBtnl : Debounce_v1_0
		generic map (
			tdead => 100
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			noisy => btnL,
			clean => btnL_sig
		);

	myDebounceBtnr : Debounce_v1_0
		generic map (
			tdead => 100
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			noisy => btnR,
			clean => btnR_sig
		);

	myHostif : Hostif
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,
			commok => commok,

			btnReset => btnL_sig,
			reqReset => reqReset,

			adxlGetAxAx => adxlGetAxAx,

			adxlGetAyAy => adxlGetAyAy,

			adxlGetAzAz => adxlGetAzAz,

			reqInvAlignSetSeq => reqInvAlignSetSeq,
			ackInvAlignSetSeq => ackInvAlignSetSeq,

			alignSetSeqLenSeq => alignSetSeqLenSeq,
			alignSetSeqSeq => alignSetSeqSeq,

			reqInvLedSetTon15 => reqInvLedSetTon15,
			ackInvLedSetTon15 => ackInvLedSetTon15,

			ledSetTon15Ton15 => ledSetTon15Ton15,

			reqInvLedSetTon60 => reqInvLedSetTon60,
			ackInvLedSetTon60 => ackInvLedSetTon60,

			ledSetTon60Ton60 => ledSetTon60Ton60,

			reqInvLwirifSetRng => reqInvLwirifSetRng,
			ackInvLwirifSetRng => ackInvLwirifSetRng,

			lwirifSetRngRng => lwirifSetRngRng,

			reqInvLwiracqSetRng => reqInvLwiracqSetRng,
			ackInvLwiracqSetRng => ackInvLwiracqSetRng,

			lwiracqSetRngRng => lwiracqSetRngRng,

			lwiracqGetInfoTixVBufstate => lwiracqGetInfoTixVBufstate,
			lwiracqGetInfoTkst => lwiracqGetInfoTkst,
			lwiracqGetInfoMin => lwiracqGetInfoMin,
			lwiracqGetInfoMax => lwiracqGetInfoMax,

			reqInvServoSetTheta => reqInvServoSetTheta,
			ackInvServoSetTheta => ackInvServoSetTheta,

			servoSetThetaTheta => servoSetThetaTheta,

			reqInvServoSetPhi => reqInvServoSetPhi,
			ackInvServoSetPhi => ackInvServoSetPhi,

			servoSetPhiPhi => servoSetPhiPhi,

			stateGetTixVZedbState => stateGetTixVZedbState,

			tkclksrcGetTkstTkst => tkclksrcGetTkstTkst,

			reqInvTkclksrcSetTkst => reqInvTkclksrcSetTkst,
			ackInvTkclksrcSetTkst => ackInvTkclksrcSetTkst,

			tkclksrcSetTkstTkst => tkclksrcSetTkstTkst,

			reqInvTriggerSetRng => reqInvTriggerSetRng,
			ackInvTriggerSetRng => ackInvTriggerSetRng,

			triggerSetRngRng => triggerSetRngRng,
			triggerSetRngBtnNotTfrm => triggerSetRngBtnNotTfrm,

			reqInvTriggerSetTdlyLwir => reqInvTriggerSetTdlyLwir,
			ackInvTriggerSetTdlyLwir => ackInvTriggerSetTdlyLwir,

			triggerSetTdlyLwirTdlyLwir => triggerSetTdlyLwirTdlyLwir,

			reqInvTriggerSetTdlyVisr => reqInvTriggerSetTdlyVisr,
			ackInvTriggerSetTdlyVisr => ackInvTriggerSetTdlyVisr,

			triggerSetTdlyVisrTdlyVisr => triggerSetTdlyVisrTdlyVisr,

			reqInvTriggerSetTfrm => reqInvTriggerSetTfrm,
			ackInvTriggerSetTfrm => ackInvTriggerSetTfrm,

			triggerSetTfrmTfrm => triggerSetTfrmTfrm,

			reqInvVgaacqSetRng => reqInvVgaacqSetRng,
			ackInvVgaacqSetRng => ackInvVgaacqSetRng,

			vgaacqSetRngRng => vgaacqSetRngRng,

			vgaacqGetInfoTixVBufstate => vgaacqGetInfoTixVBufstate,
			vgaacqGetInfoTkst => vgaacqGetInfoTkst,

			reqAbufFromLwiracq => reqAbufLwiracqToHostif,

			reqBbufFromLwiracq => reqBbufLwiracqToHostif,

			reqAbufFromVgaacq => reqAbufVgaacqToHostif,

			ackAbufFromLwiracq => ackAbufLwiracqToHostif,

			ackBbufFromLwiracq => ackBbufLwiracqToHostif,

			ackAbufFromVgaacq => ackAbufVgaacqToHostif,

			dneAbufFromLwiracq => dneAbufLwiracqToHostif,

			dneBbufFromLwiracq => dneBbufLwiracqToHostif,

			dneAbufFromVgaacq => dneAbufVgaacqToHostif,

			avllenAbufFromLwiracq => avllenAbufLwiracqToHostif,
			avllenBbufFromLwiracq => avllenBbufLwiracqToHostif,
			avllenAbufFromVgaacq => avllenAbufVgaacqToHostif,

			dAbufFromLwiracq => dAbufLwiracqToHostif,

			dBbufFromLwiracq => dBbufLwiracqToHostif,

			dAbufFromVgaacq => dAbufVgaacqToHostif,

			strbDAbufFromLwiracq => strbDAbufLwiracqToHostif,

			strbDBbufFromLwiracq => strbDBbufLwiracqToHostif,

			strbDAbufFromVgaacq => strbDAbufVgaacqToHostif,

			reqBbufFromVgaacq => reqBbufVgaacqToHostif,
			ackBbufFromVgaacq => ackBbufVgaacqToHostif,
			dneBbufFromVgaacq => dneBbufVgaacqToHostif,

			avllenBbufFromVgaacq => avllenBbufVgaacqToHostif,

			dBbufFromVgaacq => dBbufVgaacqToHostif,
			strbDBbufFromVgaacq => strbDBbufVgaacqToHostif,

			enRx => enRx,
			rx => rx,
			strbRx => strbRx,

			enTx => enTx,
			tx => tx,
			strbTx => strbTx,

			stateOp_dbg => hostifStateOp_dbg
		);

	myLed : Led
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			reqInvSetTon15 => reqInvLedSetTon15,
			ackInvSetTon15 => ackInvLedSetTon15,

			setTon15Ton15 => ledSetTon15Ton15,

			reqInvSetTon60 => reqInvLedSetTon60,
			ackInvSetTon60 => ackInvLedSetTon60,

			setTon60Ton60 => ledSetTon60Ton60,

			d15pwm => d60pwm,
			d60pwm => d15pwm
		);

	myLwiracq : Lwiracq
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,
			lwirrng => lwirrng,
			strbLwir => strbLwir,
			tkclksrcGetTkstTkst => tkclksrcGetTkstTkst,

			reqInvSetRng => reqInvLwiracqSetRng,
			ackInvSetRng => ackInvLwiracqSetRng,

			setRngRng => lwiracqSetRngRng,

			getInfoTixVBufstate => lwiracqGetInfoTixVBufstate,
			getInfoTkst => lwiracqGetInfoTkst,
			getInfoMin => lwiracqGetInfoMin,
			getInfoMax => lwiracqGetInfoMax,

			reqAbufToHostif => reqAbufLwiracqToHostif,

			reqBbufToHostif => reqBbufLwiracqToHostif,

			ackAbufToHostif => ackAbufLwiracqToHostif,

			ackBbufToHostif => ackBbufLwiracqToHostif,

			dneAbufToHostif => dneAbufLwiracqToHostif,

			dneBbufToHostif => dneBbufLwiracqToHostif,

			avllenAbufToHostif => avllenAbufLwiracqToHostif,
			avllenBbufToHostif => avllenBbufLwiracqToHostif,

			dAbufToHostif => dAbufLwiracqToHostif,

			dBbufToHostif => dBbufLwiracqToHostif,

			strbDAbufToHostif => strbDAbufLwiracqToHostif,

			strbDBbufToHostif => strbDBbufLwiracqToHostif,

			nss => niss,
			sclk => isck,
			miso => irxd,

			abbufLock_dbg => lwiracqAbbufLock_dbg,
			stateBuf_dbg => lwiracqStateBuf_dbg,
			stateBufB_dbg => lwiracqStateBufB_dbg,
			stateOp_dbg => lwiracqStateOp_dbg
		);

	myLwirif : Lwirif
		generic map (
			fMclk => fMclk -- in kHz
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,
			rng => lwirrng,

			reqInvSetRng => reqInvLwirifSetRng,
			ackInvSetRng => ackInvLwirifSetRng,

			setRngRng => lwirifSetRngRng,

			nirst => nirst,
			imclk => imclk,

			scl => iscl,
			sda => isda
		);

	myMmcmMclk : Mmcm_div2
		port map (
			reset => '0',
			clk_out1 => mclk,
			clk_in1 => extclk
		);

	myOled128x32 : Oled128x32_v1_0
		generic map (
			fMclk => fMclk,

			textNotBitmap => '0',
			numNotChar => '0',
			binNotHex => '0',

			Tfrm => 100
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,
			run => '1',

			bitmap => (x"AAAA9249FFFF9249AAAA9249FFFF9249", x"AAAA492400002492AAAA492400002492", x"AAAA2492FFFF4924AAAA2492FFFF4924", x"AAAA924900009249AAAA924900009249", x"AAAA4924FFFF2492AAAA4924FFFF2492", x"AAAA249200004924AAAA249200004924", x"AAAA9249FFFF9249AAAA9249FFFF9249", x"AAAA492400002492AAAA492400002492", x"AAAA2492FFFF4924AAAA2492FFFF4924", x"AAAA924900009249AAAA924900009249", x"AAAA4924FFFF2492AAAA4924FFFF2492", x"AAAA249200004924AAAA249200004924", x"AAAA9249FFFF9249AAAA9249FFFF9249", x"AAAA492400002492AAAA492400002492", x"AAAA2492FFFF4924AAAA2492FFFF4924", x"AAAA924900009249AAAA924900009249", x"FFFF9249AAAA9249FFFF9249AAAA9249", x"00002492AAAA492400002492AAAA4924", x"FFFF4924AAAA2492FFFF4924AAAA2492", x"00009249AAAA924900009249AAAA9249", x"FFFF2492AAAA4924FFFF2492AAAA4924", x"00004924AAAA249200004924AAAA2492", x"FFFF9249AAAA9249FFFF9249AAAA9249", x"00002492AAAA492400002492AAAA4924", x"FFFF4924AAAA2492FFFF4924AAAA2492", x"00009249AAAA924900009249AAAA9249", x"FFFF2492AAAA4924FFFF2492AAAA4924", x"00004924AAAA249200004924AAAA2492", x"FFFF9249AAAA9249FFFF9249AAAA9249", x"00002492AAAA492400002492AAAA4924", x"FFFF4924AAAA2492FFFF4924AAAA2492", x"00009249AAAA924900009249AAAA9249"),
			char => (('W',' ','H',' ','I',' ','Z',' ','N',' ','I',' ','U',' ','M','/','/','D','B','E'),('(','C',')',' ','2','0','1','7',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '),('M','p','s','i',' ','T','e','c','h','n','o','l','o','g','i','e','s',' ',' ',' '),('M','u','n','i','c','h',',',' ','G','e','r','m','a','n','y',' ',' ',' ',' ',' ')),
			hex => hex,
			bin => (x"0000", x"0000", x"0000", x"0000"),

			vdd => oledVdd,
			vbat => oledVbat,

			nres => oledRes,
			dNotC => oledDc,

			sclk => oledSclk,
			mosi => oledSdin
		);

	myServo : Servo
		generic map (
			fMclk => fMclk -- in kHz
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			reqInvSetTheta => reqInvServoSetTheta,
			ackInvSetTheta => ackInvServoSetTheta,

			setThetaTheta => servoSetThetaTheta,

			reqInvSetPhi => reqInvServoSetPhi,
			ackInvSetPhi => ackInvServoSetPhi,

			setPhiPhi => servoSetPhiPhi,

			tpwm => tpwm,
			ppwm => ppwm
		);

	myState : State
		port map (
			reset => reset,
			tkclk => tkclk,

			getTixVZedbState => stateGetTixVZedbState,

			lwirrng => lwirrng,
			commok => commok,

			ledg => sgrn,
			ledr => sred
		);

	myTkclksrc : Tkclksrc
		generic map (
			fMclk => 50000
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			getTkstTkst => tkclksrcGetTkstTkst,

			reqInvSetTkst => reqInvTkclksrcSetTkst,
			ackInvSetTkst => ackInvTkclksrcSetTkst,

			setTkstTkst => tkclksrcSetTkstTkst
		);

	myTrigger : Trigger
		generic map (
			fMclk => fMclk -- in kHz
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			reqInvSetRng => reqInvTriggerSetRng,
			ackInvSetRng => ackInvTriggerSetRng,

			setRngRng => triggerSetRngRng,
			setRngBtnNotTfrm => triggerSetRngBtnNotTfrm,

			reqInvSetTdlyLwir => reqInvTriggerSetTdlyLwir,
			ackInvSetTdlyLwir => ackInvTriggerSetTdlyLwir,

			setTdlyLwirTdlyLwir => triggerSetTdlyLwirTdlyLwir,

			reqInvSetTdlyVisr => reqInvTriggerSetTdlyVisr,
			ackInvSetTdlyVisr => ackInvTriggerSetTdlyVisr,

			setTdlyVisrTdlyVisr => triggerSetTdlyVisrTdlyVisr,

			reqInvSetTfrm => reqInvTriggerSetTfrm,
			ackInvSetTfrm => ackInvTriggerSetTfrm,

			setTfrmTfrm => triggerSetTfrmTfrm,

			rng => trigrng,
			strbLwir => strbLwir,
			strbVisl => strbVisl,
			btn => btnC_sig,
			trigVisl => lmio_sig(0),
			trigVisr => rmio_sig(0)
		);

	myVgaacq : Vgaacq
		generic map (
			fMclk => fMclk
		)
		port map (
			reset => reset,
			mclk => mclk,

			reqInvSetRng => reqInvVgaacqSetRng,
			ackInvSetRng => ackInvVgaacqSetRng,

			setRngRng => vgaacqSetRngRng,

			getInfoTixVBufstate => vgaacqGetInfoTixVBufstate,
			getInfoTkst => vgaacqGetInfoTkst,

			reqAbufToHostif => reqAbufVgaacqToHostif,

			reqBbufToHostif => reqBbufVgaacqToHostif,

			ackAbufToHostif => ackAbufVgaacqToHostif,

			ackBbufToHostif => ackBbufVgaacqToHostif,

			dneAbufToHostif => dneAbufVgaacqToHostif,

			dneBbufToHostif => dneBbufVgaacqToHostif,

			avllenAbufToHostif => avllenAbufVgaacqToHostif,
			avllenBbufToHostif => avllenBbufVgaacqToHostif,

			dAbufToHostif => dAbufVgaacqToHostif,

			dBbufToHostif => dBbufVgaacqToHostif,

			strbDAbufToHostif => strbDAbufVgaacqToHostif,

			strbDBbufToHostif => strbDBbufVgaacqToHostif,

			rxd => irxd,
			txd => itxd
		);

	------------------------------------------------------------------------
	-- implementation: reset (rst)
	------------------------------------------------------------------------

	-- IP impl.rst.wiring --- BEGIN
	reset <= '1' when stateRst=stateRstReset else '0';
	-- IP impl.rst.wiring --- END

	process (reqReset, mclk)
		variable i: natural range 0 to 16 := 0;
	begin
		if reqReset='1' then
			i := 0;
			stateRst <= stateRstReset;
		elsif rising_edge(mclk) then
			if stateRst=stateRstReset then
				i := i + 1;
				if i=16 then
					i := 0;
					stateRst <= stateRstRun;
				end if;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	lmio <= lmio_sig;
	rmio <= rmio_sig;
	
	-- IP impl.oth.cust --- IBEGIN
	hex(0) <= hostifStateOp_dbg & x"00000000000000";
	hex(1) <= (others => '0');
	hex(2) <= (others => '0');
	hex(3) <= x"00" & lwiracqAbbufLock_dbg & x"00" & lwiracqStateBuf_dbg & x"00" & lwiracqStateBufB_dbg & x"00" & lwiracqStateOp_dbg;

	gnd <= "000";

	JA <= (others => '0');
	-- IP impl.oth.cust --- IEND

end Top;




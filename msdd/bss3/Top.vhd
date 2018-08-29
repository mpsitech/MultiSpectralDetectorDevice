-- file Top.vhd
-- Top top_v1_0 top implementation
-- author Alexander Wirthmueller
-- date created: 26 Aug 2018
-- date modified: 26 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Top is
	generic (
		fExtclk: natural range 1 to 1000000 := 100000;
		fMclk: natural range 1 to 1000000 := 50000
	);
	port (
		sw: in std_logic_vector(15 downto 0);
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
		RsRx: in std_logic;
		RsTx: out std_logic;
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

		an: out std_logic_vector(3 downto 0);

		dp: out std_logic;

		seg: out std_logic_vector(6 downto 0);

		tpwm: out std_logic;
		ppwm: out std_logic;
		sgrn: out std_logic;
		sred: out std_logic;
		lmio: out std_logic_vector(0 downto 0);
		rmio: out std_logic_vector(0 downto 0);
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
		generic (
			fMclk: natural range 1 to 1000000 := 50000;
			fSclk: natural range 100 to 50000000 := 5000000
		);
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

			reqInvLwiracqSetRng: out std_logic;
			ackInvLwiracqSetRng: in std_logic;

			lwiracqSetRngRng: out std_logic_vector(7 downto 0);

			lwiracqGetInfoTixVBufstate: in std_logic_vector(7 downto 0);
			lwiracqGetInfoTkst: in std_logic_vector(31 downto 0);
			lwiracqGetInfoMin: in std_logic_vector(15 downto 0);
			lwiracqGetInfoMax: in std_logic_vector(15 downto 0);

			reqInvLwirifSetRng: out std_logic;
			ackInvLwirifSetRng: in std_logic;

			lwirifSetRngRng: out std_logic_vector(7 downto 0);

			reqInvServoSetTheta: out std_logic;
			ackInvServoSetTheta: in std_logic;

			servoSetThetaTheta: out std_logic_vector(15 downto 0);

			reqInvServoSetPhi: out std_logic;
			ackInvServoSetPhi: in std_logic;

			servoSetPhiPhi: out std_logic_vector(15 downto 0);

			stateGetTixVBss3State: in std_logic_vector(7 downto 0);

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

			reqBbufFromLwiracq: out std_logic;

			reqAbufFromLwiracq: out std_logic;

			ackBbufFromLwiracq: in std_logic;

			ackAbufFromLwiracq: in std_logic;

			dneBbufFromLwiracq: out std_logic;

			dneAbufFromLwiracq: out std_logic;

			avllenBbufFromLwiracq: in std_logic_vector(15 downto 0);
			avllenAbufFromLwiracq: in std_logic_vector(15 downto 0);

			dBbufFromLwiracq: in std_logic_vector(7 downto 0);

			dAbufFromLwiracq: in std_logic_vector(7 downto 0);

			strbDBbufFromLwiracq: out std_logic;

			strbDAbufFromLwiracq: out std_logic;

			reqAbufFromVgaacq: out std_logic;
			ackAbufFromVgaacq: in std_logic;
			dneAbufFromVgaacq: out std_logic;

			avllenAbufFromVgaacq: in std_logic_vector(15 downto 0);

			reqBbufFromVgaacq: out std_logic;

			dAbufFromVgaacq: in std_logic_vector(7 downto 0);

			ackBbufFromVgaacq: in std_logic;

			strbDAbufFromVgaacq: out std_logic;

			dneBbufFromVgaacq: out std_logic;

			avllenBbufFromVgaacq: in std_logic_vector(15 downto 0);

			dBbufFromVgaacq: in std_logic_vector(7 downto 0);
			strbDBbufFromVgaacq: out std_logic;

			rxd: in std_logic;
			txd: out std_logic
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

			reqInvSetRng: in std_logic;
			ackInvSetRng: out std_logic;

			setRngRng: in std_logic_vector(7 downto 0);

			getInfoTixVBufstate: out std_logic_vector(7 downto 0);
			getInfoTkst: out std_logic_vector(31 downto 0);
			getInfoMin: out std_logic_vector(15 downto 0);
			getInfoMax: out std_logic_vector(15 downto 0);

			reqBbufToHostif: in std_logic;

			reqAbufToHostif: in std_logic;
			ackAbufToHostif: out std_logic;

			ackBbufToHostif: out std_logic;
			dneBbufToHostif: in std_logic;

			dneAbufToHostif: in std_logic;

			avllenBbufToHostif: out std_logic_vector(15 downto 0);
			avllenAbufToHostif: out std_logic_vector(15 downto 0);

			dBbufToHostif: out std_logic_vector(7 downto 0);

			dAbufToHostif: out std_logic_vector(7 downto 0);

			strbDBbufToHostif: in std_logic;

			strbDAbufToHostif: in std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			miso: in std_logic
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

	component Quad7seg_v1_0 is
		port (
			reset: in std_logic;
			tkclk: in std_logic;
			d: in std_logic_vector(15 downto 0);

			ssa: out std_logic_vector(3 downto 0);
			sscdp: out std_logic;
			ssc: out std_logic_vector(6 downto 0)
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

			getTixVBss3State: out std_logic_vector(7 downto 0);

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
	signal stateRst, stateRst_next: stateRst_t := stateRstReset;

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

	signal lwiracqSetRngRng: std_logic_vector(7 downto 0);

	signal lwirifSetRngRng: std_logic_vector(7 downto 0);

	signal servoSetThetaTheta: std_logic_vector(15 downto 0);

	signal servoSetPhiPhi: std_logic_vector(15 downto 0);

	signal tkclksrcSetTkstTkst: std_logic_vector(31 downto 0);

	signal triggerSetRngRng: std_logic_vector(7 downto 0);
	signal triggerSetRngBtnNotTfrm: std_logic_vector(7 downto 0);

	signal triggerSetTdlyLwirTdlyLwir: std_logic_vector(15 downto 0);

	signal triggerSetTdlyVisrTdlyVisr: std_logic_vector(15 downto 0);

	signal triggerSetTfrmTfrm: std_logic_vector(15 downto 0);

	signal vgaacqSetRngRng: std_logic_vector(7 downto 0);

	signal strbDBbufLwiracqToHostif: std_logic;

	signal strbDAbufLwiracqToHostif: std_logic;

	signal strbDAbufVgaacqToHostif: std_logic;

	signal strbDBbufVgaacqToHostif: std_logic;

	---- myLwiracq
	signal lwiracqGetInfoTixVBufstate: std_logic_vector(7 downto 0);
	signal lwiracqGetInfoTkst: std_logic_vector(31 downto 0);
	signal lwiracqGetInfoMin: std_logic_vector(15 downto 0);
	signal lwiracqGetInfoMax: std_logic_vector(15 downto 0);

	signal avllenBbufLwiracqToHostif: std_logic_vector(15 downto 0);
	signal avllenAbufLwiracqToHostif: std_logic_vector(15 downto 0);

	signal dBbufLwiracqToHostif: std_logic_vector(7 downto 0);

	signal dAbufLwiracqToHostif: std_logic_vector(7 downto 0);

	---- myLwirif
	signal lwirrng: std_logic;

	---- myMmcmMclk
	signal mclk: std_logic;

	---- myState
	signal stateGetTixVBss3State: std_logic_vector(7 downto 0);

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

	-- myHostif to myLwiracq
	signal reqInvLwiracqSetRng: std_logic;
	signal ackInvLwiracqSetRng: std_logic;

	-- myHostif to myLwirif
	signal reqInvLwirifSetRng: std_logic;
	signal ackInvLwirifSetRng: std_logic;

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
	signal reqBbufLwiracqToHostif: std_logic;
	signal ackBbufLwiracqToHostif: std_logic;
	signal dneBbufLwiracqToHostif: std_logic;

	-- myHostif to myLwiracq
	signal reqAbufLwiracqToHostif: std_logic;
	signal ackAbufLwiracqToHostif: std_logic;
	signal dneAbufLwiracqToHostif: std_logic;

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
	signal dQuad7seg: std_logic_vector(15 downto 0);
	-- IP sigs.oth.cust --- INSERT

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
		generic map (
			fMclk => 50000,
			fSclk => 5000000
		)
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

			reqInvLwiracqSetRng => reqInvLwiracqSetRng,
			ackInvLwiracqSetRng => ackInvLwiracqSetRng,

			lwiracqSetRngRng => lwiracqSetRngRng,

			lwiracqGetInfoTixVBufstate => lwiracqGetInfoTixVBufstate,
			lwiracqGetInfoTkst => lwiracqGetInfoTkst,
			lwiracqGetInfoMin => lwiracqGetInfoMin,
			lwiracqGetInfoMax => lwiracqGetInfoMax,

			reqInvLwirifSetRng => reqInvLwirifSetRng,
			ackInvLwirifSetRng => ackInvLwirifSetRng,

			lwirifSetRngRng => lwirifSetRngRng,

			reqInvServoSetTheta => reqInvServoSetTheta,
			ackInvServoSetTheta => ackInvServoSetTheta,

			servoSetThetaTheta => servoSetThetaTheta,

			reqInvServoSetPhi => reqInvServoSetPhi,
			ackInvServoSetPhi => ackInvServoSetPhi,

			servoSetPhiPhi => servoSetPhiPhi,

			stateGetTixVBss3State => stateGetTixVBss3State,

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

			reqBbufFromLwiracq => reqBbufLwiracqToHostif,

			reqAbufFromLwiracq => reqAbufLwiracqToHostif,

			ackBbufFromLwiracq => ackBbufLwiracqToHostif,

			ackAbufFromLwiracq => ackAbufLwiracqToHostif,

			dneBbufFromLwiracq => dneBbufLwiracqToHostif,

			dneAbufFromLwiracq => dneAbufLwiracqToHostif,

			avllenBbufFromLwiracq => avllenBbufLwiracqToHostif,
			avllenAbufFromLwiracq => avllenAbufLwiracqToHostif,

			dBbufFromLwiracq => dBbufLwiracqToHostif,

			dAbufFromLwiracq => dAbufLwiracqToHostif,

			strbDBbufFromLwiracq => strbDBbufLwiracqToHostif,

			strbDAbufFromLwiracq => strbDAbufLwiracqToHostif,

			reqAbufFromVgaacq => reqAbufVgaacqToHostif,
			ackAbufFromVgaacq => ackAbufVgaacqToHostif,
			dneAbufFromVgaacq => dneAbufVgaacqToHostif,

			avllenAbufFromVgaacq => avllenAbufVgaacqToHostif,

			reqBbufFromVgaacq => reqBbufVgaacqToHostif,

			dAbufFromVgaacq => dAbufVgaacqToHostif,

			ackBbufFromVgaacq => ackBbufVgaacqToHostif,

			strbDAbufFromVgaacq => strbDAbufVgaacqToHostif,

			dneBbufFromVgaacq => dneBbufVgaacqToHostif,

			avllenBbufFromVgaacq => avllenBbufVgaacqToHostif,

			dBbufFromVgaacq => dBbufVgaacqToHostif,
			strbDBbufFromVgaacq => strbDBbufVgaacqToHostif,

			rxd => RsRx,
			txd => RsTx
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

			reqInvSetRng => reqInvLwiracqSetRng,
			ackInvSetRng => ackInvLwiracqSetRng,

			setRngRng => lwiracqSetRngRng,

			getInfoTixVBufstate => lwiracqGetInfoTixVBufstate,
			getInfoTkst => lwiracqGetInfoTkst,
			getInfoMin => lwiracqGetInfoMin,
			getInfoMax => lwiracqGetInfoMax,

			reqBbufToHostif => reqBbufLwiracqToHostif,

			reqAbufToHostif => reqAbufLwiracqToHostif,
			ackAbufToHostif => ackAbufLwiracqToHostif,

			ackBbufToHostif => ackBbufLwiracqToHostif,
			dneBbufToHostif => dneBbufLwiracqToHostif,

			dneAbufToHostif => dneAbufLwiracqToHostif,

			avllenBbufToHostif => avllenBbufLwiracqToHostif,
			avllenAbufToHostif => avllenAbufLwiracqToHostif,

			dBbufToHostif => dBbufLwiracqToHostif,

			dAbufToHostif => dAbufLwiracqToHostif,

			strbDBbufToHostif => strbDBbufLwiracqToHostif,

			strbDAbufToHostif => strbDAbufLwiracqToHostif,

			nss => niss,
			sclk => isck,
			miso => irxd
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

	myQuad7seg : Quad7seg_v1_0
		port map (
			reset => reset,
			tkclk => tkclk,
			d => dQuad7seg,

			ssa => an,
			sscdp => dp,
			ssc => seg
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

			getTixVBss3State => stateGetTixVBss3State,

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
			trigVisl => lmio(0),
			trigVisr => rmio(0)
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

	
	-- IP impl.oth.cust --- IBEGIN
	dQuad7seg <= x"ABCD";
	-- IP impl.oth.cust --- IEND

end Top;



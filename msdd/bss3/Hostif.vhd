-- file Hostif.vhd
-- Hostif uarthostif_Easy_v1_0 easy model host interface implementation
-- author Alexander Wirthmueller
-- date created: 12 Aug 2018
-- date modified: 12 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Hostif is
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

		reqBbufFromVgaacq: out std_logic;

		ackBbufFromLwiracq: in std_logic;

		ackBbufFromVgaacq: in std_logic;

		dneBbufFromLwiracq: out std_logic;

		dneBbufFromVgaacq: out std_logic;

		avllenBbufFromLwiracq: in std_logic_vector(15 downto 0);
		avllenBbufFromVgaacq: in std_logic_vector(15 downto 0);

		dBbufFromLwiracq: in std_logic_vector(7 downto 0);

		dBbufFromVgaacq: in std_logic_vector(7 downto 0);

		strbDBbufFromLwiracq: out std_logic;

		strbDBbufFromVgaacq: out std_logic;

		reqAbufFromVgaacq: out std_logic;
		ackAbufFromVgaacq: in std_logic;

		reqAbufFromLwiracq: out std_logic;

		dneAbufFromVgaacq: out std_logic;

		ackAbufFromLwiracq: in std_logic;

		avllenAbufFromVgaacq: in std_logic_vector(15 downto 0);

		dneAbufFromLwiracq: out std_logic;

		dAbufFromVgaacq: in std_logic_vector(7 downto 0);

		avllenAbufFromLwiracq: in std_logic_vector(15 downto 0);

		strbDAbufFromVgaacq: out std_logic;

		dAbufFromLwiracq: in std_logic_vector(7 downto 0);
		strbDAbufFromLwiracq: out std_logic;

		rxd: in std_logic;
		txd: out std_logic
	);
end Hostif;

architecture Hostif of Hostif is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Crc8005_v1_0 is
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			captNotFin: in std_logic;

			d: in std_logic_vector(7 downto 0);
			strbD: in std_logic;

			crc: out std_logic_vector(15 downto 0)
		);
	end component;

	component Uartrx_v1_1 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;
			fSclk: natural range 100 to 50000000 := 9600
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(16 downto 0);

			d: out std_logic_vector(7 downto 0);
			strbD: out std_logic;

			burst: in std_logic;
			rxd: in std_logic
		);
	end component;

	component Timeout_v1_0 is
		generic (
			twait: natural range 1 to 10000 := 100
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;
			tkclk: in std_logic;

			restart: in std_logic;
			timeout: out std_logic
		);
	end component;

	component Uarttx_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			fSclk: natural range 100 to 50000000 := 9600;
			Nstop: natural range 1 to 8 := 1
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(16 downto 0);

			d: in std_logic_vector(7 downto 0);
			strbD: out std_logic;

			txd: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	--- main operation
	type stateOp_t is (
		stateOpIdle,
		stateOpRxopA, stateOpRxopB, stateOpRxopC, stateOpRxopD, stateOpRxopE,
		stateOpPrepTxA, stateOpPrepTxB,
		stateOpTxA, stateOpTxB, stateOpTxC, stateOpTxD, stateOpTxE, stateOpTxF,
		stateOpTxbufA, stateOpTxbufB, stateOpTxbufC, stateOpTxbufD, stateOpTxbufE,
		stateOpTxbufF, stateOpTxbufG, stateOpTxbufH, stateOpTxbufI, stateOpTxbufJ,
		stateOpTxbufK,
		stateOpPrepRx,
		stateOpRxA, stateOpRxB, stateOpRxC, stateOpRxD,
		stateOpCopyRxA, stateOpCopyRxB,
		stateOpPrepRxbuf,
		stateOpRxbufA, stateOpRxbufB, stateOpRxbufC, stateOpRxbufD, stateOpRxbufE,
		stateOpTxackA, stateOpTxackB
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpIdle;

	constant sizeOpbuf: natural := 7;
	type opbuf_t is array (0 to sizeOpbuf-1) of std_logic_vector(7 downto 0);
	signal opbuf: opbuf_t;

	constant sizeRxbuf: natural := 35;
	type rxbuf_t is array (0 to sizeRxbuf-1) of std_logic_vector(7 downto 0);
	signal rxbuf: rxbuf_t;

	constant sizeTxbuf: natural := 11;
	type txbuf_t is array (0 to sizeTxbuf-1) of std_logic_vector(7 downto 0);
	signal txbuf: txbuf_t;

	signal commok_sig, commok_sig_next: std_logic;
	
	signal reqReset_sig, reqReset_sig_next: std_logic;

	signal ackInv: std_logic;

	signal reqTxbuf, reqTxbuf_next: std_logic;
	signal ackTxbuf: std_logic;
	signal dneTxbuf, dneTxbuf_next: std_logic;

	signal avllenTxbuf: natural range 0 to 65534;

	signal dTxbuf: std_logic_vector(7 downto 0);
	signal strbDTxbuf, strbDTxbuf_next: std_logic;

	signal reqRxbuf, reqRxbuf_next: std_logic;
	signal ackRxbuf: std_logic;
	signal dneRxbuf, dneRxbuf_next: std_logic;

	signal avllenRxbuf: natural range 0 to 65534;

	signal dRxbuf, dRxbuf_next: std_logic_vector(7 downto 0);
	signal strbDRxbuf, strbDRxbuf_next: std_logic;

	signal crccaptNotFin: std_logic;

	signal crcd, crcd_next: std_logic_vector(7 downto 0);
	signal strbCrcd: std_logic;

	signal torestart, torestart_next: std_logic;
	signal urxlen: std_logic_vector(16 downto 0);
	signal urxburst: std_logic;
	signal utxlen: std_logic_vector(16 downto 0);

	signal utxd, utxd_next: std_logic_vector(7 downto 0);

	signal alignSetSeqLenSeq_sig: std_logic_vector(7 downto 0);
	signal alignSetSeqSeq_sig: std_logic_vector(255 downto 0);

	signal ledSetTon15Ton15_sig: std_logic_vector(7 downto 0);

	signal ledSetTon60Ton60_sig: std_logic_vector(7 downto 0);

	signal lwiracqSetRngRng_sig: std_logic_vector(7 downto 0);

	signal lwirifSetRngRng_sig: std_logic_vector(7 downto 0);

	signal servoSetThetaTheta_sig: std_logic_vector(15 downto 0);

	signal servoSetPhiPhi_sig: std_logic_vector(15 downto 0);

	signal tkclksrcSetTkstTkst_sig: std_logic_vector(31 downto 0);

	signal triggerSetRngRng_sig: std_logic_vector(7 downto 0);
	signal triggerSetRngBtnNotTfrm_sig: std_logic_vector(7 downto 0);

	signal triggerSetTdlyLwirTdlyLwir_sig: std_logic_vector(15 downto 0);

	signal triggerSetTdlyVisrTdlyVisr_sig: std_logic_vector(15 downto 0);

	signal triggerSetTfrmTfrm_sig: std_logic_vector(15 downto 0);

	signal vgaacqSetRngRng_sig: std_logic_vector(7 downto 0);

	---- myCrc
	signal crc: std_logic_vector(15 downto 0);

	---- myRx
	signal urxd: std_logic_vector(7 downto 0);
	signal strbUrxd: std_logic;

	---- myTimeout
	signal timeout: std_logic;

	---- myTimeout2
	signal timeout2: std_logic;

	---- myTx
	signal strbUtxd: std_logic;

	---- handshake
	-- op to myCrc
	signal reqCrc: std_logic;
	signal ackCrc: std_logic;
	signal dneCrc: std_logic;

	-- op to myRx
	signal reqUrx: std_logic;
	signal ackUrx: std_logic;
	signal dneUrx: std_logic;

	-- op to myTx
	signal reqUtx: std_logic;
	signal ackUtx: std_logic;
	signal dneUtx: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myCrc : Crc8005_v1_0
		port map (
			reset => reset,
			mclk => mclk,

			req => reqCrc,
			ack => ackCrc,
			dne => dneCrc,

			captNotFin => crccaptNotFin,

			d => crcd,
			strbD => strbCrcd,

			crc => crc
		);

	myRx : Uartrx_v1_1
		generic map (
			fMclk => fMclk,
			fSclk => fSclk
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqUrx,
			ack => ackUrx,
			dne => dneUrx,

			len => urxlen,

			d => urxd,
			strbD => strbUrxd,

			burst => urxburst,
			rxd => rxd
		);

	myTimeout : Timeout_v1_0
		generic map (
			twait => 100
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			restart => torestart,
			timeout => timeout
		);

	myTimeout2 : Timeout_v1_0
		generic map (
			twait => 1000
		)
		port map (
			reset => reset,
			mclk => mclk,
			tkclk => tkclk,

			restart => torestart,
			timeout => timeout2
		);

	myTx : Uarttx_v1_0
		generic map (
			fMclk => fMclk,

			fSclk => fSclk,
			Nstop => 1
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqUtx,
			ack => ackUtx,
			dne => dneUtx,

			len => utxlen,

			d => utxd,
			strbD => strbUtxd,

			txd => txd
		);

	------------------------------------------------------------------------
	-- implementation: main operation 
	------------------------------------------------------------------------

	commok <= commok_sig;
	reqReset <= (reqReset_sig or btnReset);

	-- tx/ret command

	-- rx/inv command
	reqInvAlignSetSeq <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerAlign and opbuf(ixOpbufCommand)=tixVAlignCommandSetSeq) else '0';
	reqInvLedSetTon15 <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerLed and opbuf(ixOpbufCommand)=tixVLedCommandSetTon15) else '0';
	reqInvLedSetTon60 <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerLed and opbuf(ixOpbufCommand)=tixVLedCommandSetTon60) else '0';
	reqInvLwiracqSetRng <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerLwiracq and opbuf(ixOpbufCommand)=tixVLwiracqCommandSetRng) else '0';
	reqInvLwirifSetRng <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerLwirif and opbuf(ixOpbufCommand)=tixVLwirifCommandSetRng) else '0';
	reqInvServoSetTheta <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerServo and opbuf(ixOpbufCommand)=tixVServoCommandSetTheta) else '0';
	reqInvServoSetPhi <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerServo and opbuf(ixOpbufCommand)=tixVServoCommandSetPhi) else '0';
	reqInvTkclksrcSetTkst <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerTkclksrc and opbuf(ixOpbufCommand)=tixVTkclksrcCommandSetTkst) else '0';
	reqInvTriggerSetRng <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetRng) else '0';
	reqInvTriggerSetTdlyLwir <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyLwir) else '0';
	reqInvTriggerSetTdlyVisr <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyVisr) else '0';
	reqInvTriggerSetTfrm <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetTfrm) else '0';
	reqInvVgaacqSetRng <= '1' when (stateOp=stateOpCopyRxB and opbuf(ixOpbufController)=tixVControllerVgaacq and opbuf(ixOpbufCommand)=tixVVgaacqCommandSetRng) else '0';

	ackInv <= ackInvAlignSetSeq when (opbuf(ixOpbufController)=tixVControllerAlign and opbuf(ixOpbufCommand)=tixVAlignCommandSetSeq)
				else ackInvLedSetTon15 when (opbuf(ixOpbufController)=tixVControllerLed and opbuf(ixOpbufCommand)=tixVLedCommandSetTon15)
				else ackInvLedSetTon60 when (opbuf(ixOpbufController)=tixVControllerLed and opbuf(ixOpbufCommand)=tixVLedCommandSetTon60)
				else ackInvLwiracqSetRng when (opbuf(ixOpbufController)=tixVControllerLwiracq and opbuf(ixOpbufCommand)=tixVLwiracqCommandSetRng)
				else ackInvLwirifSetRng when (opbuf(ixOpbufController)=tixVControllerLwirif and opbuf(ixOpbufCommand)=tixVLwirifCommandSetRng)
				else ackInvServoSetTheta when (opbuf(ixOpbufController)=tixVControllerServo and opbuf(ixOpbufCommand)=tixVServoCommandSetTheta)
				else ackInvServoSetPhi when (opbuf(ixOpbufController)=tixVControllerServo and opbuf(ixOpbufCommand)=tixVServoCommandSetPhi)
				else ackInvTkclksrcSetTkst when (opbuf(ixOpbufController)=tixVControllerTkclksrc and opbuf(ixOpbufCommand)=tixVTkclksrcCommandSetTkst)
				else ackInvTriggerSetRng when (opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetRng)
				else ackInvTriggerSetTdlyLwir when (opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyLwir)
				else ackInvTriggerSetTdlyVisr when (opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyVisr)
				else ackInvTriggerSetTfrm when (opbuf(ixOpbufController)=tixVControllerTrigger and opbuf(ixOpbufCommand)=tixVTriggerCommandSetTfrm)
				else ackInvVgaacqSetRng when (opbuf(ixOpbufController)=tixVControllerVgaacq and opbuf(ixOpbufCommand)=tixVVgaacqCommandSetRng)
				else '0';

	-- tx buffer
	reqAbufFromLwiracq <= reqTxbuf when opbuf(ixOpbufBuffer)=tixWBufferAbufLwiracqToHostif else '0';
	reqAbufFromVgaacq <= reqTxbuf when opbuf(ixOpbufBuffer)=tixWBufferAbufVgaacqToHostif else '0';
	reqBbufFromLwiracq <= reqTxbuf when opbuf(ixOpbufBuffer)=tixWBufferBbufLwiracqToHostif else '0';
	reqBbufFromVgaacq <= reqTxbuf when opbuf(ixOpbufBuffer)=tixWBufferBbufVgaacqToHostif else '0';

	ackTxbuf <= ackAbufFromLwiracq when opbuf(ixOpbufBuffer)=tixWBufferAbufLwiracqToHostif
				else ackAbufFromVgaacq when opbuf(ixOpbufBuffer)=tixWBufferAbufVgaacqToHostif
				else ackBbufFromLwiracq when opbuf(ixOpbufBuffer)=tixWBufferBbufLwiracqToHostif
				else ackBbufFromVgaacq when opbuf(ixOpbufBuffer)=tixWBufferBbufVgaacqToHostif
				else '0';

	dneAbufFromLwiracq <= dneTxbuf when opbuf(ixOpbufBuffer)=tixWBufferAbufLwiracqToHostif else '0';
	dneAbufFromVgaacq <= dneTxbuf when opbuf(ixOpbufBuffer)=tixWBufferAbufVgaacqToHostif else '0';
	dneBbufFromLwiracq <= dneTxbuf when opbuf(ixOpbufBuffer)=tixWBufferBbufLwiracqToHostif else '0';
	dneBbufFromVgaacq <= dneTxbuf when opbuf(ixOpbufBuffer)=tixWBufferBbufVgaacqToHostif else '0';

	avllenTxbuf <= to_integer(unsigned(avllenAbufFromLwiracq)) when opbuf(ixOpbufBuffer)=tixWBufferAbufLwiracqToHostif
				else to_integer(unsigned(avllenAbufFromVgaacq)) when opbuf(ixOpbufBuffer)=tixWBufferAbufVgaacqToHostif
				else to_integer(unsigned(avllenBbufFromLwiracq)) when opbuf(ixOpbufBuffer)=tixWBufferBbufLwiracqToHostif
				else to_integer(unsigned(avllenBbufFromVgaacq)) when opbuf(ixOpbufBuffer)=tixWBufferBbufVgaacqToHostif
				else 0;

	dTxbuf <= dAbufFromLwiracq when opbuf(ixOpbufBuffer)=tixWBufferAbufLwiracqToHostif
				else dAbufFromVgaacq when opbuf(ixOpbufBuffer)=tixWBufferAbufVgaacqToHostif
				else dBbufFromLwiracq when opbuf(ixOpbufBuffer)=tixWBufferBbufLwiracqToHostif
				else dBbufFromVgaacq when opbuf(ixOpbufBuffer)=tixWBufferBbufVgaacqToHostif
				else x"00";

	strbDAbufFromLwiracq <= strbDTxbuf when opbuf(ixOpbufBuffer)=tixWBufferAbufLwiracqToHostif else '0';
	strbDAbufFromVgaacq <= strbDTxbuf when opbuf(ixOpbufBuffer)=tixWBufferAbufVgaacqToHostif else '0';
	strbDBbufFromLwiracq <= strbDTxbuf when opbuf(ixOpbufBuffer)=tixWBufferBbufLwiracqToHostif else '0';
	strbDBbufFromVgaacq <= strbDTxbuf when opbuf(ixOpbufBuffer)=tixWBufferBbufVgaacqToHostif else '0';

	-- rx buffer

	ackRxbuf <= '0';

	avllenRxbuf <= 0;

	-- IP impl.op.wiring --- BEGIN
	alignSetSeqLenSeq <= alignSetSeqLenSeq_sig;
	alignSetSeqSeq <= alignSetSeqSeq_sig;

	ledSetTon15Ton15 <= ledSetTon15Ton15_sig;

	ledSetTon60Ton60 <= ledSetTon60Ton60_sig;

	lwiracqSetRngRng <= lwiracqSetRngRng_sig;

	lwirifSetRngRng <= lwirifSetRngRng_sig;

	servoSetThetaTheta <= servoSetThetaTheta_sig;

	servoSetPhiPhi <= servoSetPhiPhi_sig;

	tkclksrcSetTkstTkst <= tkclksrcSetTkstTkst_sig;

	triggerSetRngRng <= triggerSetRngRng_sig;
	triggerSetRngBtnNotTfrm <= triggerSetRngBtnNotTfrm_sig;

	triggerSetTdlyLwirTdlyLwir <= triggerSetTdlyLwirTdlyLwir_sig;

	triggerSetTdlyVisrTdlyVisr <= triggerSetTdlyVisrTdlyVisr_sig;

	triggerSetTfrmTfrm <= triggerSetTfrmTfrm_sig;

	vgaacqSetRngRng <= vgaacqSetRngRng_sig;
	-- IP impl.op.wiring --- END

	reqCrc <= '1' when (stateOp=stateOpRxopA or stateOp=stateOpRxopB or stateOp=stateOpRxopC or stateOp=stateOpRxopD or stateOp=stateOpRxopE
				or stateOp=stateOpRxA or stateOp=stateOpRxB or stateOp=stateOpRxC or stateOp=stateOpRxD
				or stateOp=stateOpTxA or stateOp=stateOpTxB or stateOp=stateOpTxC or stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxF
				or stateOp=stateOpTxbufB or stateOp=stateOpTxbufC or stateOp=stateOpTxbufD or stateOp=stateOpTxbufE or stateOp=stateOpTxbufF
				or stateOp=stateOpTxbufG or stateOp=stateOpTxbufH or stateOp=stateOpTxbufI or stateOp=stateOpTxbufJ
				or stateOp=stateOpRxbufA or stateOp=stateOpRxbufB or stateOp=stateOpRxbufC or stateOp=stateOpRxbufD) else '0';

	crccaptNotFin <= '1' when (stateOp=stateOpRxopA or stateOp=stateOpRxopB or stateOp=stateOpRxopC
				or stateOp=stateOpRxA or stateOp=stateOpRxB or stateOp=stateOpRxC
				or stateOp=stateOpTxA or stateOp=stateOpTxB or stateOp=stateOpTxC
				or stateOp=stateOpTxbufB or stateOp=stateOpTxbufC or stateOp=stateOpTxbufD or stateOp=stateOpTxbufE or stateOp=stateOpTxbufF or stateOp=stateOpTxbufG
				or stateOp=stateOpRxbufA or stateOp=stateOpRxbufB or stateOp=stateOpRxbufC) else '0';

	strbCrcd <= '1' when (stateOp=stateOpRxopC or stateOp=stateOpRxC or stateOp=stateOpTxB or stateOp=stateOpTxbufC or stateOp=stateOpRxbufC) else '0';

	reqUrx <= '1' when (stateOp=stateOpRxopA or stateOp=stateOpRxopB or stateOp=stateOpRxopC or stateOp=stateOpRxopD
				or stateOp=stateOpRxA or stateOp=stateOpRxB or stateOp=stateOpRxC
				or stateOp=stateOpRxbufA or stateOp=stateOpRxbufB or stateOp=stateOpRxbufC) else '0';

	reqUtx <= '1' when (stateOp=stateOpTxA or stateOp=stateOpTxB or stateOp=stateOpTxC or stateOp=stateOpTxD or stateOp=stateOpTxE or stateOp=stateOpTxF
				or stateOp=stateOpTxbufB or stateOp=stateOpTxbufC or stateOp=stateOpTxbufD or stateOp=stateOpTxbufE or stateOp=stateOpTxbufF or stateOp=stateOpTxbufG or stateOp=stateOpTxbufH
				or stateOp=stateOpTxbufI or stateOp=stateOpTxbufJ
				or stateOp=stateOpTxackA or stateOp=stateOpTxackB) else '0';

	process (reset, mclk, stateOp)
		variable i: natural range 0 to 65536;
		variable icrc: natural range 0 to 65536; -- for tx and txbuf

		variable x: std_logic_vector(16 downto 0);

	begin
		if reset='1' then
			stateOp_next <= stateOpIdle;
			torestart_next <= '0';
			crcd_next <= (others => '0');
			utxd_next <= (others => '0');
			commok_sig_next <= '0';
			reqReset_sig_next <= '0';
			reqTxbuf_next <= '0';
			dneTxbuf_next <= '0';
			strbDTxbuf_next <= '0';
			reqRxbuf_next <= '0';
			dneRxbuf_next <= '0';
			dRxbuf_next <= x"00";
			strbDRxbuf_next <= '0';

		elsif rising_edge(mclk) then
			if stateOp=stateOpIdle then
				urxlen <= std_logic_vector(to_unsigned(sizeOpbuf, 17));
				urxburst <= '0';
				crcd_next <= (others => '0');
				utxd_next <= (others => '0');
				reqTxbuf_next <= '0';
				dneTxbuf_next <= '0';
				strbDTxbuf_next <= '0';
				reqRxbuf_next <= '0';
				dneRxbuf_next <= '0';
				dRxbuf_next <= x"00";
				strbDRxbuf_next <= '0';

				i := 0;

				torestart_next <= '1';

				if ackUrx='0' then
					stateOp_next <= stateOpRxopA;
				end if;

-- RX OP BEGIN
			elsif stateOp=stateOpRxopA then
				if (ackCrc='1' and ackUrx='1') then
					stateOp_next <= stateOpRxopB;

				elsif timeout='1' then
					stateOp_next <= stateOpIdle;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxopB then
				if strbUrxd='1' then
					opbuf(i) <= urxd;

					crcd_next <= urxd;

					if (i=0 and urxd=x"FF") then
						reqReset_sig_next <= '1';
					else
						torestart_next <= '1';

						stateOp_next <= stateOpRxopC;
					end if;

				elsif ackUrx='0' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpRxopC then -- strbCrcd='1'
				if strbUrxd='0' then
					i := i + 1;

					stateOp_next <= stateOpRxopB;

				elsif dneUrx='1' then
					stateOp_next <= stateOpRxopD;

				elsif timeout='1' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxopD then
				if dneCrc='1' then
					if crc=x"0000" then
						commok_sig_next <= '1';
						urxburst <= '1';
						stateOp_next <= stateOpRxopE;
					else
						commok_sig_next <= '0';
						stateOp_next <= stateOpIdle;
					end if;
				end if;

			elsif stateOp=stateOpRxopE then
				if opbuf(ixOpbufBuffer)=tixWBufferCmdretToHostif then
					urxburst <= '0';
					stateOp_next <= stateOpPrepTxA;

				elsif opbuf(ixOpbufBuffer)=tixWBufferHostifToCmdinv then
					if ( (opbuf(ixOpbufController)=tixVControllerAlign and (opbuf(ixOpbufCommand)=tixVAlignCommandSetSeq))
								or (opbuf(ixOpbufController)=tixVControllerLed and (opbuf(ixOpbufCommand)=tixVLedCommandSetTon15 or opbuf(ixOpbufCommand)=tixVLedCommandSetTon60))
								or (opbuf(ixOpbufController)=tixVControllerLwiracq and (opbuf(ixOpbufCommand)=tixVLwiracqCommandSetRng))
								or (opbuf(ixOpbufController)=tixVControllerLwirif and (opbuf(ixOpbufCommand)=tixVLwirifCommandSetRng))
								or (opbuf(ixOpbufController)=tixVControllerServo and (opbuf(ixOpbufCommand)=tixVServoCommandSetTheta or opbuf(ixOpbufCommand)=tixVServoCommandSetPhi))
								or (opbuf(ixOpbufController)=tixVControllerTkclksrc and (opbuf(ixOpbufCommand)=tixVTkclksrcCommandSetTkst))
								or (opbuf(ixOpbufController)=tixVControllerTrigger and (opbuf(ixOpbufCommand)=tixVTriggerCommandSetRng or opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyLwir or opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyVisr or opbuf(ixOpbufCommand)=tixVTriggerCommandSetTfrm))
								or (opbuf(ixOpbufController)=tixVControllerVgaacq and (opbuf(ixOpbufCommand)=tixVVgaacqCommandSetRng)) ) then

						urxlen <= "0" & opbuf(ixOpbufLength) & opbuf(ixOpbufLength+1); -- 2 bytes of CRC included

						i := 0;

						stateOp_next <= stateOpPrepRx;

					else
						stateOp_next <= stateOpIdle;
					end if;

				elsif avllenTxbuf/=0 then
					urxburst <= '0';

					i := 0;

					icrc := avllenTxbuf;
					x := std_logic_vector(to_unsigned(avllenTxbuf + 2, 17));

					if (opbuf(ixOpbufLength)=x(15 downto 8) and opbuf(ixOpbufLength+1)=x(7 downto 0)) then
						utxlen <= x;

						reqTxbuf_next <= '1';

						stateOp_next <= stateOpTxbufA;

					else
						stateOp_next <= stateOpIdle;
					end if;

				elsif avllenRxbuf/=0 then
					i := 0;

					icrc := avllenRxbuf;
					x := std_logic_vector(to_unsigned(avllenRxbuf + 2, 17));

					if (opbuf(ixOpbufLength)=x(15 downto 8) and opbuf(ixOpbufLength+1)=x(7 downto 0)) then
						urxlen <= x;

						reqRxbuf_next <= '1';
						strbDRxbuf_next <= '0';

						stateOp_next <= stateOpPrepRxbuf;

					else
						stateOp_next <= stateOpIdle;
					end if;

				else
					stateOp_next <= stateOpIdle;
				end if;
-- RX OP END

-- TX BEGIN
			elsif stateOp=stateOpPrepTxA then -- arrive here if buffer=cmdretToHostif
				if opbuf(ixOpbufController)=tixVControllerAdxl then
					if opbuf(ixOpbufCommand)=tixVAdxlCommandGetAx then
						txbuf(0) <= adxlGetAxAx(15 downto 8);
						txbuf(1) <= adxlGetAxAx(7 downto 0);
					elsif opbuf(ixOpbufCommand)=tixVAdxlCommandGetAy then
						txbuf(0) <= adxlGetAyAy(15 downto 8);
						txbuf(1) <= adxlGetAyAy(7 downto 0);
					elsif opbuf(ixOpbufCommand)=tixVAdxlCommandGetAz then
						txbuf(0) <= adxlGetAzAz(15 downto 8);
						txbuf(1) <= adxlGetAzAz(7 downto 0);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerLwiracq then
					if opbuf(ixOpbufCommand)=tixVLwiracqCommandGetInfo then
						txbuf(0) <= lwiracqGetInfoTixVBufstate;
						txbuf(1) <= lwiracqGetInfoTkst(31 downto 24);
						txbuf(2) <= lwiracqGetInfoTkst(23 downto 16);
						txbuf(3) <= lwiracqGetInfoTkst(15 downto 8);
						txbuf(4) <= lwiracqGetInfoTkst(7 downto 0);
						txbuf(5) <= lwiracqGetInfoMin(15 downto 8);
						txbuf(6) <= lwiracqGetInfoMin(7 downto 0);
						txbuf(7) <= lwiracqGetInfoMax(15 downto 8);
						txbuf(8) <= lwiracqGetInfoMax(7 downto 0);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerState then
					if opbuf(ixOpbufCommand)=tixVStateCommandGet then
						txbuf(0) <= stateGetTixVBss3State;
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerTkclksrc then
					if opbuf(ixOpbufCommand)=tixVTkclksrcCommandGetTkst then
						txbuf(0) <= tkclksrcGetTkstTkst(31 downto 24);
						txbuf(1) <= tkclksrcGetTkstTkst(23 downto 16);
						txbuf(2) <= tkclksrcGetTkstTkst(15 downto 8);
						txbuf(3) <= tkclksrcGetTkstTkst(7 downto 0);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerVgaacq then
					if opbuf(ixOpbufCommand)=tixVVgaacqCommandGetInfo then
						txbuf(0) <= vgaacqGetInfoTixVBufstate;
						txbuf(1) <= vgaacqGetInfoTkst(31 downto 24);
						txbuf(2) <= vgaacqGetInfoTkst(23 downto 16);
						txbuf(3) <= vgaacqGetInfoTkst(15 downto 8);
						txbuf(4) <= vgaacqGetInfoTkst(7 downto 0);
					end if;

				end if;

				utxlen <= "0" & opbuf(ixOpbufLength) & opbuf(ixOpbufLength+1); -- 2 bytes of CRC included

				x := "0" & opbuf(ixOpbufLength) & opbuf(ixOpbufLength+1);
				icrc := to_integer(unsigned(x)) - 2;

				stateOp_next <= stateOpPrepTxB;

			elsif stateOp=stateOpPrepTxB then
				i := 0;

				utxd_next <= txbuf(0);
				crcd_next <= txbuf(0);

				stateOp_next <= stateOpTxA;

			elsif stateOp=stateOpTxA then -- reqCrc='1', captNotFin='1'
				if (ackCrc='1' and ackUtx='1') then
					stateOp_next <= stateOpTxB;
				end if;

			elsif stateOp=stateOpTxB then -- strbCrcd='1'
				if strbUtxd='0' then
					i := i + 1;

					if i=icrc then
						stateOp_next <= stateOpTxD;
					else
						utxd_next <= txbuf(i);
						crcd_next <= txbuf(i);

						stateOp_next <= stateOpTxC;
					end if;
				end if;

			elsif stateOp=stateOpTxC then
				if strbUtxd='1' then
					stateOp_next <= stateOpTxB;

				elsif ackUtx='0' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpTxD then -- captNotFin='0'
				if dneCrc='1' then
					utxd_next <= crc(15 downto 8);
					stateOp_next <= stateOpTxF;
				end if;

			elsif stateOp=stateOpTxE then
				if dneUtx='1' then
					stateOp_next <= stateOpIdle;

				elsif strbUtxd='0' then
					utxd_next <= crc(7 downto 0); -- i increment not required, only one byte left

					stateOp_next <= stateOpTxF;
				end if;

			elsif stateOp=stateOpTxF then
				if strbUtxd='1' then
					stateOp_next <= stateOpTxE;

				elsif ackUtx='0' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;
				end if;
-- TX END

-- TX BUFFER BEGIN
			elsif stateOp=stateOpTxbufA then
				if ackTxbuf='1' then
					i := 0;

					utxd_next <= dTxbuf;
					crcd_next <= dTxbuf;

					stateOp_next <= stateOpTxbufB;
				end if;

			elsif stateOp=stateOpTxbufB then -- reqCrc='1', captNotFin='1'
				if (ackCrc='1' and ackUtx='1') then
					stateOp_next <= stateOpTxbufC;
				end if;

			elsif stateOp=stateOpTxbufC then -- strbCrcd='1'
				if strbUtxd='0' then
					strbDTxbuf_next <= '1';

					i := i + 1;

					if i=icrc then
						stateOp_next <= stateOpTxbufH;
					else
						stateOp_next <= stateOpTxbufD;
					end if;
				end if;

			elsif stateOp=stateOpTxbufD then
				strbDTxbuf_next <= '0';

				stateOp_next <= stateOpTxbufF;

			elsif stateOp=stateOpTxbufE then
				utxd_next <= dTxbuf;
				crcd_next <= dTxbuf;

				stateOp_next <= stateOpTxbufG;

			elsif stateOp=stateOpTxbufF then
				stateOp_next <= stateOpTxbufE;

			elsif stateOp=stateOpTxbufG then
				if strbUtxd='1' then
					stateOp_next <= stateOpTxbufC;

				elsif ackUtx='0' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpTxbufH then -- captNotFin='0'
				if dneCrc='1' then
					utxd_next <= crc(15 downto 8);
					stateOp_next <= stateOpTxbufJ;
				end if;

			elsif stateOp=stateOpTxbufI then
				if dneUtx='1' then
					dneTxbuf_next <= '1';

					stateOp_next <= stateOpTxbufK;

				elsif strbUtxd='0' then
					utxd_next <= crc(7 downto 0); -- i increment not required, only one byte left

					stateOp_next <= stateOpTxbufJ;
				end if;

			elsif stateOp=stateOpTxbufJ then
				if strbUtxd='1' then
					stateOp_next <= stateOpTxbufI;

				elsif ackUtx='0' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpTxbufK then
				if ackTxbuf='0' then
					stateOp_next <= stateOpIdle;
				end if;
-- TX BUFFER END

-- RX BEGIN
			elsif stateOp=stateOpPrepRx then -- arrive here if buffer=hostifToCmdinv
				if (ackCrc='0' and ackUrx='0') then
					torestart_next <= '1';

					stateOp_next <= stateOpRxA;
				end if;

			elsif stateOp=stateOpRxA then
				if (ackCrc='1' and ackUrx='1') then
					stateOp_next <= stateOpRxB;

				elsif timeout2='1' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxB then
				if strbUrxd='1' then
					rxbuf(i) <= urxd;

					crcd_next <= urxd;

					torestart_next <= '1';

					stateOp_next <= stateOpRxC;

				elsif ackUrx='0' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpRxC then -- strbCrcd='1'
				if strbUrxd='0' then
					i := i + 1;

					stateOp_next <= stateOpRxB;

				elsif dneUrx='1' then
					stateOp_next <= stateOpRxD;

				elsif timeout='1' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxD then
				if dneCrc='1' then
					if crc=x"0000" then
						commok_sig_next <= '1';
						stateOp_next <= stateOpCopyRxA;
					else
						commok_sig_next <= '0';
						stateOp_next <= stateOpIdle;
					end if;
				end if;

			elsif stateOp=stateOpCopyRxA then
				stateOp_next <= stateOpCopyRxB;

				-- copy takes place on falling edge

			elsif stateOp=stateOpCopyRxB then
				if ackInv='1' then
					utxlen <= "0" & x"0002"; -- tx 2x 0x00 (CRC of empty set)
					utxd_next <= x"00";
					stateOp_next <= stateOpTxackA;
				end if;
-- RX END

-- RX BUFFER BEGIN
			elsif stateOp=stateOpPrepRxbuf then
				if (ackCrc='0' and ackUrx='0' and ackRxbuf='1') then
					torestart_next <= '1';

					stateOp_next <= stateOpRxbufA;
				end if;

			elsif stateOp=stateOpRxbufA then
				if (ackCrc='1' and ackUrx='1') then
					stateOp_next <= stateOpRxbufB;

				elsif timeout2='1' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxbufB then
				if strbUrxd='1' then
					dRxbuf_next <= urxd;
					strbDRxbuf_next <= '1';

					crcd_next <= urxd;

					torestart_next <= '1';

					stateOp_next <= stateOpRxbufC;

				elsif ackUrx='0' then
					stateOp_next <= stateOpIdle;
				end if;

			elsif stateOp=stateOpRxbufC then -- strbCrcd='1'
				if strbUrxd='0' then
					i := i + 1;

					if i<icrc then
						strbDRxbuf_next <= '0';
					end if;

					stateOp_next <= stateOpRxbufB;

				elsif dneUrx='1' then
					stateOp_next <= stateOpRxbufD;

				elsif timeout='1' then
					commok_sig_next <= '0';
					stateOp_next <= stateOpIdle;

				else
					torestart_next <= '0';
				end if;

			elsif stateOp=stateOpRxbufD then
				if dneCrc='1' then
					if crc=x"0000" then
						dneRxbuf_next <= '1';
						commok_sig_next <= '1';
						stateOp_next <= stateOpRxbufE;
					else
						commok_sig_next <= '0';
						stateOp_next <= stateOpIdle;
					end if;
				end if;

			elsif stateOp=stateOpRxbufE then
				if ackRxbuf='0' then
					reqRxbuf_next <= '0';

					utxlen <= "0" & x"0002"; -- tx 2x 0x00 (CRC of empty set)
					utxd_next <= x"00";
					stateOp_next <= stateOpTxackA;
				end if;
-- RX BUFFER END

			elsif stateOp=stateOpTxackA then
				if ackUtx='1' then
					stateOp_next <= stateOpTxackB;
				end if;

			elsif stateOp=stateOpTxackB then
				if dneUtx='1' then
					stateOp_next <= stateOpIdle;
				end if;
			end if;
		end if;
	end process;

	process (reset, mclk, stateOp)
	begin
		if reset='1' then
			alignSetSeqLenSeq_sig <= x"20";
			alignSetSeqSeq_sig <= x"00102030405060708090A0B0C0D0E0F0F0E0D0C0B0A090807060504030201000";
			ledSetTon15Ton15_sig <= x"01"; -- was x"14"
			ledSetTon60Ton60_sig <= x"01"; -- was x"14"
			lwiracqSetRngRng_sig <= fls8;
			lwirifSetRngRng_sig <= tru8;
			servoSetThetaTheta_sig <= x"FE9C"; -- was x"0000", now -40deg
			servoSetPhiPhi_sig <= x"010B"; -- was x"0000", now 30deg
			tkclksrcSetTkstTkst_sig <= x"00000000";
			triggerSetRngRng_sig <= fls8;
			triggerSetRngBtnNotTfrm_sig <= fls8;
			triggerSetTdlyLwirTdlyLwir_sig <= x"0000";
			triggerSetTdlyVisrTdlyVisr_sig <= x"0000";
			triggerSetTfrmTfrm_sig <= x"000A";
			vgaacqSetRngRng_sig <= fls8;
		end if;

		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			torestart <= torestart_next;
			crcd <= crcd_next;
			utxd <= utxd_next;
			commok_sig <= commok_sig_next;
			reqReset_sig <= reqReset_sig_next;
			reqTxbuf <= reqTxbuf_next;
			dneTxbuf <= dneTxbuf_next;
			strbDTxbuf <= strbDTxbuf_next;
			reqRxbuf <= reqRxbuf_next;
			dneRxbuf <= dneRxbuf_next;
			dRxbuf <= dRxbuf_next;
			strbDRxbuf <= strbDRxbuf_next;

			if stateOp_next=stateOpCopyRxB then
				if opbuf(ixOpbufController)=tixVControllerAlign then
					if opbuf(ixOpbufCommand)=tixVAlignCommandSetSeq then
						alignSetSeqLenSeq_sig <= rxbuf(0);
						alignSetSeqSeq_sig(255 downto 248) <= rxbuf(1);
						alignSetSeqSeq_sig(247 downto 240) <= rxbuf(2);
						alignSetSeqSeq_sig(239 downto 232) <= rxbuf(3);
						alignSetSeqSeq_sig(231 downto 224) <= rxbuf(4);
						alignSetSeqSeq_sig(223 downto 216) <= rxbuf(5);
						alignSetSeqSeq_sig(215 downto 208) <= rxbuf(6);
						alignSetSeqSeq_sig(207 downto 200) <= rxbuf(7);
						alignSetSeqSeq_sig(199 downto 192) <= rxbuf(8);
						alignSetSeqSeq_sig(191 downto 184) <= rxbuf(9);
						alignSetSeqSeq_sig(183 downto 176) <= rxbuf(10);
						alignSetSeqSeq_sig(175 downto 168) <= rxbuf(11);
						alignSetSeqSeq_sig(167 downto 160) <= rxbuf(12);
						alignSetSeqSeq_sig(159 downto 152) <= rxbuf(13);
						alignSetSeqSeq_sig(151 downto 144) <= rxbuf(14);
						alignSetSeqSeq_sig(143 downto 136) <= rxbuf(15);
						alignSetSeqSeq_sig(135 downto 128) <= rxbuf(16);
						alignSetSeqSeq_sig(127 downto 120) <= rxbuf(17);
						alignSetSeqSeq_sig(119 downto 112) <= rxbuf(18);
						alignSetSeqSeq_sig(111 downto 104) <= rxbuf(19);
						alignSetSeqSeq_sig(103 downto 96) <= rxbuf(20);
						alignSetSeqSeq_sig(95 downto 88) <= rxbuf(21);
						alignSetSeqSeq_sig(87 downto 80) <= rxbuf(22);
						alignSetSeqSeq_sig(79 downto 72) <= rxbuf(23);
						alignSetSeqSeq_sig(71 downto 64) <= rxbuf(24);
						alignSetSeqSeq_sig(63 downto 56) <= rxbuf(25);
						alignSetSeqSeq_sig(55 downto 48) <= rxbuf(26);
						alignSetSeqSeq_sig(47 downto 40) <= rxbuf(27);
						alignSetSeqSeq_sig(39 downto 32) <= rxbuf(28);
						alignSetSeqSeq_sig(31 downto 24) <= rxbuf(29);
						alignSetSeqSeq_sig(23 downto 16) <= rxbuf(30);
						alignSetSeqSeq_sig(15 downto 8) <= rxbuf(31);
						alignSetSeqSeq_sig(7 downto 0) <= rxbuf(32);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerLed then
					if opbuf(ixOpbufCommand)=tixVLedCommandSetTon15 then
						ledSetTon15Ton15_sig <= rxbuf(0);
					elsif opbuf(ixOpbufCommand)=tixVLedCommandSetTon60 then
						ledSetTon60Ton60_sig <= rxbuf(0);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerLwiracq then
					if opbuf(ixOpbufCommand)=tixVLwiracqCommandSetRng then
						lwiracqSetRngRng_sig <= rxbuf(0);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerLwirif then
					if opbuf(ixOpbufCommand)=tixVLwirifCommandSetRng then
						lwirifSetRngRng_sig <= rxbuf(0);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerServo then
					if opbuf(ixOpbufCommand)=tixVServoCommandSetTheta then
						servoSetThetaTheta_sig(15 downto 8) <= rxbuf(0);
						servoSetThetaTheta_sig(7 downto 0) <= rxbuf(1);
					elsif opbuf(ixOpbufCommand)=tixVServoCommandSetPhi then
						servoSetPhiPhi_sig(15 downto 8) <= rxbuf(0);
						servoSetPhiPhi_sig(7 downto 0) <= rxbuf(1);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerTkclksrc then
					if opbuf(ixOpbufCommand)=tixVTkclksrcCommandSetTkst then
						tkclksrcSetTkstTkst_sig(31 downto 24) <= rxbuf(0);
						tkclksrcSetTkstTkst_sig(23 downto 16) <= rxbuf(1);
						tkclksrcSetTkstTkst_sig(15 downto 8) <= rxbuf(2);
						tkclksrcSetTkstTkst_sig(7 downto 0) <= rxbuf(3);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerTrigger then
					if opbuf(ixOpbufCommand)=tixVTriggerCommandSetRng then
						triggerSetRngRng_sig <= rxbuf(0);
						triggerSetRngBtnNotTfrm_sig <= rxbuf(1);
					elsif opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyLwir then
						triggerSetTdlyLwirTdlyLwir_sig(15 downto 8) <= rxbuf(0);
						triggerSetTdlyLwirTdlyLwir_sig(7 downto 0) <= rxbuf(1);
					elsif opbuf(ixOpbufCommand)=tixVTriggerCommandSetTdlyVisr then
						triggerSetTdlyVisrTdlyVisr_sig(15 downto 8) <= rxbuf(0);
						triggerSetTdlyVisrTdlyVisr_sig(7 downto 0) <= rxbuf(1);
					elsif opbuf(ixOpbufCommand)=tixVTriggerCommandSetTfrm then
						triggerSetTfrmTfrm_sig(15 downto 8) <= rxbuf(0);
						triggerSetTfrmTfrm_sig(7 downto 0) <= rxbuf(1);
					end if;

				elsif opbuf(ixOpbufController)=tixVControllerVgaacq then
					if opbuf(ixOpbufCommand)=tixVVgaacqCommandSetRng then
						vgaacqSetRngRng_sig <= rxbuf(0);
					end if;

				end if;

			end if;
		end if;
	end process;

end Hostif;


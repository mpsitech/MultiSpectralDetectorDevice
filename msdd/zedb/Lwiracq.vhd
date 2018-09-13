-- file Lwiracq.vhd
-- Lwiracq easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 9 Aug 2018
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Lwiracq is
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

		tkclksrcGetTkstTkst: in std_logic_vector(31 downto 0);

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
		miso: in std_logic
	);
end Lwiracq;

architecture Lwiracq of Lwiracq is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Dpbram_v1_0_size38kB is
		port (
			clkA: in std_logic;

			enA: in std_logic;
			weA: in std_logic;

			aA: in std_logic_vector(15 downto 0);
			drdA: out std_logic_vector(7 downto 0);
			dwrA: in std_logic_vector(7 downto 0);

			clkB: in std_logic;

			enB: in std_logic;
			weB: in std_logic;

			aB: in std_logic_vector(15 downto 0);
			drdB: out std_logic_vector(7 downto 0);
			dwrB: in std_logic_vector(7 downto 0)
		);
	end component;

	component Spimaster_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			cpol: std_logic := '0';
			cpha: std_logic := '0';

			nssByteNotXfer: std_logic := '0';

			fSclk: natural range 1 to 50000000 := 10000000;
			Nstop: natural range 1 to 8 := 1
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(16 downto 0);

			send: in std_logic_vector(7 downto 0);
			strbSend: out std_logic;

			recv: out std_logic_vector(7 downto 0);
			strbRecv: out std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	constant tixVBufstateIdle: std_logic_vector(7 downto 0) := x"00";
	constant tixVBufstateEmpty: std_logic_vector(7 downto 0) := x"01";
	constant tixVBufstateAbuf: std_logic_vector(7 downto 0) := x"02";
	constant tixVBufstateBbuf: std_logic_vector(7 downto 0) := x"03";

	---- {a/b}buf mutex management (buf)
	type stateBuf_t is (
		stateBufInit,
		stateBufReady,
		stateBufAck
	);
	signal stateBuf: stateBuf_t := stateBufInit;

	type lock_t is (lockIdle, lockBufB, lockOp);
	signal abufLock: lock_t;
	signal abufFull: std_logic;

	signal bbufLock: lock_t;
	signal bbufFull: std_logic;

	-- IP sigs.buf.cust --- INSERT

	---- {a/b}buf B/hostif-facing operation (bufB)
	type stateBufB_t is (
		stateBufBInit,
		stateBufBReady,
		stateBufBTrylock,
		stateBufBReadA, stateBufBReadB,
		stateBufBDone
	);
	signal stateBufB: stateBufB_t := stateBufBInit;

	signal enAbufB: std_logic;
	signal enBbufB: std_logic;

	signal infoTixVBufstate: std_logic_vector(7 downto 0);
	signal getInfoTkst_sig: std_logic_vector(31 downto 0);
	signal getInfoMin_sig: std_logic_vector(15 downto 0);
	signal getInfoMax_sig: std_logic_vector(15 downto 0);

	signal aBufB_vec: std_logic_vector(15 downto 0);
	signal aBufB: natural range 0 to 38912;

	signal ackBufToHostif: std_logic;
	signal ackAbufToHostif_sig: std_logic;
	signal ackBbufToHostif_sig: std_logic;

	-- IP sigs.bufB.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpReady,
		stateOpTimeoutA, stateOpTimeoutB,
		stateOpLoopSeg,
		stateOpLoopPkt,
		stateOpInterpkg,
		stateOpHdrA, stateOpHdrB,
		stateOpTrylockA, stateOpTrylockB,
		stateOpDataA, stateOpDataB, stateOpDataC,
		stateOpSkip,
		stateOpCancel,
		stateOpDoneA, stateOpDoneB
	);
	signal stateOp: stateOp_t := stateOpInit;

	signal bufrun: std_logic;

	signal infoTkstA: std_logic_vector(31 downto 0);
	signal infoTkstB: std_logic_vector(31 downto 0);
	signal infoMinA: std_logic_vector(15 downto 0);
	signal infoMinB: std_logic_vector(15 downto 0);
	signal infoMaxA: std_logic_vector(15 downto 0);
	signal infoMaxB: std_logic_vector(15 downto 0);

	signal latestBNotA: std_logic;

	signal enAbuf: std_logic;
	signal enBbuf: std_logic;

	signal aBuf: std_logic_vector(15 downto 0);
	signal dwrBuf: std_logic_vector(7 downto 0);
	signal spilen: std_logic_vector(16 downto 0);
	signal ackInvSetRng_sig: std_logic;

	-- IP sigs.op.cust --- INSERT

	---- mySpi
	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	---- handshake
	-- op to buf
	signal reqOpToBufAbufLock: std_logic;
	signal ackOpToBufAbufLock: std_logic;
	signal dnyOpToBufAbufLock: std_logic;

	-- op to buf
	signal reqOpToBufAbufSetFull: std_logic;
	signal ackOpToBufAbufSetFull: std_logic;

	-- op to buf
	signal reqOpToBufBbufLock: std_logic;
	signal ackOpToBufBbufLock: std_logic;
	signal dnyOpToBufBbufLock: std_logic;

	-- op to buf
	signal reqOpToBufBbufSetFull: std_logic;
	signal ackOpToBufBbufSetFull: std_logic;

	-- bufB to buf
	signal reqBufBToBufAbufLock: std_logic;
	signal ackBufBToBufAbufLock: std_logic;
	signal dnyBufBToBufAbufLock: std_logic;

	-- bufB to buf
	signal reqBufBToBufAbufClear: std_logic;
	signal ackBufBToBufAbufClear: std_logic;

	-- bufB to buf
	signal reqBufBToBufBbufLock: std_logic;
	signal ackBufBToBufBbufLock: std_logic;
	signal dnyBufBToBufBbufLock: std_logic;

	-- bufB to buf
	signal reqBufBToBufBbufClear: std_logic;
	signal ackBufBToBufBbufClear: std_logic;

	-- op to mySpi
	signal reqSpi: std_logic;
	signal ackSpi: std_logic;
	signal dneSpi: std_logic;

	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myAbuf : Dpbram_v1_0_size38kB
		port map (
			clkA => mclk,

			enA => enAbuf,
			weA => '1',

			aA => aBuf,
			drdA => open,
			dwrA => dwrBuf,

			clkB => mclk,

			enB => enAbufB,
			weB => '0',

			aB => aBufB_vec,
			drdB => dAbufToHostif,
			dwrB => x"00"
		);

	myBbuf : Dpbram_v1_0_size38kB
		port map (
			clkA => mclk,

			enA => enBbuf,
			weA => '1',

			aA => aBuf,
			drdA => open,
			dwrA => dwrBuf,

			clkB => mclk,

			enB => enBbufB,
			weB => '0',

			aB => aBufB_vec,
			drdB => dBbufToHostif,
			dwrB => x"00"
		);

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '1',
			cpha => '1',

			nssByteNotXfer => '0',

			fSclk => 12500000,
			Nstop => 1
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqSpi,
			ack => ackSpi,
			dne => dneSpi,

			len => spilen,

			send => x"00",
			strbSend => open,

			recv => spirecv,
			strbRecv => strbSpirecv,

			nss => nss,
			sclk => sclk,
			mosi => open,
			miso => miso
		);

	------------------------------------------------------------------------
	-- implementation: {a/b}buf mutex management (buf)
	------------------------------------------------------------------------

	-- IP impl.buf.wiring --- BEGIN
	-- IP impl.buf.wiring --- END

	-- IP impl.buf.rising --- BEGIN
	process (reset, mclk, stateBuf)
		-- IP impl.buf.rising.vars --- BEGIN
		-- IP impl.buf.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.buf.rising.asyncrst --- BEGIN
			stateBuf <= stateBufInit;
			abufLock <= lockIdle;
			abufFull <= '0';
			bbufLock <= lockIdle;
			bbufFull <= '0';
			ackOpToBufAbufLock <= '0';
			dnyOpToBufAbufLock <= '0';
			ackOpToBufAbufSetFull <= '0';
			ackOpToBufBbufLock <= '0';
			dnyOpToBufBbufLock <= '0';
			ackOpToBufBbufSetFull <= '0';
			ackBufBToBufAbufLock <= '0';
			dnyBufBToBufAbufLock <= '0';
			ackBufBToBufAbufClear <= '0';
			ackBufBToBufBbufLock <= '0';
			dnyBufBToBufBbufLock <= '0';
			ackBufBToBufBbufClear <= '0';
			-- IP impl.buf.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBuf=stateBufInit or bufrun='0') then
				-- IP impl.buf.rising.syncrst --- BEGIN
				abufLock <= lockIdle;
				abufFull <= '0';
				bbufLock <= lockIdle;
				bbufFull <= '0';
				ackOpToBufAbufLock <= '0';
				dnyOpToBufAbufLock <= '0';
				ackOpToBufAbufSetFull <= '0';
				ackOpToBufBbufLock <= '0';
				dnyOpToBufBbufLock <= '0';
				ackOpToBufBbufSetFull <= '0';
				ackBufBToBufAbufLock <= '0';
				dnyBufBToBufAbufLock <= '0';
				ackBufBToBufAbufClear <= '0';
				ackBufBToBufBbufLock <= '0';
				dnyBufBToBufBbufLock <= '0';
				ackBufBToBufBbufClear <= '0';
				-- IP impl.buf.rising.syncrst --- END

				if bufrun='0' then
					stateBuf <= stateBufInit;

				else
					stateBuf <= stateBufReady;
				end if;

			elsif stateBuf=stateBufReady then
				if reqOpToBufAbufLock='1' then
					-- IP impl.buf.rising.ready.opAbufLock --- IBEGIN
					if abufLock=lockIdle then
						abufLock <= lockOp;
						abufFull <= '0';
						ackOpToBufAbufLock <= '1';
					elsif abufLock=lockBufB then
						dnyOpToBufAbufLock <= '1';
					elsif abufLock=lockOp then
						abufLock <= lockIdle; -- unlock
						ackOpToBufAbufLock <= '1';
					end if;
					-- IP impl.buf.rising.ready.opAbufLock --- IEND

					stateBuf <= stateBufAck;

				elsif reqOpToBufAbufSetFull='1' then
					-- IP impl.buf.rising.ready.abufFull --- IBEGIN
					if abufLock=lockOp then
						abufLock <= lockIdle;
						abufFull <= '1';
						ackOpToBufAbufSetFull <= '1';
					end if;
					-- IP impl.buf.rising.ready.abufFull --- IEND

					stateBuf <= stateBufAck;

				elsif reqOpToBufBbufLock='1' then
					-- IP impl.buf.rising.ready.opBbufLock --- IBEGIN
					if bbufLock=lockIdle then
						bbufLock <= lockOp;
						bbufFull <= '0';
						ackOpToBufBbufLock <= '1';
					elsif bbufLock=lockBufB then
						dnyOpToBufBbufLock <= '1';
					elsif bbufLock=lockOp then
						bbufLock <= lockIdle; -- unlock
						ackOpToBufBbufLock <= '1';
					end if;
					-- IP impl.buf.rising.ready.opBbufLock --- IEND

					stateBuf <= stateBufAck;

				elsif reqOpToBufBbufSetFull='1' then
					-- IP impl.buf.rising.ready.bbufFull --- IBEGIN
					if bbufLock=lockOp then
						bbufLock <= lockIdle;
						bbufFull <= '1';
						ackOpToBufBbufSetFull <= '1';
					end if;
					-- IP impl.buf.rising.ready.bbufFull --- IEND

					stateBuf <= stateBufAck;

				elsif reqBufBToBufAbufLock='1' then
					-- IP impl.buf.rising.ready.bufBAbufLock --- IBEGIN
					if abufLock=lockIdle then
						abufLock <= lockBufB;
						ackBufBToBufAbufLock <= '1';
					elsif abufLock=lockBufB then
						abufLock <= lockIdle; -- unlock
						ackBufBToBufAbufLock <= '1';
					elsif abufLock=lockOp then
						dnyBufBToBufAbufLock <= '1';
					end if;
					-- IP impl.buf.rising.ready.bufBAbufLock --- IEND

					stateBuf <= stateBufAck;

				elsif reqBufBToBufAbufClear='1' then
					-- IP impl.buf.rising.ready.abufClear --- IBEGIN
					if abufLock=lockBufB then
						abufLock <= lockIdle;
						abufFull <= '0';
						ackBufBToBufAbufClear <= '1';
					end if;
					-- IP impl.buf.rising.ready.abufClear --- IEND

					stateBuf <= stateBufAck;

				elsif reqBufBToBufBbufLock='1' then
					-- IP impl.buf.rising.ready.bufBBbufLock --- IBEGIN
					if bbufLock=lockIdle then
						bbufLock <= lockBufB;
						ackBufBToBufBbufLock <= '1';
					elsif bbufLock=lockBufB then
						bbufLock <= lockIdle; -- unlock
						ackBufBToBufBbufLock <= '1';
					elsif bbufLock=lockOp then
						dnyBufBToBufBbufLock <= '1';
					end if;
					-- IP impl.buf.rising.ready.bufBBbufLock --- IEND

					stateBuf <= stateBufAck;

				elsif reqBufBToBufBbufClear='1' then
					-- IP impl.buf.rising.ready.bbufClear --- IBEGIN
					if bbufLock=lockBufB then
						bbufLock <= lockIdle;
						bbufFull <= '0';
						ackBufBToBufBbufClear <= '1';
					end if;
					-- IP impl.buf.rising.ready.bbufClear --- IEND

					stateBuf <= stateBufAck;
				end if;

			elsif stateBuf=stateBufAck then
				if ((ackOpToBufAbufLock='1' or dnyOpToBufAbufLock='1') and reqOpToBufAbufLock='0') then
					-- IP impl.buf.rising.ack.opAbufLock --- IBEGIN
					ackOpToBufAbufLock <= '0';
					dnyOpToBufAbufLock <= '0';
					-- IP impl.buf.rising.ack.opAbufLock --- IEND

					stateBuf <= stateBufReady;

				elsif (ackOpToBufAbufSetFull='1' and reqOpToBufAbufSetFull='0') then
					ackOpToBufAbufSetFull <= '0'; -- IP impl.buf.rising.ack.abufFull --- ILINE

					stateBuf <= stateBufReady;

				elsif ((ackOpToBufBbufLock='1' or dnyOpToBufBbufLock='1') and reqOpToBufBbufLock='0') then
					-- IP impl.buf.rising.ack.opBbufLock --- IBEGIN
					ackOpToBufBbufLock <= '0';
					dnyOpToBufBbufLock <= '0';
					-- IP impl.buf.rising.ack.opBbufLock --- IEND

					stateBuf <= stateBufReady;

				elsif (ackOpToBufBbufSetFull='1' and reqOpToBufBbufSetFull='0') then
					ackOpToBufBbufSetFull <= '0'; -- IP impl.buf.rising.ack.bbufFull --- ILINE

					stateBuf <= stateBufReady;

				elsif ((ackBufBToBufAbufLock='1' or dnyBufBToBufAbufLock='1') and reqBufBToBufAbufLock='0') then
					-- IP impl.buf.rising.ack.bufBAbufLock --- IBEGIN
					ackBufBToBufAbufLock <= '0';
					dnyBufBToBufAbufLock <= '0';
					-- IP impl.buf.rising.ack.bufBAbufLock --- IEND

					stateBuf <= stateBufReady;

				elsif (ackBufBToBufAbufClear='1' and reqBufBToBufAbufClear='0') then
					ackBufBToBufAbufClear <= '0'; -- IP impl.buf.rising.ack.abufClear --- ILINE

					stateBuf <= stateBufReady;

				elsif ((ackBufBToBufBbufLock='1' or dnyBufBToBufBbufLock='1') and reqBufBToBufBbufLock='0') then
					-- IP impl.buf.rising.ack.bufBBbufLock --- IBEGIN
					ackBufBToBufBbufLock <= '0';
					dnyBufBToBufBbufLock <= '0';
					-- IP impl.buf.rising.ack.bufBBbufLock --- IEND

					stateBuf <= stateBufReady;

				elsif (ackBufBToBufBbufClear='1' and reqBufBToBufBbufClear='0') then
					ackBufBToBufBbufClear <= '0'; -- IP impl.buf.rising.ack.bbufClear --- ILINE

					stateBuf <= stateBufReady;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.buf.rising --- END

	------------------------------------------------------------------------
	-- implementation: {a/b}buf B/hostif-facing operation (bufB)
	------------------------------------------------------------------------

	-- IP impl.bufB.wiring --- RBEGIN
	enAbufB <= '1' when (abufLock=lockBufB and strbDAbufToHostif='0' and stateBufB=stateBufBReadA) else '0';
	enBbufB <= '1' when (bbufLock=lockBufB and strbDBbufToHostif='0' and stateBufB=stateBufBReadA) else '0';

	aBufB_vec <= std_logic_vector(to_unsigned(aBufB, 16));

	infoTixVBufstate <= tixVBufstateAbuf when ((latestBNotA='0' and abufLock=lockIdle and abufFull='1') or (latestBNotA='1' and bbufLock=lockOp and abufFull='1'))
				else tixVBufstateBbuf when ((latestBNotA='0' and abufLock=lockOp and bbufFull='1') or (latestBNotA='1' and bbufLock=lockIdle and bbufFull='1'))
				else tixVBufstateEmpty when bufrun='1'
				else tixVBufstateIdle; -- op can't have a lock on abuf and bbuf simultaneously

	getInfoTixVBufstate <= infoTixVBufstate;
	getInfoTkst_sig <= infoTkstB when infoTixVBufstate=tixVBufstateBbuf else infoTkstA;
	getInfoTkst <= getInfoTkst_sig;
	getInfoMin_sig <= infoMinB when infoTixVBufstate=tixVBufstateBbuf else infoMinA;
	getInfoMin <= getInfoMin_sig;
	getInfoMax_sig <= infoMaxB when infoTixVBufstate=tixVBufstateBbuf else infoMaxA;
	getInfoMax <= getInfoMax_sig;

	avllenAbufToHostif <= std_logic_vector(to_unsigned(38400, 16)) when (abufLock=lockIdle and abufFull='1') else (others => '0');
	avllenBbufToHostif <= std_logic_vector(to_unsigned(38400, 16)) when (bbufLock=lockIdle and bbufFull='1') else (others => '0');

	ackAbufToHostif_sig <= ackBufToHostif when abufLock=lockBufB else '0';
	ackAbufToHostif <= ackAbufToHostif_sig;
	ackBbufToHostif_sig <= ackBufToHostif when bbufLock=lockBufB else '0';
	ackBbufToHostif <= ackBbufToHostif_sig;
	-- IP impl.bufB.wiring --- REND

	-- IP impl.bufB.rising --- BEGIN
	process (reset, mclk, stateBufB)
		-- IP impl.bufB.rising.vars --- BEGIN
		-- IP impl.bufB.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.bufB.rising.asyncrst --- BEGIN
			stateBufB <= stateBufBInit;
			aBufB <= 0;
			ackBufToHostif <= '0';
			reqBufBToBufAbufLock <= '0';
			reqBufBToBufAbufClear <= '0';
			reqBufBToBufBbufLock <= '0';
			reqBufBToBufBbufClear <= '0';
			-- IP impl.bufB.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBufB=stateBufBInit or bufrun='0') then
				-- IP impl.bufB.rising.syncrst --- BEGIN
				aBufB <= 0;
				ackBufToHostif <= '0';
				reqBufBToBufAbufLock <= '0';
				reqBufBToBufAbufClear <= '0';
				reqBufBToBufBbufLock <= '0';
				reqBufBToBufBbufClear <= '0';
				-- IP impl.bufB.rising.syncrst --- END

				if bufrun='0' then
					stateBufB <= stateBufBInit;

				else
					stateBufB <= stateBufBReady;
				end if;

			elsif stateBufB=stateBufBReady then
				if (infoTixVBufstate=tixVBufstateAbuf and reqAbufToHostif='1') then
					reqBufBToBufAbufLock <= '1'; -- IP impl.bufB.rising.ready.aprep --- ILINE

					stateBufB <= stateBufBTrylock;

				elsif (infoTixVBufstate=tixVBufstateBbuf and reqBbufToHostif='1') then
					reqBufBToBufBbufLock <= '1'; -- IP impl.bufB.rising.ready.bprep --- ILINE

					stateBufB <= stateBufBTrylock;
				end if;

			elsif stateBufB=stateBufBTrylock then
				if (ackBufBToBufAbufLock='1' or ackBufBToBufBbufLock='1') then
					-- IP impl.bufB.rising.trylock.ack --- IBEGIN
					reqBufBToBufAbufLock <= '0';
					reqBufBToBufBbufLock <= '0';
					-- IP impl.bufB.rising.trylock.ack --- IEND

					stateBufB <= stateBufBReadA;

				elsif (dnyBufBToBufAbufLock='1' or dnyBufBToBufBbufLock='1') then
					stateBufB <= stateBufBInit;
				end if;

			elsif stateBufB=stateBufBReadA then
				if abufLock=lockBufB then
					if dneAbufToHostif='1' then
						-- IP impl.bufB.rising.readA.adne --- IBEGIN
						reqBufBToBufAbufClear <= '1';
						ackBufToHostif <= '0';
						-- IP impl.bufB.rising.readA.adne --- IEND

						stateBufB <= stateBufBDone;

					elsif reqAbufToHostif='0' then
						-- IP impl.bufB.rising.readA.acnc --- IBEGIN
						reqBufBToBufAbufLock <= '1'; -- unlock
						ackBufToHostif <= '0';
						-- IP impl.bufB.rising.readA.acnc --- IEND

						stateBufB <= stateBufBDone;

					elsif strbDAbufToHostif='0' then
						ackBufToHostif <= '1'; -- IP impl.bufB.rising.readA.astep --- ILINE

						stateBufB <= stateBufBReadB;
					end if;

				elsif bbufLock=lockBufB then
					if dneBbufToHostif='1' then
						-- IP impl.bufB.rising.readA.bdne --- IBEGIN
						reqBufBToBufBbufClear <= '1';
						ackBufToHostif <= '0';
						-- IP impl.bufB.rising.readA.bdne --- IEND

						stateBufB <= stateBufBDone;

					elsif reqBbufToHostif='0' then
						-- IP impl.bufB.rising.readA.bcnc --- IBEGIN
						reqBufBToBufBbufLock <= '1'; -- unlock
						ackBufToHostif <= '0';
						-- IP impl.bufB.rising.readA.bcnc --- IEND

						stateBufB <= stateBufBDone;

					elsif strbDBbufToHostif='0' then
						ackBufToHostif <= '1'; -- IP impl.bufB.rising.readA.bstep --- ILINE

						stateBufB <= stateBufBReadB;
					end if;
				end if;

			elsif stateBufB=stateBufBReadB then
				if ((abufLock=lockBufB and strbDAbufToHostif='1') or (bbufLock=lockBufB and strbDBbufToHostif='1')) then
					aBufB <= aBufB + 1; -- IP impl.bufB.rising.readB.inc --- ILINE

					stateBufB <= stateBufBReadA;
				end if;

			elsif stateBufB=stateBufBDone then
				if (ackBufBToBufAbufLock='1' or ackBufBToBufAbufClear='1' or ackBufBToBufBbufLock='1' or ackBufBToBufBbufClear='1') then
					stateBufB <= stateBufBInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.bufB.rising --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	bufrun <= '0' when (stateOp=stateOpInit or stateOp=stateOpInv) else '1';

	enAbuf <= '1' when (abufLock=lockOp and stateOp=stateOpDataC) else '0';
	enBbuf <= '1' when (bbufLock=lockOp and stateOp=stateOpDataC) else '0';

	reqSpi <= '1' when (stateOp=stateOpHdrA or stateOp=stateOpHdrB or stateOp=stateOpTrylockA or stateOp=stateOpTrylockB or stateOp=stateOpDataA or stateOp=stateOpDataB or stateOp=stateOpDataC or stateOp=stateOpSkip) else '0';

	ackInvSetRng_sig <= '1' when stateOp=stateOpInv else '0';
	ackInvSetRng <= ackInvSetRng_sig;
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		constant sizeHdrbuf: natural := 4;

		type hdrbuf_t is array (0 to sizeHdrbuf-1) of std_logic_vector(7 downto 0);
		variable hdrbuf: hdrbuf_t;
		
		constant ixHdrbufSeg: natural := 0;
		constant ixHdrbufPkt: natural := 1;

		variable seg: natural range 1 to 5;
		variable pkt: natural range 0 to 60;

		variable val: std_logic_vector(15 downto 0);
		variable min: natural range 0 to 65535;
		variable max: natural range 0 to 65535;

		variable errcnt: natural range 0 to 500;

		variable i: natural range 0 to 4; -- packet header bytes

		variable k: natural range 0 to 10*(fMclk/1000); -- 10us
		variable l: natural range 0 to 50; -- 5ms (using tkclk)
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- RBEGIN
			stateOp <= stateOpInit;
			latestBNotA <= '0';
			aBuf <= (others => '0');
			dwrBuf <= (others => '0');

			infoTkstA <= (others => '0');
			infoTkstB <= (others => '0');
			infoMinA <= (others => '0');
			infoMinB <= (others => '0');
			infoMaxA <= (others => '0');
			infoMaxB <= (others => '0');

			reqOpToBufAbufLock <= '0';
			reqOpToBufAbufSetFull <= '0';
			reqOpToBufBbufLock <= '0';
			reqOpToBufBbufSetFull <= '0';
			-- IP impl.op.rising.asyncrst --- REND

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and reqInvSetRng='1')) then
				if reqInvSetRng='1' then
					stateOp <= stateOpInv;

				else
					-- IP impl.op.rising.syncrst --- RBEGIN
					latestBNotA <= '0';
					aBuf <= (others => '0');
					dwrBuf <= (others => '0');

					infoTkstA <= (others => '0');
					infoTkstB <= (others => '0');
					infoMinA <= (others => '0');
					infoMinB <= (others => '0');
					infoMaxA <= (others => '0');
					infoMaxB <= (others => '0');

					reqOpToBufAbufLock <= '0';
					reqOpToBufAbufSetFull <= '0';
					reqOpToBufBbufLock <= '0';
					reqOpToBufBbufSetFull <= '0';
					-- IP impl.op.rising.syncrst --- REND

					if setRngRng=fls8 then
						stateOp <= stateOpInit;

					else
						stateOp <= stateOpReady;
					end if;
				end if;

			elsif stateOp=stateOpInv then
				if reqInvSetRng='0' then
					stateOp <= stateOpInit;
				end if;

			elsif stateOp=stateOpReady then
				if lwirrng='1' then
					-- IP impl.op.rising.ready.rng --- IBEGIN
					aBuf <= (others => '0');
		
					spilen <= std_logic_vector(to_unsigned(164, 17));
		
					seg := 1;
					pkt := 0;

					min := 65535;
					max := 0;

					errcnt := 0;
					
					i := 0;
					-- IP impl.op.rising.ready.rng --- IEND

					stateOp <= stateOpHdrB;
				end if;

			elsif stateOp=stateOpTimeoutA then
				if tkclk='0' then
					l := l + 1; -- IP impl.op.rising.timeoutA.inc --- ILINE

					if l=50 then
						stateOp <= stateOpReady;

					else
						stateOp <= stateOpTimeoutB;
					end if;
				end if;

			elsif stateOp=stateOpTimeoutB then
				if tkclk='1' then
					stateOp <= stateOpTimeoutA;
				end if;

			elsif stateOp=stateOpLoopSeg then
				seg := seg + 1; -- IP impl.op.rising.loopSeg.ext --- ILINE

				if seg=5 then
					seg := 0; -- IP impl.op.rising.loopSeg.reset --- ILINE

					if abufLock=lockOp then
						-- IP impl.op.rising.loopSeg.abuf --- IBEGIN
						infoMinA <= std_logic_vector(to_unsigned(min, 16));
						infoMaxA <= std_logic_vector(to_unsigned(max, 16));

						latestBNotA <= '0';

						reqOpToBufAbufSetFull <= '1';
						-- IP impl.op.rising.loopSeg.abuf --- IEND

						stateOp <= stateOpDoneA;

					elsif bbufLock=lockOp then
						-- IP impl.op.rising.loopSeg.bbuf --- IBEGIN
						infoMinB <= std_logic_vector(to_unsigned(min, 16));
						infoMaxB <= std_logic_vector(to_unsigned(max, 16));
						
						latestBNotA <= '1';
						
						reqOpToBufBbufSetFull <= '1';
						-- IP impl.op.rising.loopSeg.bbuf --- IEND

						stateOp <= stateOpDoneA;

					else
						stateOp <= stateOpReady;
					end if;

				else
					k := 0; -- IP impl.op.rising.loopSeg.prepWait --- ILINE

					stateOp <= stateOpInterpkg;
				end if;

			elsif stateOp=stateOpLoopPkt then
				pkt := pkt + 1; -- IP impl.op.rising.loopPkt.ext --- ILINE

				if pkt=60 then
					pkt := 0; -- IP impl.op.rising.loopPkt.reset --- ILINE

					stateOp <= stateOpLoopSeg;

				else
					k := 0; -- IP impl.op.rising.loopPkt.prepWait --- ILINE

					stateOp <= stateOpInterpkg;
				end if;

			elsif stateOp=stateOpInterpkg then
				k := k + 1; -- IP impl.op.rising.interpkg.ext --- ILINE

				if k=(10*(fMclk/1000)) then
					i := 0; -- IP impl.op.rising.interpkg.prepHdr --- ILINE

					stateOp <= stateOpHdrB;
				end if;

			elsif stateOp=stateOpHdrA then
				-- IP impl.op.rising.hdrA --- IBEGIN

				-- full Wdbe modelling would require up to Cond7
				if strbSpirecv='0' then
					i := i + 1;

					if i=4 then
						-- header complete
						if (hdrbuf(ixHdrbufSeg)(3 downto 0)/="1111" and to_integer(unsigned(hdrbuf(ixHdrbufPkt)))<60) then
							if to_integer(unsigned(hdrbuf(ixHdrbufPkt)))=20 then
								if to_integer(unsigned(hdrbuf(ixHdrbufSeg)(6 downto 4)))/=seg then
									seg := 1;
									pkt := 0;

									aBuf <= (others => '0');
								end if;
							end if;

							if to_integer(unsigned(hdrbuf(ixHdrbufPkt)))=pkt then
								if (seg=1 and pkt=0) then
									if (abufLock/=lockOp and bbufLock/=lockOp) then
										if latestBNotA='0' then
											reqOpToBufBbufLock <= '1';
											stateOp <= stateOpTrylockB;
										else
											reqOpToBufAbufLock <= '1';
											stateOp <= stateOpTrylockA;
										end if;
									else
										stateOp <= stateOpDataB;
									end if;
								else
									stateOp <= stateOpDataB;
								end if;

							else
								errcnt := errcnt + 1;
								stateOp <= stateOpSkip;
							end if;

						else
							errcnt := errcnt + 1;
							stateOp <= stateOpSkip;
						end if;

					else
						stateOp <= stateOpHdrB;
					end if;
				end if;
				-- IP impl.op.rising.hdrA --- IEND

			elsif stateOp=stateOpHdrB then
				if (ackSpi='1' and strbSpirecv='1') then
					hdrbuf(i) := spirecv; -- IP impl.op.rising.hdrB --- ILINE

					stateOp <= stateOpHdrA;
				end if;

			elsif stateOp=stateOpTrylockA then
				if ackOpToBufAbufLock='1' then
					-- IP impl.op.rising.trylockA.ack --- IBEGIN
					reqOpToBufAbufLock <= '0';
					infoTkstA <= tkclksrcGetTkstTkst;
					-- IP impl.op.rising.trylockA.ack --- IEND

					stateOp <= stateOpDataB;

				elsif dnyOpToBufAbufLock='1' then
					-- IP impl.op.rising.trylockA.dny --- IBEGIN
					reqOpToBufAbufLock <= '0';
					reqOpToBufBbufLock <= '1';
					-- IP impl.op.rising.trylockA.dny --- IEND

					stateOp <= stateOpTrylockB;
				end if;

			elsif stateOp=stateOpTrylockB then
				if ackOpToBufBbufLock='1' then
					-- IP impl.op.rising.trylockB.ack --- IBEGIN
					reqOpToBufBbufLock <= '0';
					infoTkstB <= tkclksrcGetTkstTkst;
					-- IP impl.op.rising.trylockB.ack --- IEND

					stateOp <= stateOpDataB;

				elsif dnyOpToBufBbufLock='1' then
					-- IP impl.op.rising.trylockB.dny --- IBEGIN
					reqOpToBufBbufLock <= '0';
					reqOpToBufAbufLock <= '1';
					-- IP impl.op.rising.trylockB.dny --- IEND

					stateOp <= stateOpTrylockA;
				end if;

			elsif stateOp=stateOpDataA then
				if strbSpirecv='0' then
					aBuf <= std_logic_vector(unsigned(aBuf) + 1); -- IP impl.op.rising.dataA.next --- ILINE

					stateOp <= stateOpDataB;

				elsif dneSpi='1' then
					aBuf <= std_logic_vector(unsigned(aBuf) + 1); -- IP impl.op.rising.dataA.last --- ILINE

					stateOp <= stateOpLoopPkt;
				end if;

			elsif stateOp=stateOpDataB then
				if strbSpirecv='1' then
					-- IP impl.op.rising.dataB --- IBEGIN
					if aBuf(0)='1' then
						val := dwrBuf & spirecv;

						if to_integer(unsigned(val))<min then
							min := to_integer(unsigned(val));
						end if;
						
						if to_integer(unsigned(val))>max then
							max := to_integer(unsigned(val));
						end if;
					end if;

					dwrBuf <= spirecv;
					-- IP impl.op.rising.dataB --- IEND

					stateOp <= stateOpDataC;
				end if;

			elsif stateOp=stateOpDataC then
				stateOp <= stateOpDataA;

			elsif stateOp=stateOpSkip then
				if dneSpi='1' then
					if errcnt=500 then
						if abufLock=lockOp then
							reqOpToBufAbufLock <= '1'; -- IP impl.op.rising.skip.lockAbuf --- ILINE

							stateOp <= stateOpCancel;

						elsif bbufLock=lockOp then
							reqOpToBufBbufLock <= '1'; -- IP impl.op.rising.skip.lockBbuf --- ILINE

							stateOp <= stateOpCancel;

						else
							l := 0; -- IP impl.op.rising.skip.timeout --- ILINE

							stateOp <= stateOpTimeoutA;
						end if;

					else
						k := 0; -- IP impl.op.rising.skip.prepWait --- ILINE

						stateOp <= stateOpInterpkg;
					end if;
				end if;

			elsif stateOp=stateOpCancel then
				if (ackOpToBufAbufLock='1' or ackOpToBufBbufLock='1') then
					-- IP impl.op.rising.cancel --- IBEGIN
					reqOpToBufAbufLock <= '0';
					reqOpToBufBbufLock <= '0';
		
					l := 0;
					-- IP impl.op.rising.cancel --- IEND

					stateOp <= stateOpTimeoutA;
				end if;

			elsif stateOp=stateOpDoneA then
				if (ackOpToBufAbufSetFull='1' or ackOpToBufBbufSetFull='1') then
					-- IP impl.op.rising.doneA --- IBEGIN
					reqOpToBufAbufSetFull <= '0';
					reqOpToBufBbufSetFull <= '0';
	
					k := 0;
					-- IP impl.op.rising.doneA --- IEND

					stateOp <= stateOpDoneB;
				end if;

			elsif stateOp=stateOpDoneB then
				k := k + 1; -- IP impl.op.rising.doneB.ext --- ILINE

				if k=(10*(fMclk/1000)) then
					i := 0; -- IP impl.op.rising.doneB.reset --- ILINE

					stateOp <= stateOpReady;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Lwiracq;

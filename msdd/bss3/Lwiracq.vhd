-- file Lwiracq.vhd
-- Lwiracq easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 12 Aug 2018
-- date modified: 12 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

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
	signal stateBuf, stateBuf_next: stateBuf_t := stateBufInit;

	type lock_t is (lockIdle, lockBufB, lockOp);
	signal abufLock, abufLock_next: lock_t;
	signal abufFull, abufFull_next: std_logic;

	signal bbufLock, bbufLock_next: lock_t;
	signal bbufFull, bbufFull_next: std_logic;

	-- IP sigs.buf.cust --- INSERT

	---- {a/b}buf B/hostif-facing operation (bufB)
	type stateBufB_t is (
		stateBufBInit,
		stateBufBReady,
		stateBufBTrylock,
		stateBufBReadA, stateBufBReadB,
		stateBufBDone
	);
	signal stateBufB, stateBufB_next: stateBufB_t := stateBufBInit;

	signal enAbufB: std_logic;
	signal enBbufB: std_logic;

	signal infoTixVBufstate, infoTixVBufstate_next: std_logic_vector(7 downto 0);
	signal getInfoTkst_sig: std_logic_vector(31 downto 0);
	signal getInfoMin_sig: std_logic_vector(15 downto 0);
	signal getInfoMax_sig: std_logic_vector(15 downto 0);

	signal aBufB_vec: std_logic_vector(15 downto 0);
	signal aBufB, aBufB_next: natural range 0 to 38912;

	signal ackBufToHostif, ackBufToHostif_next: std_logic;
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
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal bufrun: std_logic;

	signal infoTkstA: std_logic_vector(31 downto 0);
	signal infoTkstB: std_logic_vector(31 downto 0);
	signal infoMinA: std_logic_vector(15 downto 0);
	signal infoMinB: std_logic_vector(15 downto 0);
	signal infoMaxA: std_logic_vector(15 downto 0);
	signal infoMaxB: std_logic_vector(15 downto 0);

	signal latestBNotA, latestBNotA_next: std_logic;

	signal enAbuf: std_logic;
	signal enBbuf: std_logic;

	signal aBuf, aBuf_next: std_logic_vector(15 downto 0);
	signal dwrBuf, dwrBuf_next: std_logic_vector(7 downto 0);
	signal spilen: std_logic_vector(16 downto 0);
	signal ackInvSetRng_sig: std_logic;

	-- IP sigs.op.cust --- INSERT

	---- mySpi
	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	---- handshake
	-- op to buf
	signal reqOpToBufAbufLock, reqOpToBufAbufLock_next: std_logic;
	signal ackOpToBufAbufLock, ackOpToBufAbufLock_next: std_logic;
	signal dnyOpToBufAbufLock, dnyOpToBufAbufLock_next: std_logic;

	-- op to buf
	signal reqOpToBufAbufSetFull, reqOpToBufAbufSetFull_next: std_logic;
	signal ackOpToBufAbufSetFull, ackOpToBufAbufSetFull_next: std_logic;

	-- op to buf
	signal reqOpToBufBbufLock, reqOpToBufBbufLock_next: std_logic;
	signal ackOpToBufBbufLock, ackOpToBufBbufLock_next: std_logic;
	signal dnyOpToBufBbufLock, dnyOpToBufBbufLock_next: std_logic;

	-- op to buf
	signal reqOpToBufBbufSetFull, reqOpToBufBbufSetFull_next: std_logic;
	signal ackOpToBufBbufSetFull, ackOpToBufBbufSetFull_next: std_logic;

	-- bufB to buf
	signal reqBufBToBufAbufLock, reqBufBToBufAbufLock_next: std_logic;
	signal ackBufBToBufAbufLock, ackBufBToBufAbufLock_next: std_logic;
	signal dnyBufBToBufAbufLock, dnyBufBToBufAbufLock_next: std_logic;

	-- bufB to buf
	signal reqBufBToBufAbufClear, reqBufBToBufAbufClear_next: std_logic;
	signal ackBufBToBufAbufClear, ackBufBToBufAbufClear_next: std_logic;

	-- bufB to buf
	signal reqBufBToBufBbufLock, reqBufBToBufBbufLock_next: std_logic;
	signal ackBufBToBufBbufLock, ackBufBToBufBbufLock_next: std_logic;
	signal dnyBufBToBufBbufLock, dnyBufBToBufBbufLock_next: std_logic;

	-- bufB to buf
	signal reqBufBToBufBbufClear, reqBufBToBufBbufClear_next: std_logic;
	signal ackBufBToBufBbufClear, ackBufBToBufBbufClear_next: std_logic;

	-- op to mySpi
	signal reqSpi: std_logic;
	signal ackSpi: std_logic;
	signal dneSpi: std_logic;

	---- other
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
			ack => open,
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
			stateBuf_next <= stateBufInit;
			abufLock_next <= lockIdle;
			abufFull_next <= '0';
			bbufLock_next <= lockIdle;
			bbufFull_next <= '0';
			ackOpToBufAbufLock_next <= '0';
			dnyOpToBufAbufLock_next <= '0';
			ackOpToBufAbufSetFull_next <= '0';
			ackOpToBufBbufLock_next <= '0';
			dnyOpToBufBbufLock_next <= '0';
			ackOpToBufBbufSetFull_next <= '0';
			ackBufBToBufAbufLock_next <= '0';
			dnyBufBToBufAbufLock_next <= '0';
			ackBufBToBufAbufClear_next <= '0';
			ackBufBToBufBbufLock_next <= '0';
			dnyBufBToBufBbufLock_next <= '0';
			ackBufBToBufBbufClear_next <= '0';
			-- IP impl.buf.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBuf=stateBufInit or bufrun='0') then
				-- IP impl.buf.rising.syncrst --- BEGIN
				abufLock_next <= lockIdle;
				abufFull_next <= '0';
				bbufLock_next <= lockIdle;
				bbufFull_next <= '0';
				ackOpToBufAbufLock_next <= '0';
				dnyOpToBufAbufLock_next <= '0';
				ackOpToBufAbufSetFull_next <= '0';
				ackOpToBufBbufLock_next <= '0';
				dnyOpToBufBbufLock_next <= '0';
				ackOpToBufBbufSetFull_next <= '0';
				ackBufBToBufAbufLock_next <= '0';
				dnyBufBToBufAbufLock_next <= '0';
				ackBufBToBufAbufClear_next <= '0';
				ackBufBToBufBbufLock_next <= '0';
				dnyBufBToBufBbufLock_next <= '0';
				ackBufBToBufBbufClear_next <= '0';

				-- IP impl.buf.rising.syncrst --- END

				if bufrun='0' then
					stateBuf_next <= stateBufInit;

				else
					stateBuf_next <= stateBufReady;
				end if;

			elsif stateBuf=stateBufReady then
				if reqOpToBufAbufLock='1' then
					-- IP impl.buf.rising.ready.opAbufLock --- IBEGIN
					if abufLock=lockIdle then
						abufLock_next <= lockOp;
						abufFull_next <= '0';
						ackOpToBufAbufLock_next <= '1';
					elsif abufLock=lockBufB then
						dnyOpToBufAbufLock_next <= '1';
					elsif abufLock=lockOp then
						abufLock_next <= lockIdle; -- unlock
						ackOpToBufAbufLock_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.opAbufLock --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqOpToBufAbufSetFull='1' then
					-- IP impl.buf.rising.ready.abufFull --- IBEGIN
					if abufLock=lockOp then
						abufLock_next <= lockIdle;
						abufFull_next <= '1';
						ackOpToBufAbufSetFull_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.abufFull --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqOpToBufBbufLock='1' then
					-- IP impl.buf.rising.ready.opBbufLock --- IBEGIN
					if bbufLock=lockIdle then
						bbufLock_next <= lockOp;
						bbufFull_next <= '0';
						ackOpToBufBbufLock_next <= '1';
					elsif bbufLock=lockBufB then
						dnyOpToBufBbufLock_next <= '1';
					elsif bbufLock=lockOp then
						bbufLock_next <= lockIdle; -- unlock
						ackOpToBufBbufLock_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.opBbufLock --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqOpToBufBbufSetFull='1' then
					-- IP impl.buf.rising.ready.bbufFull --- IBEGIN
					if bbufLock=lockOp then
						bbufLock_next <= lockIdle;
						bbufFull_next <= '1';
						ackOpToBufBbufSetFull_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.bbufFull --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqBufBToBufAbufLock='1' then
					-- IP impl.buf.rising.ready.bufBAbufLock --- IBEGIN
					if abufLock=lockIdle then
						abufLock_next <= lockBufB;
						ackBufBToBufAbufLock_next <= '1';
					elsif abufLock=lockBufB then
						abufLock_next <= lockIdle; -- unlock
						ackBufBToBufAbufLock_next <= '1';
					elsif abufLock=lockOp then
						dnyBufBToBufAbufLock_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.bufBAbufLock --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqBufBToBufAbufClear='1' then
					-- IP impl.buf.rising.ready.abufClear --- IBEGIN
					if abufLock=lockBufB then
						abufLock_next <= lockIdle;
						abufFull_next <= '0';
						ackBufBToBufAbufClear_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.abufClear --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqBufBToBufBbufLock='1' then
					-- IP impl.buf.rising.ready.bufBBbufLock --- IBEGIN
					if bbufLock=lockIdle then
						bbufLock_next <= lockBufB;
						ackBufBToBufBbufLock_next <= '1';
					elsif bbufLock=lockBufB then
						bbufLock_next <= lockIdle; -- unlock
						ackBufBToBufBbufLock_next <= '1';
					elsif bbufLock=lockOp then
						dnyBufBToBufBbufLock_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.bufBBbufLock --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqBufBToBufBbufClear='1' then
					-- IP impl.buf.rising.ready.bbufClear --- IBEGIN
					if bbufLock=lockBufB then
						bbufLock_next <= lockIdle;
						bbufFull_next <= '0';
						ackBufBToBufBbufClear_next <= '1';
					end if;
					-- IP impl.buf.rising.ready.bbufClear --- IEND

					stateBuf_next <= stateBufAck;
				end if;

			elsif stateBuf=stateBufAck then
				if ((ackOpToBufAbufLock='1' or dnyOpToBufAbufLock='1') and reqOpToBufAbufLock='0') then
					-- IP impl.buf.rising.ack.opAbufLock --- IBEGIN
					ackOpToBufAbufLock_next <= '0';
					dnyOpToBufAbufLock_next <= '0';
					-- IP impl.buf.rising.ack.opAbufLock --- IEND

					stateBuf_next <= stateBufReady;

				elsif (ackOpToBufAbufSetFull='1' and reqOpToBufAbufSetFull='0') then
					ackOpToBufAbufSetFull_next <= '0'; -- IP impl.buf.rising.ack.abufFull --- ILINE

					stateBuf_next <= stateBufReady;

				elsif ((ackOpToBufBbufLock='1' or dnyOpToBufBbufLock='1') and reqOpToBufBbufLock='0') then
					-- IP impl.buf.rising.ack.opBbufLock --- IBEGIN
					ackOpToBufBbufLock_next <= '0';
					dnyOpToBufBbufLock_next <= '0';
					-- IP impl.buf.rising.ack.opBbufLock --- IEND

					stateBuf_next <= stateBufReady;

				elsif (ackOpToBufAbufSetFull='1' and reqOpToBufAbufSetFull='0') then
					ackOpToBufBbufSetFull_next <= '0'; -- IP impl.buf.rising.ack.bbufFull --- ILINE

					stateBuf_next <= stateBufReady;

				elsif ((ackBufBToBufAbufLock='1' or dnyBufBToBufAbufLock='1') and reqBufBToBufAbufLock='0') then
					-- IP impl.buf.rising.ack.bufBAbufLock --- IBEGIN
					ackBufBToBufAbufLock_next <= '0';
					dnyBufBToBufAbufLock_next <= '0';
					-- IP impl.buf.rising.ack.bufBAbufLock --- IEND

					stateBuf_next <= stateBufReady;

				elsif (ackBufBToBufAbufClear='1' and reqBufBToBufAbufClear='0') then
					ackBufBToBufAbufClear_next <= '0'; -- IP impl.buf.rising.ack.abufClear --- ILINE

					stateBuf_next <= stateBufReady;

				elsif ((ackBufBToBufBbufLock='1' or dnyBufBToBufBbufLock='1') and reqBufBToBufBbufLock='0') then
					-- IP impl.buf.rising.ack.bufBBbufLock --- IBEGIN
					ackBufBToBufBbufLock_next <= '0';
					dnyBufBToBufBbufLock_next <= '0';
					-- IP impl.buf.rising.ack.bufBBbufLock --- IEND

					stateBuf_next <= stateBufReady;

				elsif (ackBufBToBufBbufClear='1' and reqBufBToBufBbufClear='0') then
					ackBufBToBufBbufClear_next <= '0'; -- IP impl.buf.rising.ack.bbufClear --- ILINE

					stateBuf_next <= stateBufReady;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.buf.rising --- END

	-- IP impl.buf.falling --- BEGIN
	process (mclk)
		-- IP impl.buf.falling.vars --- BEGIN
		-- IP impl.buf.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateBuf <= stateBuf_next;
			abufLock <= abufLock_next;
			abufFull <= abufFull_next;
			bbufLock <= bbufLock_next;
			bbufFull <= bbufFull_next;
			ackOpToBufAbufLock <= ackOpToBufAbufLock_next;
			dnyOpToBufAbufLock <= dnyOpToBufAbufLock_next;
			ackOpToBufAbufSetFull <= ackOpToBufAbufSetFull_next;
			ackOpToBufBbufLock <= ackOpToBufBbufLock_next;
			dnyOpToBufBbufLock <= dnyOpToBufBbufLock_next;
			ackOpToBufBbufSetFull <= ackOpToBufBbufSetFull_next;
			ackBufBToBufAbufLock <= ackBufBToBufAbufLock_next;
			dnyBufBToBufAbufLock <= dnyBufBToBufAbufLock_next;
			ackBufBToBufAbufClear <= ackBufBToBufAbufClear_next;
			ackBufBToBufBbufLock <= ackBufBToBufBbufLock_next;
			dnyBufBToBufBbufLock <= dnyBufBToBufBbufLock_next;
			ackBufBToBufBbufClear <= ackBufBToBufBbufClear_next;
		end if;
	end process;
	-- IP impl.buf.falling --- END

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
			stateBufB_next <= stateBufBInit;
			aBufB_next <= 0;
			ackBufToHostif_next <= '0';
			reqBufBToBufAbufLock_next <= '0';
			reqBufBToBufAbufClear_next <= '0';
			reqBufBToBufBbufLock_next <= '0';
			reqBufBToBufBbufClear_next <= '0';
			-- IP impl.bufB.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBufB=stateBufBInit or bufrun='0') then
				-- IP impl.bufB.rising.syncrst --- BEGIN
				aBufB_next <= 0;
				ackBufToHostif_next <= '0';
				reqBufBToBufAbufLock_next <= '0';
				reqBufBToBufAbufClear_next <= '0';
				reqBufBToBufBbufLock_next <= '0';
				reqBufBToBufBbufClear_next <= '0';

				-- IP impl.bufB.rising.syncrst --- END

				if bufrun='0' then
					stateBufB_next <= stateBufBInit;

				else
					stateBufB_next <= stateBufBReady;
				end if;

			elsif stateBufB=stateBufBReady then
				if (infoTixVBufstate=tixVBufstateAbuf and reqAbufToHostif='1') then
					reqBufBToBufAbufLock_next <= '1'; -- IP impl.bufB.rising.ready.aprep --- ILINE

					stateBufB_next <= stateBufBTrylock;

				elsif (infoTixVBufstate=tixVBufstateBbuf and reqBbufToHostif='1') then
					reqBufBToBufBbufLock_next <= '1'; -- IP impl.bufB.rising.ready.bprep --- ILINE

					stateBufB_next <= stateBufBTrylock;
				end if;

			elsif stateBufB=stateBufBTrylock then
				if (ackBufBToBufAbufLock='1' or ackBufBToBufBbufLock='1') then
					-- IP impl.bufB.rising.trylock.ack --- IBEGIN
					reqBufBToBufAbufLock_next <= '0';
					reqBufBToBufBbufLock_next <= '0';
					-- IP impl.bufB.rising.trylock.ack --- IEND

					stateBufB_next <= stateBufBReadA;

				elsif (dnyBufBToBufAbufLock='1' or dnyBufBToBufBbufLock='1') then
					stateBufB_next <= stateBufBInit;
				end if;

			elsif stateBufB=stateBufBReadA then
				if abufLock=lockBufB then
					if dneAbufToHostif='1' then
						-- IP impl.bufB.rising.readA.adne --- IBEGIN
						reqBufBToBufAbufClear_next <= '1';
						ackBufToHostif_next <= '0';
						-- IP impl.bufB.rising.readA.adne --- IEND

						stateBufB_next <= stateBufBDone;

					elsif reqAbufToHostif='0' then
						-- IP impl.bufB.rising.readA.acnc --- IBEGIN
						reqBufBToBufAbufLock_next <= '1'; -- unlock
						ackBufToHostif_next <= '0';
						-- IP impl.bufB.rising.readA.acnc --- IEND

						stateBufB_next <= stateBufBDone;

					elsif strbDAbufToHostif='0' then
						ackBufToHostif_next <= '1'; -- IP impl.bufB.rising.readA.astep --- ILINE

						stateBufB_next <= stateBufBReadB;
					end if;

				elsif bbufLock=lockBufB then
					if dneBbufToHostif='1' then
						-- IP impl.bufB.rising.readA.bdne --- IBEGIN
						reqBufBToBufBbufClear_next <= '1';
						ackBufToHostif_next <= '0';
						-- IP impl.bufB.rising.readA.bdne --- IEND

						stateBufB_next <= stateBufBDone;

					elsif reqBbufToHostif='0' then
						-- IP impl.bufB.rising.readA.bcnc --- IBEGIN
						reqBufBToBufBbufLock_next <= '1'; -- unlock
						ackBufToHostif_next <= '0';
						-- IP impl.bufB.rising.readA.bcnc --- IEND

						stateBufB_next <= stateBufBDone;

					elsif strbDBbufToHostif='0' then
						ackBufToHostif_next <= '1'; -- IP impl.bufB.rising.readA.bstep --- ILINE

						stateBufB_next <= stateBufBReadB;
					end if;
				end if;

			elsif stateBufB=stateBufBReadB then
				if ((abufLock=lockBufB and strbDAbufToHostif='1') or (bbufLock=lockBufB and strbDBbufToHostif='1')) then
					aBufB_next <= aBufB + 1; -- IP impl.bufB.rising.readB.inc --- ILINE

					stateBufB_next <= stateBufBReadA;
				end if;

			elsif stateBufB=stateBufBDone then
				if (ackBufBToBufAbufLock='1' or ackBufBToBufAbufClear='1' or ackBufBToBufBbufLock='1' or ackBufBToBufBbufClear='1') then
					stateBufB_next <= stateBufBInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.bufB.rising --- END

	-- IP impl.bufB.falling --- BEGIN
	process (mclk)
		-- IP impl.bufB.falling.vars --- BEGIN
		-- IP impl.bufB.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateBufB <= stateBufB_next;
			aBufB <= aBufB_next;
			ackBufToHostif <= ackBufToHostif_next;
			reqBufBToBufAbufLock <= reqBufBToBufAbufLock_next;
			reqBufBToBufAbufClear <= reqBufBToBufAbufClear_next;
			reqBufBToBufBbufLock <= reqBufBToBufBbufLock_next;
			reqBufBToBufBbufClear <= reqBufBToBufBbufClear_next;
		end if;
	end process;
	-- IP impl.bufB.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	bufrun <= '0' when (stateOp=stateOpInit or stateOp=stateOpInv) else '1';

	enAbuf <= '1' when (abufLock=lockOp and stateOp=stateOpDataC) else '0';
	enBbuf <= '1' when (bbufLock=lockOp and stateOp=stateOpDataC) else '0';

	ackInvSetRng_sig <= '1' when stateOp=stateOpInv else '0';
	ackInvSetRng <= ackInvSetRng_sig;

	reqSpi <= '1' when (stateOp=stateOpHdrA or stateOp=stateOpHdrB or stateOp=stateOpTrylockA or stateOp=stateOpTrylockB
				 or stateOp=stateOpDataA or stateOp=stateOpDataB or stateOp=stateOpDataC or stateOp=stateOpSkip) else '0';
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
			stateOp_next <= stateOpInit;
			latestBNotA_next <= '0';
			aBuf_next <= (others => '0');
			dwrBuf_next <= (others => '0');

			infoTkstA <= (others => '0');
			infoTkstB <= (others => '0');
			infoMinA <= (others => '0');
			infoMinB <= (others => '0');
			infoMaxA <= (others => '0');
			infoMaxB <= (others => '0');

			reqOpToBufAbufLock_next <= '0';
			reqOpToBufAbufSetFull_next <= '0';
			reqOpToBufBbufLock_next <= '0';
			reqOpToBufBbufSetFull_next <= '0';
			-- IP impl.op.rising.asyncrst --- REND

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and reqInvSetRng='1')) then
				if reqInvSetRng='1' then
					stateOp_next <= stateOpInv;

				else
					-- IP impl.op.rising.syncrst --- RBEGIN
					latestBNotA_next <= '0';
					aBuf_next <= (others => '0');
					dwrBuf_next <= (others => '0');

					infoTkstA <= (others => '0');
					infoTkstB <= (others => '0');
					infoMinA <= (others => '0');
					infoMinB <= (others => '0');
					infoMaxA <= (others => '0');
					infoMaxB <= (others => '0');

					reqOpToBufAbufLock_next <= '0';
					reqOpToBufAbufSetFull_next <= '0';
					reqOpToBufBbufLock_next <= '0';
					reqOpToBufBbufSetFull_next <= '0';
					-- IP impl.op.rising.syncrst --- REND

					if setRngRng=fls8 then
						stateOp_next <= stateOpInit;

					else
						stateOp_next <= stateOpReady;
					end if;
				end if;

			elsif stateOp=stateOpInv then
				if reqInvSetRng='0' then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpReady then
				if lwirrng='1' then
					-- IP impl.op.rising.ready.rng --- IBEGIN
					aBuf_next <= (others => '0');
		
					spilen <= std_logic_vector(to_unsigned(164, 17));
		
					seg := 1;
					pkt := 0;

					min := 65535;
					max := 0;

					errcnt := 0;
					
					i := 0;
					-- IP impl.op.rising.ready.rng --- IEND

					stateOp_next <= stateOpHdrB;
				end if;

			elsif stateOp=stateOpTimeoutA then
				if tkclk='0' then
					l := l + 1; -- IP impl.op.rising.timeoutA.inc --- ILINE

					if l=50 then
						stateOp_next <= stateOpReady;

					else
						stateOp_next <= stateOpTimeoutB;
					end if;
				end if;

			elsif stateOp=stateOpTimeoutB then
				if tkclk='1' then
					stateOp_next <= stateOpTimeoutA;
				end if;

			elsif stateOp=stateOpLoopSeg then
				seg := seg + 1; -- IP impl.op.rising.loopSeg.ext --- ILINE

				if seg=5 then
					seg := 0; -- IP impl.op.rising.loopSeg.reset --- ILINE

					if abufLock=lockOp then
						-- IP impl.op.rising.loopSeg.abuf --- IBEGIN
						infoMinA <= std_logic_vector(to_unsigned(min, 16));
						infoMaxA <= std_logic_vector(to_unsigned(max, 16));

						latestBNotA_next <= '0';

						reqOpToBufAbufSetFull_next <= '1';
						-- IP impl.op.rising.loopSeg.abuf --- IEND

						stateOp_next <= stateOpDoneA;

					elsif bbufLock=lockOp then
						-- IP impl.op.rising.loopSeg.bbuf --- IBEGIN
						infoMinB <= std_logic_vector(to_unsigned(min, 16));
						infoMaxB <= std_logic_vector(to_unsigned(max, 16));
						
						latestBNotA_next <= '1';
						
						reqOpToBufBbufSetFull_next <= '1';
						-- IP impl.op.rising.loopSeg.bbuf --- IEND

						stateOp_next <= stateOpDoneA;

					else
						stateOp_next <= stateOpReady;
					end if;

				else
					k := 0; -- IP impl.op.rising.loopSeg.prepWait --- ILINE

					stateOp_next <= stateOpInterpkg;
				end if;

			elsif stateOp=stateOpLoopPkt then
				pkt := pkt + 1; -- IP impl.op.rising.loopPkt.ext --- ILINE

				if pkt=60 then
					pkt := 0; -- IP impl.op.rising.loopPkt.reset --- ILINE

					stateOp_next <= stateOpLoopSeg;

				else
					k := 0; -- IP impl.op.rising.loopPkt.prepWait --- ILINE

					stateOp_next <= stateOpInterpkg;
				end if;

			elsif stateOp=stateOpInterpkg then
				k := k + 1; -- IP impl.op.rising.interpkg.ext --- ILINE

				if k=(10*(fMclk/1000)) then
					i := 0; -- IP impl.op.rising.interpkg.prepHdr --- ILINE

					stateOp_next <= stateOpHdrB;
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

									aBuf_next <= (others => '0');
								end if;
							end if;

							if to_integer(unsigned(hdrbuf(ixHdrbufPkt)))=pkt then
								if (seg=1 and pkt=0) then
									if (abufLock/=lockOp and bbufLock/=lockOp) then
										if latestBNotA='0' then
											reqOpToBufBbufLock_next <= '1';
											stateOp_next <= stateOpTrylockB;
										else
											reqOpToBufAbufLock_next <= '1';
											stateOp_next <= stateOpTrylockA;
										end if;
									else
										stateOp_next <= stateOpDataB;
									end if;
								else
									stateOp_next <= stateOpDataB;
								end if;

							else
								errcnt := errcnt + 1;
								stateOp_next <= stateOpSkip;
							end if;

						else
							errcnt := errcnt + 1;
							stateOp_next <= stateOpSkip;
						end if;

					else
						stateOp_next <= stateOpHdrB;
					end if;
				end if;
				-- IP impl.op.rising.hdrA --- IEND

			elsif stateOp=stateOpHdrB then
				if (ackSpi='1' and strbSpirecv='1') then
					hdrbuf(i) := spirecv; -- IP impl.op.rising.hdrB --- ILINE

					stateOp_next <= stateOpHdrA;
				end if;

			elsif stateOp=stateOpTrylockA then
				if ackOpToBufAbufLock='1' then
					-- IP impl.op.rising.trylockA.ack --- IBEGIN
					reqOpToBufAbufLock_next <= '0';
					infoTkstA <= tkclksrcGetTkstTkst;
					-- IP impl.op.rising.trylockA.ack --- IEND

					stateOp_next <= stateOpDataB;

				elsif dnyOpToBufAbufLock='1' then
					-- IP impl.op.rising.trylockA.dny --- IBEGIN
					reqOpToBufAbufLock_next <= '0';
					reqOpToBufBbufLock_next <= '1';
					-- IP impl.op.rising.trylockA.dny --- IEND

					stateOp_next <= stateOpTrylockB;
				end if;

			elsif stateOp=stateOpTrylockB then
				if ackOpToBufBbufLock='1' then
					-- IP impl.op.rising.trylockB.ack --- IBEGIN
					reqOpToBufBbufLock_next <= '0';
					infoTkstB <= tkclksrcGetTkstTkst;
					-- IP impl.op.rising.trylockB.ack --- IEND

					stateOp_next <= stateOpDataB;

				elsif dnyOpToBufBbufLock='1' then
					-- IP impl.op.rising.trylockB.dny --- IBEGIN
					reqOpToBufBbufLock_next <= '0';
					reqOpToBufAbufLock_next <= '1';
					-- IP impl.op.rising.trylockB.dny --- IEND

					stateOp_next <= stateOpTrylockA;
				end if;

			elsif stateOp=stateOpDataA then
				if strbSpirecv='0' then
					aBuf_next <= std_logic_vector(unsigned(aBuf) + 1); -- IP impl.op.rising.dataA.next --- ILINE

					stateOp_next <= stateOpDataB;

				elsif dneSpi='1' then
					aBuf_next <= std_logic_vector(unsigned(aBuf) + 1); -- IP impl.op.rising.dataA.last --- ILINE

					stateOp_next <= stateOpLoopPkt;
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

					dwrBuf_next <= spirecv;
					-- IP impl.op.rising.dataB --- IEND

					stateOp_next <= stateOpDataC;
				end if;

			elsif stateOp=stateOpDataC then
				stateOp_next <= stateOpDataA;

			elsif stateOp=stateOpSkip then
				if dneSpi='1' then
					if errcnt=500 then
						if abufLock=lockOp then
							reqOpToBufAbufLock_next <= '1'; -- IP impl.op.rising.skip.lockAbuf --- ILINE

							stateOp_next <= stateOpCancel;

						elsif bbufLock=lockOp then
							reqOpToBufBbufLock_next <= '1'; -- IP impl.op.rising.skip.lockBbuf --- ILINE

							stateOp_next <= stateOpCancel;

						else
							l := 0; -- IP impl.op.rising.skip.timeout --- ILINE

							stateOp_next <= stateOpTimeoutA;
						end if;

					else
						k := 0; -- IP impl.op.rising.skip.prepWait --- ILINE

						stateOp_next <= stateOpInterpkg;
					end if;
				end if;

			elsif stateOp=stateOpCancel then
				if (ackOpToBufAbufLock='1' or ackOpToBufBbufLock='1') then
					-- IP impl.op.rising.cancel --- IBEGIN
					reqOpToBufAbufLock_next <= '0';
					reqOpToBufBbufLock_next <= '0';
		
					l := 0;
					-- IP impl.op.rising.cancel --- IEND

					stateOp_next <= stateOpTimeoutA;
				end if;

			elsif stateOp=stateOpDoneA then
				if (ackOpToBufAbufSetFull='1' or ackOpToBufBbufSetFull='1') then
					-- IP impl.op.rising.doneA --- IBEGIN
					reqOpToBufAbufSetFull_next <= '0';
					reqOpToBufBbufSetFull_next <= '0';
	
					k := 0;
					-- IP impl.op.rising.doneA --- IEND

					stateOp_next <= stateOpDoneB;
				end if;

			elsif stateOp=stateOpDoneB then
				k := k + 1; -- IP impl.op.rising.doneB.ext --- ILINE

				if k=(10*(fMclk/1000)) then
					i := 0; -- IP impl.op.rising.doneB.reset --- ILINE

					stateOp_next <= stateOpReady;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (mclk)
		-- IP impl.op.falling.vars --- BEGIN
		-- IP impl.op.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			latestBNotA <= latestBNotA_next;
			aBuf <= aBuf_next;
			dwrBuf <= dwrBuf_next;
			reqOpToBufAbufLock <= reqOpToBufAbufLock_next;
			reqOpToBufAbufSetFull <= reqOpToBufAbufSetFull_next;
			reqOpToBufBbufLock <= reqOpToBufBbufLock_next;
			reqOpToBufBbufSetFull <= reqOpToBufBbufSetFull_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Lwiracq;



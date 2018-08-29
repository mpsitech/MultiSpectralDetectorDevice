-- file Vgaacq.vhd
-- Vgaacq easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 26 Aug 2018
-- date modified: 26 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Vgaacq is
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
end Vgaacq;

architecture Vgaacq of Vgaacq is

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

	constant tixVBufstateIdle: std_logic_vector(7 downto 0) := x"00";
	constant tixVBufstateEmpty: std_logic_vector(7 downto 0) := x"01";
	constant tixVBufstateAbuf: std_logic_vector(7 downto 0) := x"02";
	constant tixVBufstateBbuf: std_logic_vector(7 downto 0) := x"03";

	---- buffer operation (buf)
	type stateBuf_t is (
		stateBufInit,
		stateBufIdle,
		stateBufAck
	);
	signal stateBuf, stateBuf_next: stateBuf_t := stateBufInit;

	signal abufFull, abufFull_next: std_logic;
	signal bbufFull, bbufFull_next: std_logic;

	signal infoTixVBufstate, infoTixVBufstate_next: std_logic_vector(7 downto 0);

	-- IP sigs.buf.cust --- INSERT

	---- {a/b}buf B/hostif-facing operation (bufB)
	type stateBufB_t is (
		stateBufBInit,
		stateBufBReady,
		stateBufBReadA, stateBufBReadB,
		stateBufBDone
	);
	signal stateBufB, stateBufB_next: stateBufB_t := stateBufBInit;

	signal enAbufB: std_logic;

	signal aAbufB_vec: std_logic_vector(15 downto 0);
	signal aAbufB, aAbufB_next: natural range 0 to 38911;

	signal ackAbufToHostif_sig, ackAbufToHostif_sig_next: std_logic;
	signal enBbufB: std_logic;

	signal aBbufB_vec: std_logic_vector(15 downto 0);
	signal aBbufB, aBbufB_next: natural range 0 to 38911;

	signal ackBbufToHostif_sig, ackBbufToHostif_sig_next: std_logic;

	-- IP sigs.bufB.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpReady,
		stateOpLoadA, stateOpLoadB,
		stateOpStoreA, stateOpStoreB,
		stateOpSetFull
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal bufrun: std_logic;

	signal infoTkstA: std_logic_vector(31 downto 0);
	signal infoTkstB: std_logic_vector(31 downto 0);

	signal bNotA, bNotA_next: std_logic;

	signal enAbuf: std_logic;
	signal enBbuf: std_logic;

	signal weBuf: std_logic;
	signal aBuf, aBuf_next: std_logic_vector(15 downto 0);

	signal drdBuf: std_logic_vector(7 downto 0);
	signal dwrBuf: std_logic_vector(7 downto 0);

	signal urxlen: std_logic_vector(16 downto 0);
	signal utxlen: std_logic_vector(16 downto 0);
	signal utxd: std_logic_vector(7 downto 0);
	signal ackInvSetRng_sig: std_logic;

	-- IP sigs.op.cust --- INSERT

	---- myAbuf
	signal drdAbuf: std_logic_vector(7 downto 0);

	---- myBbuf
	signal drdBbuf: std_logic_vector(7 downto 0);

	---- handshake
	-- op to 
	signal reqUrx: std_logic;
	signal ackUrx: std_logic;
	signal dneUrx: std_logic;

	-- op to 
	signal reqUtx: std_logic;
	signal ackUtx: std_logic;
	signal dneUtx: std_logic;

	-- op to buf
	signal reqOpToBufAbufSetFull, reqOpToBufAbufSetFull_next: std_logic;
	signal ackOpToBufAbufSetFull, ackOpToBufAbufSetFull_next: std_logic;

	-- op to buf
	signal reqOpToBufBbufSetFull, reqOpToBufBbufSetFull_next: std_logic;
	signal ackOpToBufBbufSetFull, ackOpToBufBbufSetFull_next: std_logic;

	-- bufB to buf
	signal reqBufBToBufClear: std_logic;
	signal ackBufBToBufClear, ackBufBToBufClear_next: std_logic;

	---- other
	signal urxd: std_logic_vector(7 downto 0);
	signal strbUrxd: std_logic;

	signal strbUtxd: std_logic;
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myAbuf : Dpbram_v1_0_size38kB
		port map (
			clkA => mclk,

			enA => enAbuf,
			weA => weBuf,

			aA => aBuf,
			drdA => drdAbuf,
			dwrA => dwrBuf,

			clkB => mclk,

			enB => enAbufB,
			weB => '0',

			aB => aAbufB_vec,
			drdB => dAbufToHostif,
			dwrB => x"00"
		);

	myBbuf : Dpbram_v1_0_size38kB
		port map (
			clkA => mclk,

			enA => enAbuf,
			weA => weBuf,

			aA => aBuf,
			drdA => drdAbuf,
			dwrA => dwrBuf,

			clkB => mclk,

			enB => enAbufB,
			weB => '0',

			aB => aAbufB_vec,
			drdB => dBbufToHostif,
			dwrB => x"00"
		);

	myRx : Uartrx_v1_1
		generic map (
			fMclk => fMclk,
			fSclk => 921600
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

			burst => '0',
			rxd => rxd
		);

	myTx : Uarttx_v1_0
		generic map (
			fMclk => fMclk,

			fSclk => 921600,
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
	-- implementation: buffer operation (buf)
	------------------------------------------------------------------------

	-- IP impl.buf.wiring --- RBEGIN
	getInfoTixVBufstate <= infoTixVBufstate;

	avllenAbufToHostif <= std_logic_vector(to_unsigned(38400, 16)) when infoTixVBufstate=tixVBufstateAbuf else (others => '0');
	avllenBbufToHostif <= std_logic_vector(to_unsigned(38400, 16)) when infoTixVBufstate=tixVBufstateBbuf else (others => '0');
	-- IP impl.buf.wiring --- REND

	-- IP impl.buf.rising --- BEGIN
	process (reset, mclk, stateBuf)
		-- IP impl.buf.rising.vars --- BEGIN
		-- IP impl.buf.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.buf.rising.asyncrst --- BEGIN
			stateBuf_next <= stateBufInit;
			abufFull_next <= '0';
			bbufFull_next <= '0';
			infoTixVBufstate_next <= x"00";
			ackOpToBufAbufSetFull_next <= '0';
			ackOpToBufBbufSetFull_next <= '0';
			ackBufBToBufClear_next <= '0';
			-- IP impl.buf.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBuf=stateBufInit or bufrun='0') then
				if bufrun='0' then
					infoTixVBufstate_next <= tixVBufstateIdle; -- IP impl.buf.rising.init.stop --- ILINE

					stateBuf_next <= stateBufInit;

				else
					infoTixVBufstate_next <= tixVBufstateEmpty; -- IP impl.buf.rising.init.run --- ILINE

					stateBuf_next <= stateBufIdle;
				end if;

			elsif stateBuf=stateBufIdle then
				if reqOpToBufAbufSetFull='1' then
					-- IP impl.buf.rising.idle.afull --- IBEGIN
					abufFull_next <= '1';
					ackOpToBufAbufSetFull_next <= '1';
					-- IP impl.buf.rising.idle.afull --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqOpToBufBbufSetFull='1' then
					-- IP impl.buf.rising.idle.bfull --- IBEGIN
					bbufFull_next <= '1';
					ackOpToBufBbufSetFull_next <= '1';
					-- IP impl.buf.rising.idle.bfull --- IEND

					stateBuf_next <= stateBufAck;

				elsif reqBufBToBufClear='1' then
					-- IP impl.buf.rising.idle.clear --- IBEGIN
					if infoTixVBufstate=tixVBufstateAbuf then
						abufFull_next <= '0';
					elsif infoTixVBufstate=tixVBufstateBbuf then
						bbufFull_next <= '0';
					end if;
	
					ackBufBToBufClear_next <= '1';
					-- IP impl.buf.rising.idle.clear --- IEND

					stateBuf_next <= stateBufAck;
				end if;

			elsif stateBuf=stateBufAck then
				if (reqOpToBufAbufSetFull='0' and ackOpToBufAbufSetFull='1') then
					-- IP impl.buf.rising.ack.afull --- IBEGIN
					if infoTixVBufstate=tixVBufstateEmpty then
						infoTixVBufstate_next <= tixVBufstateAbuf;
					end if;
					
					ackOpToBufAbufSetFull_next <= '0';
					-- IP impl.buf.rising.ack.afull --- IEND

					stateBuf_next <= stateBufIdle;

				elsif (reqOpToBufBbufSetFull='0' and ackOpToBufBbufSetFull='1') then
					-- IP impl.buf.rising.ack.bfull --- IBEGIN
					if infoTixVBufstate=tixVBufstateEmpty then
						infoTixVBufstate_next <= tixVBufstateBbuf;
					end if;
	
					ackOpToBufBbufSetFull_next <= '0';
					-- IP impl.buf.rising.ack.bfull --- IEND

					stateBuf_next <= stateBufIdle;

				elsif (reqBufBToBufClear='0' and ackBufBToBufClear='1') then
					-- IP impl.buf.rising.ack.clear --- IBEGIN
					if (infoTixVBufstate=tixVBufstateAbuf and bbufFull='1') then
						infoTixVBufstate_next <= tixVBufstateBbuf;
					elsif (infoTixVBufstate=tixVBufstateBbuf and abufFull='1') then
						infoTixVBufstate_next <= tixVBufstateAbuf;
					else
						infoTixVBufstate_next <= tixVBufstateEmpty;
					end if;
	
					ackBufBToBufClear_next <= '0';
					-- IP impl.buf.rising.ack.clear --- IEND

					stateBuf_next <= stateBufIdle;
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
			abufFull <= abufFull_next;
			bbufFull <= bbufFull_next;
			infoTixVBufstate <= infoTixVBufstate_next;
			ackOpToBufAbufSetFull <= ackOpToBufAbufSetFull_next;
			ackOpToBufBbufSetFull <= ackOpToBufBbufSetFull_next;
			ackBufBToBufClear <= ackBufBToBufClear_next;
		end if;
	end process;
	-- IP impl.buf.falling --- END

	------------------------------------------------------------------------
	-- implementation: {a/b}buf B/hostif-facing operation (bufB)
	------------------------------------------------------------------------

	-- IP impl.bufB.wiring --- RBEGIN
	enAbufB <= '1' when (infoTixVBufstate=tixVBufstateAbuf and strbDAbufToHostif='0' and stateBufB=stateBufBReadA) else '0';
	enBbufB <= '1' when (infoTixVBufstate=tixVBufstateBbuf and strbDBbufToHostif='0' and stateBufB=stateBufBReadA) else '0';

	ackAbufToHostif <= ackAbufToHostif_sig;
	ackBbufToHostif <= ackBbufToHostif_sig;

	reqBufBToBufClear <= '1' when stateBufB=stateBufBDone else '0';

	aAbufB_vec <= std_logic_vector(to_unsigned(aAbufB, 16));

	aBbufB_vec <= std_logic_vector(to_unsigned(aBbufB, 16));
	-- IP impl.bufB.wiring --- REND

	-- IP impl.bufB.rising --- BEGIN
	process (reset, mclk, stateBufB)
		-- IP impl.bufB.rising.vars --- BEGIN
		-- IP impl.bufB.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.bufB.rising.asyncrst --- BEGIN
			stateBufB_next <= stateBufBInit;
			aAbufB_next <= 0;
			ackAbufToHostif_sig_next <= '0';
			aBbufB_next <= 0;
			ackBbufToHostif_sig_next <= '0';
			-- IP impl.bufB.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateBufB=stateBufBInit or (infoTixVBufstate/=tixVBufstateAbuf and infoTixVBufstate/=tixVBufstateBbuf)) then
				if (infoTixVBufstate/=tixVBufstateAbuf and infoTixVBufstate/=tixVBufstateBbuf) then
					stateBufB_next <= stateBufBInit;

				else
					stateBufB_next <= stateBufBReady;
				end if;

			elsif stateBufB=stateBufBReady then
				if (infoTixVBufstate=tixVBufstateAbuf and reqAbufToHostif='1') then
					aAbufB_next <= 0; -- IP impl.bufB.rising.ready.aprep --- ILINE

					stateBufB_next <= stateBufBReadA;

				elsif (infoTixVBufstate=tixVBufstateBbuf and reqBbufToHostif='1') then
					aBbufB_next <= 0; -- IP impl.bufB.rising.ready.bprep --- ILINE

					stateBufB_next <= stateBufBReadA;
				end if;

			elsif stateBufB=stateBufBReadA then
				if infoTixVBufstate=tixVBufstateAbuf then
					if dneAbufToHostif='1' then
						ackAbufToHostif_sig_next <= '0'; -- IP impl.bufB.rising.readA.adne --- ILINE

						stateBufB_next <= stateBufBDone;

					elsif reqAbufToHostif='0' then
						ackAbufToHostif_sig_next <= '0'; -- IP impl.bufB.rising.readA.acnc --- ILINE

						stateBufB_next <= stateBufBReady;

					elsif strbDAbufToHostif='0' then
						ackAbufToHostif_sig_next <= '1'; -- IP impl.bufB.rising.readA.astep --- ILINE

						stateBufB_next <= stateBufBReadB;
					end if;

				elsif infoTixVBufstate=tixVBufstateBbuf then
					if dneBbufToHostif='1' then
						ackBbufToHostif_sig_next <= '0'; -- IP impl.bufB.rising.readA.bdne --- ILINE

						stateBufB_next <= stateBufBDone;

					elsif reqBbufToHostif='0' then
						ackBbufToHostif_sig_next <= '0'; -- IP impl.bufB.rising.readA.bcnc --- ILINE

						stateBufB_next <= stateBufBReady;

					elsif strbDBbufToHostif='0' then
						ackBbufToHostif_sig_next <= '1'; -- IP impl.bufB.rising.readA.bstep --- ILINE

						stateBufB_next <= stateBufBReadB;
					end if;
				end if;

			elsif stateBufB=stateBufBReadB then
				if (infoTixVBufstate=tixVBufstateAbuf and strbDAbufToHostif='1') then
					-- IP impl.bufB.rising.readB.ainc --- INSERT

					stateBufB_next <= stateBufBReadA;

				elsif (infoTixVBufstate=tixVBufstateBbuf and strbDBbufToHostif='1') then
					-- IP impl.bufB.rising.readB.binc --- INSERT

					stateBufB_next <= stateBufBReadA;
				end if;

			elsif stateBufB=stateBufBDone then
				if ackBufBToBufClear='1' then
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
			aAbufB <= aAbufB_next;
			ackAbufToHostif_sig <= ackAbufToHostif_sig_next;
			aBbufB <= aBbufB_next;
			ackBbufToHostif_sig <= ackBbufToHostif_sig_next;
		end if;
	end process;
	-- IP impl.bufB.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	bufrun <= '0' when (stateOp=stateOpInit or stateOp=stateOpInv) else '1';

	enAbuf <= '1' when (bNotA='0' and (stateOp=stateOpLoadA or stateOp=stateOpStoreB)) else '0';
	enBbuf <= '1' when (bNotA='1' and (stateOp=stateOpLoadA or stateOp=stateOpStoreB)) else '0';

	weBuf <= '1' when stateOp=stateOpStoreB else '0';
	ackInvSetRng_sig <= '0' when stateOp=stateOpInv else '0';
	ackInvSetRng <= ackInvSetRng_sig;
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- BEGIN
		-- IP impl.op.rising.vars --- END

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- RBEGIN
			stateOp_next <= stateOpInit;
			bNotA_next <= '0';
			aBuf_next <= x"0000";
			reqOpToBufAbufSetFull_next <= '0';
			reqOpToBufBbufSetFull_next <= '0';

			infoTkstA <= (others => '0');
			infoTkstB <= (others => '0');
			-- IP impl.op.rising.asyncrst --- REND

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and reqInvSetRng='1')) then
				if reqInvSetRng='1' then
					stateOp_next <= stateOpInv;

				elsif setRngRng=fls8 then
					stateOp_next <= stateOpInit;

				else
					stateOp_next <= stateOpReady;
				end if;

			elsif stateOp=stateOpInv then
				if reqInvSetRng='0' then
					-- IP impl.op.rising.inv --- INSERT

					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpReady then
				-- IP impl.op.rising.ready --- INSERT

			elsif stateOp=stateOpLoadA then
				-- IP impl.op.rising.loadA --- INSERT

			elsif stateOp=stateOpLoadB then
				-- IP impl.op.rising.loadB --- INSERT

			elsif stateOp=stateOpStoreA then
				-- IP impl.op.rising.storeA --- INSERT

			elsif stateOp=stateOpStoreB then
				-- IP impl.op.rising.storeB --- INSERT

			elsif stateOp=stateOpSetFull then
				if reqOpToBufAbufSetFull='1' then
					-- IP impl.op.rising.setFull.afull --- INSERT

					stateOp_next <= stateOpSetFull;

				elsif reqOpToBufBbufSetFull='1' then
					-- IP impl.op.rising.setFull.bfull --- INSERT

					stateOp_next <= stateOpSetFull;

				else
					-- IP impl.op.rising.setFull.toggle --- INSERT

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
			bNotA <= bNotA_next;
			aBuf <= aBuf_next;
			reqOpToBufAbufSetFull <= reqOpToBufAbufSetFull_next;
			reqOpToBufBbufSetFull <= reqOpToBufBbufSetFull_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Vgaacq;



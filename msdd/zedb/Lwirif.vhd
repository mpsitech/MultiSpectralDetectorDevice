-- file Lwirif.vhd
-- Lwirif easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 12 Aug 2018
-- date modified: 12 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Lwirif is
	generic (
		fMclk: natural range 1 to 1000000 := 50000 -- in kHz
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
end Lwirif;

architecture Lwirif of Lwirif is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component I2c is
		generic (
			fMclk: natural range 1 to 1000000;

			clkFastNotStd: std_logic := '1';
			clkFastplusNotFast: std_logic := '0';

			devaddr: std_logic_vector(7 downto 0) := x"55"
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			readNotWrite: in std_logic;
			regaddr: in std_logic_vector(15 downto 0);
			send: in std_logic_vector(15 downto 0);
			recv: out std_logic_vector(15 downto 0);

			scl: out std_logic;
			sda: inout std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- camera master clock (cmclk)

	signal cmclk: std_logic;

	-- IP sigs.cmclk.cust --- INSERT

	---- get command clock (get)
	type stateGet_t is (
		stateGetReady,
		stateGetRunA, stateGetRunB, stateGetRunC
	);
	signal stateGet, stateGet_next: stateGet_t := stateGetReady;

	signal strbGet: std_logic;

	-- IP sigs.get.cust --- INSERT

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpStartA, stateOpStartB,
		stateOpReady,
		stateOpLoopCmd,
		stateOpWaitReadyA, stateOpWaitReadyB,
		stateOpSetLenA, stateOpSetLenB,
		stateOpSetCmdA, stateOpSetCmdB,
		stateOpCheckErrA, stateOpCheckErrB,
		stateOpReadA, stateOpReadB
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal rng_sig: std_logic;
	signal nirst_sig: std_logic;

	signal i2creadNotWrite: std_logic;
	signal i2cregaddr: std_logic_vector(15 downto 0);
	signal i2csend: std_logic_vector(15 downto 0);

	signal ackInvSetRng_sig: std_logic;

	-- IP sigs.op.cust --- INSERT

	---- myI2c
	signal i2crecv: std_logic_vector(15 downto 0);

	---- handshake
	-- op to myI2c
	signal reqI2c: std_logic;
	signal ackI2c: std_logic;
	signal dneI2c: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myI2c : I2c
		generic map (
			fMclk => fMclk, -- in kHz

			clkFastNotStd => '1', -- 1Mbps/400kbps vs. 100kbps
			clkFastplusNotFast => '0', -- 1Mbps vs. 400kbps

			devaddr => x"55"
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqI2c,
			ack => open,
			dne => dneI2c,

			readNotWrite => i2creadNotWrite,
			regaddr => i2cregaddr,
			send => i2csend,
			recv => i2crecv,

			scl => scl,
			sda => sda
		);

	------------------------------------------------------------------------
	-- implementation: camera master clock (cmclk)
	------------------------------------------------------------------------

	-- IP impl.cmclk.wiring --- BEGIN
	imclk <= cmclk;
	-- IP impl.cmclk.wiring --- END

	-- IP impl.cmclk.rising --- BEGIN
	process (reset, mclk)
		-- IP impl.cmclk.rising.vars --- RBEGIN
		constant fCmclk: natural := 25000; -- in kHz

		variable i: natural range 0 to (fMclk/fCmclk)/2;
		-- IP impl.cmclk.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.cmclk.rising.asyncrst --- RBEGIN
			cmclk <= '0';
			i := 0;
			-- IP impl.cmclk.rising.asyncrst --- REND

		elsif rising_edge(mclk) then
			-- IP impl.cmclk.rising --- IBEGIN
			i := i + 1;
			if i=(fMclk/fCmclk)/2 then
				cmclk <= not cmclk;
				i := 0;
			end if;
			-- IP impl.cmclk.rising --- IEND
		end if;
	end process;
	-- IP impl.cmclk.rising --- END

	------------------------------------------------------------------------
	-- implementation: get command clock (get)
	------------------------------------------------------------------------

	-- IP impl.get.wiring --- BEGIN
	strbGet <= '1' when (tkclk='1' and stateGet=stateGetRunA) else '0';
	-- IP impl.get.wiring --- END

	-- IP impl.get.rising --- BEGIN
	process (reset, mclk, stateGet)
		-- IP impl.get.rising.vars --- RBEGIN
		variable i: natural range 0 to 50000; -- 5s
		-- IP impl.get.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.get.rising.asyncrst --- BEGIN
			stateGet_next <= stateGetReady;
			-- IP impl.get.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateGet=stateGetReady then
				if tkclk='0' then
					i := 0; -- IP impl.get.rising.ready.prepRun --- ILINE

					stateGet_next <= stateGetRunA;
				end if;

			elsif stateGet=stateGetRunA then
				if tkclk='1' then
					stateGet_next <= stateGetRunC;
				end if;

			elsif stateGet=stateGetRunB then
				if tkclk='1' then
					stateGet_next <= stateGetRunC;
				end if;

			elsif stateGet=stateGetRunC then
				if tkclk='0' then
					i := i + 1; -- IP impl.get.rising.runC.inc --- ILINE

					if i=50000 then
						i := 0; -- IP impl.get.rising.runC.prepRun --- ILINE

						stateGet_next <= stateGetRunA;

					else
						stateGet_next <= stateGetRunB;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.get.rising --- END

	-- IP impl.get.falling --- BEGIN
	process (mclk)
		-- IP impl.get.falling.vars --- BEGIN
		-- IP impl.get.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateGet <= stateGet_next;
		end if;
	end process;
	-- IP impl.get.falling --- END

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- RBEGIN
	rng_sig <= '0' when (stateOp=stateOpInit or stateOp=stateOpInv or stateOp=stateOpStartA or stateOp=stateOpStartB) else '1';
	rng <= rng_sig;

	nirst_sig <= '0' when stateOp=stateOpInit else '1';
	nirst <= nirst_sig;

	reqI2c <= '1' when (stateOp=stateOpWaitReadyB or stateOp=stateOpSetLenB or stateOp=stateOpSetCmdB or stateOp=stateOpCheckErrB or stateOp=stateOpReadB) else '0';

	ackInvSetRng_sig <= '1' when stateOp=stateOpInv else '0';
	ackInvSetRng <= ackInvSetRng_sig;
	-- IP impl.op.wiring --- REND

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		constant regaddrStat: std_logic_vector(15 downto 0) := x"0002";
		constant regaddrCmd: std_logic_vector(15 downto 0) := x"0004";
		constant regaddrLen: std_logic_vector(15 downto 0) := x"0006";
		constant regaddrData0: std_logic_vector(15 downto 0) := x"0008";

		constant sizeRxbuf: natural := 16;
		type rxbuf_t is array (0 to sizeRxbuf-1) of std_logic_vector(15 downto 0);
		variable rxbuf: rxbuf_t;

		variable cmd: std_logic_vector(15 downto 0);
		variable lenRxbuf: natural range 0 to sizeRxbuf;

		constant cmdGetSerno: std_logic_vector(15 downto 0) := x"0208";
		constant lenRxbufGetSerno: natural := 4;

		constant cmdGetPartno: std_logic_vector(15 downto 0) := x"481C";
		constant lenRxbufGetPartno: natural := 16;

		constant cmdGetAuxtemp: std_logic_vector(15 downto 0) := x"0210";
		constant lenRxbufGetAuxtemp: natural := 1;

		constant cmdGetFpatemp: std_logic_vector(15 downto 0) := x"0214";
		constant lenRxbufGetFpatemp: natural := 1;

		constant cmdGetStats: std_logic_vector(15 downto 0) := x"022C";
		constant lenRxbufGetStats: natural := 4;

		variable i: natural range 0 to 50000; -- wait for 5s

		variable j: natural range 0 to sizeRxbuf; -- loop over rxbuf
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- RBEGIN
			stateOp_next <= stateOpInit;
			-- IP impl.op.rising.asyncrst --- REND

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and reqInvSetRng='1') or setRngRng=fls8) then
				if reqInvSetRng='1' then
					stateOp_next <= stateOpInv;

				else
					if setRngRng=fls8 then
						-- IP impl.op.rising.syncrst --- BEGIN
						-- IP impl.op.rising.syncrst --- END

						stateOp_next <= stateOpInit;

					else
						i := 0; -- IP impl.op.rising.init.rng --- ILINE

						if tkclk='0' then
							stateOp_next <= stateOpStartB;

						else
							stateOp_next <= stateOpStartA;
						end if;
					end if;
				end if;

			elsif stateOp=stateOpInv then
				if reqInvSetRng='0' then
					stateOp_next <= stateOpInit;
				end if;

			elsif stateOp=stateOpStartA then
				if tkclk='0' then
					i := i + 1; -- IP impl.op.rising.startA.inc --- ILINE

					if i=50000 then
						stateOp_next <= stateOpReady;

					else
						stateOp_next <= stateOpStartB;
					end if;
				end if;

			elsif stateOp=stateOpStartB then
				if tkclk='1' then
					stateOp_next <= stateOpStartA;
				end if;

			elsif stateOp=stateOpReady then
				if strbGet='1' then
					-- IP impl.op.rising.ready --- IBEGIN
					cmd := cmdGetSerno;
					lenRxbuf := lenRxbufGetSerno;
					-- IP impl.op.rising.ready --- IEND

					stateOp_next <= stateOpWaitReadyA;
				end if;

			elsif stateOp=stateOpLoopCmd then
				if cmd=cmdGetSerno then
					-- IP impl.op.rising.loopCmd.partno --- IBEGIN
					cmd := cmdGetPartno;
					lenRxbuf := lenRxbufGetPartno;
					-- IP impl.op.rising.loopCmd.partno --- IEND

					stateOp_next <= stateOpWaitReadyA;

				elsif cmd=cmdGetPartno then
					-- IP impl.op.rising.loopCmd.auxtemp --- IBEGIN
					cmd := cmdGetAuxtemp;
					lenRxbuf := lenRxbufGetAuxtemp;
					-- IP impl.op.rising.loopCmd.auxtemp --- IEND

					stateOp_next <= stateOpWaitReadyA;

				elsif cmd=cmdGetAuxtemp then
					-- IP impl.op.rising.loopCmd.fpatemp --- IBEGIN
					cmd := cmdGetFpatemp;
					lenRxbuf := lenRxbufGetFpatemp;
					-- IP impl.op.rising.loopCmd.fpatemp --- IEND

					stateOp_next <= stateOpWaitReadyA;

				elsif cmd=cmdGetFpatemp then
					-- IP impl.op.rising.loopCmd.stats --- IBEGIN
					cmd := cmdGetStats;
					lenRxbuf := lenRxbufGetStats;
					-- IP impl.op.rising.loopCmd.stats --- IEND

					stateOp_next <= stateOpWaitReadyA;

				elsif cmd=cmdGetStats then
					stateOp_next <= stateOpReady;
				end if;

			elsif stateOp=stateOpWaitReadyA then
				-- IP impl.op.rising.waitReadyA --- IBEGIN
				i2creadNotWrite <= '1';
				i2cregaddr <= regaddrStat;
				-- IP impl.op.rising.waitReadyA --- IEND

				stateOp_next <= stateOpWaitReadyB;

			elsif stateOp=stateOpWaitReadyB then
				if dneI2c='1' then
					if i2crecv(2 downto 0)="110" then
						stateOp_next <= stateOpSetLenA;

					else
						stateOp_next <= stateOpWaitReadyA;
					end if;
				end if;

			elsif stateOp=stateOpSetLenA then
				-- IP impl.op.rising.setLenA --- IBEGIN
				i2creadNotWrite <= '0';
				i2cregaddr <= regaddrLen;

				if cmd=cmdGetSerno then
					i2csend <= std_logic_vector(to_unsigned(lenRxbufGetSerno, 16));
				elsif cmd=cmdGetPartno then
					i2csend <= std_logic_vector(to_unsigned(lenRxbufGetPartno, 16));
				elsif cmd=cmdGetAuxtemp then
					i2csend <= std_logic_vector(to_unsigned(lenRxbufGetAuxtemp, 16));
				elsif cmd=cmdGetFpatemp then
					i2csend <= std_logic_vector(to_unsigned(lenRxbufGetFpatemp, 16));
				elsif cmd=cmdGetStats then
					i2csend <= std_logic_vector(to_unsigned(lenRxbufGetStats, 16));
				end if;
				-- IP impl.op.rising.setLenA --- IEND

				stateOp_next <= stateOpSetLenB;

			elsif stateOp=stateOpSetLenB then
				if dneI2c='1' then
					stateOp_next <= stateOpSetCmdA;
				end if;

			elsif stateOp=stateOpSetCmdA then
				-- IP impl.op.rising.setCmdA --- IBEGIN
				i2creadNotWrite <= '0';
				i2cregaddr <= regaddrCmd;
	
				if cmd=cmdGetSerno then
					i2csend <= cmdGetSerno;
				elsif cmd=cmdGetPartno then
					i2csend <= cmdGetPartno;
				elsif cmd=cmdGetAuxtemp then
					i2csend <= cmdGetAuxtemp;
				elsif cmd=cmdGetFpatemp then
					i2csend <= cmdGetFpatemp;
				elsif cmd=cmdGetStats then
					i2csend <= cmdGetStats;
				end if;
				-- IP impl.op.rising.setCmdA --- IEND

				stateOp_next <= stateOpSetCmdB;

			elsif stateOp=stateOpSetCmdB then
				if dneI2c='1' then
					stateOp_next <= stateOpCheckErrA;
				end if;

			elsif stateOp=stateOpCheckErrA then
				-- IP impl.op.rising.checkErrA --- IBEGIN
				i2creadNotWrite <= '1';
				i2cregaddr <= regaddrStat;
				-- IP impl.op.rising.checkErrA --- IEND

				stateOp_next <= stateOpCheckErrB;

			elsif stateOp=stateOpCheckErrB then
				if dneI2c='1' then
					if i2crecv(2 downto 0)="110" then
						if lenRxbuf=0 then
							stateOp_next <= stateOpLoopCmd;

						else
							-- IP impl.op.rising.checkErrB.prepRead --- IBEGIN
							i2cregaddr <= regaddrData0;
							j := 0;
							-- IP impl.op.rising.checkErrB.prepRead --- IEND

							stateOp_next <= stateOpReadA;
						end if;

					else
						stateOp_next <= stateOpCheckErrA;
					end if;
				end if;

			elsif stateOp=stateOpReadA then
				i2creadNotWrite <= '1'; -- IP impl.op.rising.readA --- ILINE

				stateOp_next <= stateOpReadB;

			elsif stateOp=stateOpReadB then
				if dneI2c='1' then
					-- IP impl.op.rising.readB --- IBEGIN
					rxbuf(j) := i2crecv;

					j := j + 1;
					-- IP impl.op.rising.readB --- IEND

					if j=lenRxbuf then
						stateOp_next <= stateOpLoopCmd;

					else
						i2cregaddr <= std_logic_vector(unsigned(i2cregaddr) + 2); -- IP impl.op.rising.readB.inc --- ILINE

						stateOp_next <= stateOpReadA;
					end if;
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
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Lwirif;



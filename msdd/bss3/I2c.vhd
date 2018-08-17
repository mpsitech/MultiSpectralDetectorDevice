-- file I2c.vhd
-- I2c other module implementation
-- author Alexander Wirthmueller
-- date created: 12 Aug 2018
-- date modified: 12 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Dbecore.all;
use work.Bss3.all;

entity I2c is
	generic (
		fMclk: natural range 1 to 1000000; -- in kHz

		clkFastNotStd: std_logic := '1'; -- 1Mbps/400kbps vs. 100kbps
		clkFastplusNotFast: std_logic := '0'; -- 1Mbps vs. 400kbps

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
end I2c;

architecture I2c of I2c is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- transfer operation (xfer)
	type stateXfer_t is (
		stateXferInit,
		stateXferStartA, stateXferStartB,
		stateXferBitA, stateXferBitB,
		stateXferAckA, stateXferAckB,
		stateXferRestart,
		stateXferStopA, stateXferStopB, stateXferStopC,
		stateXferDone
	);
	signal stateXfer, stateXfer_next: stateXfer_t := stateXferInit;

	signal ack_sig: std_logic;
	signal dne_sig: std_logic;
	signal recv_sig, recv_sig_next: std_logic_vector(15 downto 0);
	signal scl_sig: std_logic;
	signal sda_sig, sda_sig_next: std_logic;

	-- IP sigs.xfer.cust --- INSERT

	---- myIobuf
	signal sda_in: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myIobuf : IOBUF
		port map (
			O => sda_in,
			IO => sda,
			I => '0',
			T => sda_sig
		);

	------------------------------------------------------------------------
	-- implementation: transfer operation (xfer)
	------------------------------------------------------------------------

	-- IP impl.xfer.wiring --- BEGIN
	ack_sig <= '0' when stateXfer=stateXferInit else '1';
	ack <= ack_sig;
	dne_sig <= '1' when stateXfer=stateXferDone else '0';
	dne <= dne_sig;
	recv <= recv_sig;
	scl_sig <= '0' when (stateXfer=stateXferBitA or stateXfer=stateXferAckA or stateXfer=stateXferRestart
				 or stateXfer=stateXferStopA) else '1';
	scl <= scl_sig;
	-- IP impl.xfer.wiring --- END

	-- IP impl.xfer.rising --- BEGIN
	process (reset, mclk, stateXfer)
		-- IP impl.xfer.rising.vars --- RBEGIN
		variable recvraw: std_logic_vector(15 downto 0);

		variable bytecnt: natural range 0 to 6;

		variable bitcnt: natural range 0 to 8;

		variable imax: natural range 0 to (fMclk/400)/2;
		variable i: natural range 0 to (fMclk/400)/2;
		-- IP impl.xfer.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.xfer.rising.asyncrst --- BEGIN
			stateXfer_next <= stateXferInit;
			recv_sig_next <= x"0000";
			sda_sig_next <= '0';
			-- IP impl.xfer.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateXfer=stateXferInit or req='0') then
				-- IP impl.xfer.rising.syncrst --- RBEGIN
				recv_sig_next <= (others => '0');
				sda_sig_next <= '1';

				recvraw := (others => '0');
				bytecnt := 0;
				bitcnt := 0;

				if clkFastNotStd='0' then
					imax := (fMclk/100)/2;
				else
					if clkFastplusNotFast='1' then
						imax := (fMclk/1000)/2;
					else
						imax := (fMclk/400)/2;
					end if;
				end if;

				i := 0;
				-- IP impl.xfer.rising.syncrst --- REND

				if req='0' then
					stateXfer_next <= stateXferInit;

				else
					stateXfer_next <= stateXferStartA;
				end if;

			elsif stateXfer=stateXferStartA then
				i := i + 1; -- IP impl.xfer.rising.startA.ext --- ILINE

				if i=imax then
					-- IP impl.xfer.rising.startA.step --- IBEGIN
					i := 0;

					sda_sig_next <= '0';
					-- IP impl.xfer.rising.startA.step --- IEND

					stateXfer_next <= stateXferStartB;
				end if;

			elsif stateXfer=stateXferStartB then
				i := i + 1; -- IP impl.xfer.rising.startB.ext --- ILINE

				if i=imax then
					-- IP impl.xfer.rising.startB.step --- IBEGIN
					i := 0;

					bitcnt := 0;
					-- IP impl.xfer.rising.startB.step --- IEND

					stateXfer_next <= stateXferBitA;
				end if;

			elsif stateXfer=stateXferBitA then
				-- IP impl.xfer.rising.bitA.ext --- IBEGIN
				if bytecnt=0 then
					if bitcnt=7 then
						sda_sig_next <= '0';
					else
						sda_sig_next <= devaddr(7-bitcnt);
					end if;
				elsif bytecnt=1 then
					sda_sig_next <= regaddr(15-bitcnt);
				elsif bytecnt=2 then
					sda_sig_next <= regaddr(7-bitcnt);
				elsif bytecnt=3 then
					if readNotWrite='1' then
						if bitcnt=7 then
							sda_sig_next <= '1';
						else
							sda_sig_next <= devaddr(7-bitcnt);
						end if;
					else
						sda_sig_next <= send(15-bitcnt);
					end if;
				elsif bytecnt=4 then
					if readNotWrite='1' then
						sda_sig_next <= '1';
					else
						sda_sig_next <= send(7-bitcnt);
					end if;
				else
					sda_sig_next <= '1';
				end if;

				i := i + 1;
				-- IP impl.xfer.rising.bitA.ext --- IEND

				if i=imax then
					i := 0; -- IP impl.xfer.rising.bitA.step --- ILINE

					stateXfer_next <= stateXferBitB;
				end if;

			elsif stateXfer=stateXferBitB then
				-- IP impl.xfer.rising.bitB.ext --- IBEGIN
				if bytecnt=4 then
					recvraw(15-bitcnt) := sda_in;
				elsif bytecnt=5 then
					recvraw(7-bitcnt) := sda_in;
				end if;

				i := i + 1;
				-- IP impl.xfer.rising.bitB.ext --- IEND

				if i=imax then
					-- IP impl.xfer.rising.bitB.step --- IBEGIN
					i := 0;

					bitcnt := bitcnt + 1;
					-- IP impl.xfer.rising.bitB.step --- IEND

					if bitcnt=8 then
						stateXfer_next <= stateXferAckA;

					else
						stateXfer_next <= stateXferBitA;
					end if;
				end if;

			elsif stateXfer=stateXferAckA then
				-- IP impl.xfer.rising.ackA.ext --- IBEGIN
				if (readNotWrite='1' and bytecnt=4) then
					sda_sig_next <= '0';
				else
					sda_sig_next <= '1';
				end if;

				i := i + 1;
				-- IP impl.xfer.rising.ackA.ext --- IEND

				if i=imax then
					i := 0; -- IP impl.xfer.rising.ackA.step --- ILINE

					stateXfer_next <= stateXferAckB;
				end if;

			elsif stateXfer=stateXferAckB then
				i := i + 1; -- IP impl.xfer.rising.ackB.ext --- ILINE

				if i=imax then
					-- IP impl.xfer.rising.ackB.step --- IBEGIN
					i := 0;

					bitcnt := 0;

					bytecnt := bytecnt + 1;
					-- IP impl.xfer.rising.ackB.step --- IEND

					if bytecnt=3 then
						if readNotWrite='1' then
							stateXfer_next <= stateXferRestart;

						else
							stateXfer_next <= stateXferBitA;
						end if;

					elsif ((bytecnt=5 and readNotWrite='0') or (bytecnt=6 and readNotWrite='1')) then
						sda_sig_next <= '0'; -- IP impl.xfer.rising.ackB.prepStop --- ILINE

						stateXfer_next <= stateXferStopA;

					else
						stateXfer_next <= stateXferBitA;
					end if;
				end if;

			elsif stateXfer=stateXferRestart then
				i := i + 1; -- IP impl.xfer.rising.restart.ext --- ILINE

				if i=imax then
					i := 0; -- IP impl.xfer.rising.restart.step --- ILINE

					stateXfer_next <= stateXferStartA;
				end if;

			elsif stateXfer=stateXferStopA then
				i := i + 1; -- IP impl.xfer.rising.stopA.ext --- ILINE

				if i=imax then
					i := 0; -- IP impl.xfer.rising.stopA.step --- ILINE

					stateXfer_next <= stateXferStopB;
				end if;

			elsif stateXfer=stateXferStopB then
				i := i + 1; -- IP impl.xfer.rising.stopB.ext --- ILINE

				if i=imax then
					-- IP impl.xfer.rising.stopB.step --- IBEGIN
					i := 0;
					sda_sig_next <= '1';
					-- IP impl.xfer.rising.stopB.step --- IEND

					stateXfer_next <= stateXferStopC;
				end if;

			elsif stateXfer=stateXferStopC then
				i := i + 1; -- IP impl.xfer.rising.stopC.ext --- ILINE

				if i=imax then
					-- IP impl.xfer.rising.stopC.step --- IBEGIN
					if readNotWrite='1' then
						recv_sig_next <= recvraw;
					end if;
					-- IP impl.xfer.rising.stopC.step --- IEND

					stateXfer_next <= stateXferDone;
				end if;

			elsif stateXfer=stateXferDone then
				if req='0' then
					stateXfer_next <= stateXferInit;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.xfer.rising --- END

	-- IP impl.xfer.falling --- BEGIN
	process (mclk)
		-- IP impl.xfer.falling.vars --- BEGIN
		-- IP impl.xfer.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateXfer <= stateXfer_next;
			recv_sig <= recv_sig_next;
			sda_sig <= sda_sig_next;
		end if;
	end process;
	-- IP impl.xfer.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end I2c;



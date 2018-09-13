-- file Uartrx_v1_1.vhd
-- Uartrx_v1_1 module implementation
-- author Alexander Wirthmueller
-- date created: 6 Aug 2016
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Uartrx_v1_1 is
	generic(
		fMclk: natural range 1 to 1000000;

		fSclk: natural range 100 to 50000000
	);
	port(
		reset: in std_logic;

		mclk: in std_logic;

		req: in std_logic;
		ack: out std_logic;
		dne: out std_logic;

		len: in std_logic_vector(16 downto 0);

		d: out std_logic_vector(7 downto 0);
		strbD: out std_logic;

		rxd: in std_logic;

		burst: in std_logic
	);
end Uartrx_v1_1;

architecture Uartrx_v1_1 of Uartrx_v1_1 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	-- unsolicited transfer monitor (mon)
	type stateMon_t is (
		stateMonInit,
		stateMonIdle,
		stateMonBusyA, stateMonBusyB, stateMonBusyC
	);
	signal stateMon: stateMon_t := stateMonInit;

	signal rng: std_logic;

	-- receive operation (recv)
	type stateRecv_t is (
		stateRecvInit,
		stateRecvWaitStart,
		stateRecvStart, -- strb low
		stateRecvData, -- strb low
		stateRecvStop,
		stateRecvDone
	);
	signal stateRecv: stateRecv_t := stateRecvInit;

	constant tbit: natural := ((1000*fMclk)/fSclk);
	constant tbithalf: natural := ((500*fMclk)/fSclk);

	signal monrestart: std_logic;

	signal ack_sig: std_logic;

	signal d_sig: std_logic_vector(7 downto 0);

begin

	------------------------------------------------------------------------
	-- implementation: unsolicited transfer monitor (mon)
	------------------------------------------------------------------------

	rng <= '1' when (stateMon=stateMonBusyA or stateMon=stateMonBusyB or stateMon=stateMonBusyC) else '0';

	process (reset, mclk, stateMon)
		variable i: natural range 0 to tbit;
		variable j: natural range 0 to 10;

	begin
		if reset='1' then
			stateMon <= stateMonInit;

		elsif rising_edge(mclk) then
			if (stateMon=stateMonInit or monrestart='1') then
				i := 0;
				j := 0;

				if monrestart='1' then
					stateMon <= stateMonInit;
				else
					stateMon <= stateMonIdle;
				end if;

			elsif stateMon=stateMonIdle then
				if rxd='0' then
					stateMon <= stateMonBusyA;
				end if;

			elsif stateMon=stateMonBusyA then
				i := i + 1;

				if i=tbithalf then
					i := 0;

					stateMon <= stateMonBusyB;
				end if;

			elsif stateMon=stateMonBusyB then
				i := i + 1;
				if i=tbit then
					i := 0;

					j := j + 1;
					if j=9 then
						j := 0;
						stateMon <= stateMonBusyC;
					end if;
				end if;

			elsif stateMon=stateMonBusyC then
				if rxd='0' then
					i := 0;
					j := 0;

					stateMon <= stateMonBusyA;
				else
					i := i + 1;
					if i=tbit then
						i := 0;

						j := j + 1;
						if j=10 then
							stateMon <= stateMonInit;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: receive operation (recv)
	------------------------------------------------------------------------

	dne <= '1' when stateRecv=stateRecvDone else '0';

	strbD <= '0' when (stateRecv=stateRecvStart or stateRecv=stateRecvData) else '1';

	ack <= ack_sig;

	d <= d_sig;

	process (reset, mclk)
		variable draw: std_logic_vector(7 downto 0);

		variable bitcnt: natural range 0 to 7;
		variable bytecnt: natural range 0 to 65536;

		variable i: natural range 0 to tbit;

	begin
		if reset='1' then
			stateRecv <= stateRecvInit;
			monrestart <= '0';
			ack_sig <= '0';
			d_sig <= (others => '0');

		elsif rising_edge(mclk) then
			if (stateRecv=stateRecvInit or req='0') then
				monrestart <= '0';
				ack_sig <= '0';
				d_sig <= (others => '0');

				draw := x"00";

				bytecnt := 0;

				if req='0' then
					stateRecv <= stateRecvInit;

				else
					if to_integer(unsigned(len))=0 then
						ack_sig <= '1';
						stateRecv <= stateRecvDone;
					elsif (burst='1' or rng='0') then
						stateRecv <= stateRecvWaitStart;
					end if;
				end if;

			elsif stateRecv=stateRecvWaitStart then
				if rxd='0' then
					ack_sig <= '1';

					bytecnt := bytecnt + 1; -- byte count received

					i := 0;

					stateRecv <= stateRecvStart;
				end if;
			
			elsif stateRecv=stateRecvStart then
				i := i + 1;
				if i=tbithalf then -- sample mid-bit
					i := 0;

					bitcnt := 0;

					stateRecv <= stateRecvData;
				end if;
			
			elsif stateRecv=stateRecvData then
				i := i + 1;
				if i=tbit then
					i := 0;

					draw(bitcnt) := rxd;

					if bitcnt=7 then
						d_sig <= draw;

						bitcnt := 0;

						stateRecv <= stateRecvStop;
					else
						bitcnt := bitcnt + 1;
					end if;
				end if;

			elsif stateRecv=stateRecvStop then
				i := i + 1;
				if i=tbit then
					i := 0;
					
					if rxd='1' then
						if bytecnt=to_integer(unsigned(len)) then
							monrestart <= '1';
							stateRecv <= stateRecvDone;
						else
							stateRecv <= stateRecvWaitStart;
						end if;

					else
						stateRecv <= stateRecvInit; -- should not happen
					end if;
				end if;

			elsif stateRecv=stateRecvDone then
				monrestart <= '0';

				-- if req='0' then
				-- 	stateRecv <= stateRecvInit;
				-- end if;
			end if;
		end if;
	end process;

end Uartrx_v1_1;

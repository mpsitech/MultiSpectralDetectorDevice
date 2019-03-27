-- file Uarttx_v1_0.vhd
-- Uarttx_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 6 Aug 2016
-- date modified: 24 Jan 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Uarttx_v1_0 is
	generic(
		fMclk: natural range 1 to 1000000;

		fSclk: natural range 100 to 50000000;
		Nstop: natural range 1 to 8 := 1
	);
	port(
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
end Uarttx_v1_0;

architecture Uarttx_v1_0 of Uarttx_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	-- send operation (send)
	type stateSend_t is (
		stateSendInit,
		stateSendPrep,
		stateSendLoad,
		stateSendStart,
		stateSendData,
		stateSendStop,
		stateSendDone
	);
	signal stateSend: stateSend_t := stateSendInit;

	constant tbit: natural := ((1000*fMclk)/fSclk);

	signal strbD_sig: std_logic;

	signal txd_sig: std_logic;

begin

	------------------------------------------------------------------------
	-- implementation: send operation (send)
	------------------------------------------------------------------------

	ack <= '1' when (stateSend=stateSendPrep or stateSend=stateSendLoad or stateSend=stateSendStart or stateSend=stateSendData or stateSend=stateSendStop or stateSend=stateSendDone) else '0';

	dne <= '1' when stateSend=stateSendDone else '0';

	strbD <= strbD_sig;

	txd <= txd_sig;

	process (reset, mclk)
		variable d_var: std_logic_vector(7 downto 0);

		variable bitcnt: natural range 0 to 7;
		variable bytecnt: natural range 0 to 65536;

		variable i: natural range 0 to tbit;
		variable j: natural range 0 to Nstop;

	begin
		if reset='1' then
			stateSend <= stateSendInit;
			strbD_sig <= '1';
			txd_sig <= '1';

		elsif rising_edge(mclk) then
			if (stateSend=stateSendInit or req='0') then
				strbD_sig <= '1';
				txd_sig <= '1';
	
				bytecnt := 0;

				if req='0' then
					stateSend <= stateSendInit;
				else
					stateSend <= stateSendPrep;
				end if;

			elsif stateSend=stateSendPrep then
				if to_integer(unsigned(len))=0 then
					stateSend <= stateSendDone;
				else
					stateSend <= stateSendLoad;
				end if;

			elsif stateSend=stateSendLoad then
				txd_sig <= '0';

				d_var := d;

				bytecnt := bytecnt + 1; -- byte count put out for send
				if bytecnt/=to_integer(unsigned(len)) then
					strbD_sig <= '0';
				end if;

				i := 0;

				stateSend <= stateSendStart;

			elsif stateSend=stateSendStart then
				i := i + 1;
				if i=tbit then
					txd_sig <= d_var(0);

					bitcnt := 0;
					i := 0;

					stateSend <= stateSendData;
				end if;

			elsif stateSend=stateSendData then
				i := i + 1;
				if i=tbit then
					i := 0;
					
					if bitcnt=7 then
						txd_sig <= '1';

						j := 0;
						
						stateSend <= stateSendStop;
					else
						bitcnt := bitcnt + 1;
						txd_sig <= d_var(bitcnt);
					end if;
				end if;
			
			elsif stateSend=stateSendStop then
				i := i + 1;
				if i=tbit then
					i := 0;
	
					j := j + 1;

					if j=Nstop then
						if bytecnt=to_integer(unsigned(len)) then
							stateSend <= stateSendDone;
						else
							strbD_sig <= '1';
							stateSend <= stateSendLoad;
						end if;
					end if;
				end if;

			elsif stateSend=stateSendDone then
				-- if req='0' then
				-- 	stateSend <= stateSendInit;
				-- end if;
			end if;
		end if;
	end process;

end Uarttx_v1_0;


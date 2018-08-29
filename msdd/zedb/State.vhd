-- file State.vhd
-- State easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 26 Aug 2018
-- date modified: 26 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity State is
	port (
		reset: in std_logic;
		tkclk: in std_logic;

		getTixVZedbState: out std_logic_vector(7 downto 0);

		lwirrng: in std_logic;
		commok: in std_logic;

		ledg: out std_logic;
		ledr: out std_logic
	);
end State;

architecture State of State is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	constant tixVZedbStateNc: std_logic_vector(7 downto 0) := x"00";
	constant tixVZedbStateReady: std_logic_vector(7 downto 0) := x"01";
	constant tixVZedbStateActive: std_logic_vector(7 downto 0) := x"02";

	---- LED control (led)
	type stateLed_t is (
		stateLedOn,
		stateLedOff
	);
	signal stateLed, stateLed_next: stateLed_t := stateLedOn;

	signal ledg_sig: std_logic;
	signal ledr_sig: std_logic;

	-- IP sigs.led.cust --- INSERT

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: LED control (led)
	------------------------------------------------------------------------

	-- IP impl.led.wiring --- RBEGIN
	ledg_sig <= '1' when (commok='1' and (lwirrng='0' or (lwirrng='1' and stateLed=stateLedOn))) else '0';
	ledg <= ledg_sig;
	ledr_sig <= '1' when commok='0' else '0';
	ledr <= ledr_sig;

	getTixVZedbState <= tixVZedbStateNc when commok='0'
				else tixVZedbStateReady when lwirrng='0'
				else tixVZedbStateActive;
	-- IP impl.led.wiring --- REND

	-- IP impl.led.rising --- BEGIN
	process (reset, tkclk, stateLed)
		-- IP impl.led.rising.vars --- RBEGIN
		variable i: natural range 0 to 4000;
		-- IP impl.led.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.led.rising.asyncrst --- RBEGIN
			stateLed_next <= stateLedOn;

			i := 0;
			-- IP impl.led.rising.asyncrst --- REND

		elsif rising_edge(tkclk) then
			if stateLed=stateLedOn then
				i := i + 1; -- IP impl.led.rising.on.ext --- ILINE

				if i=1000 then
					i := 0; -- IP impl.led.rising.on.prepOff --- ILINE

					stateLed_next <= stateLedOff;
				end if;

			elsif stateLed=stateLedOff then
				i := i + 1; -- IP impl.led.rising.off.ext --- ILINE

				if i=4000 then
					i := 0; -- IP impl.led.rising.off.prepOn --- ILINE

					stateLed_next <= stateLedOn;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.led.rising --- END

	-- IP impl.led.falling --- BEGIN
	process (tkclk)
		-- IP impl.led.falling.vars --- BEGIN
		-- IP impl.led.falling.vars --- END
	begin
		if falling_edge(tkclk) then
			stateLed <= stateLed_next;
		end if;
	end process;
	-- IP impl.led.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end State;



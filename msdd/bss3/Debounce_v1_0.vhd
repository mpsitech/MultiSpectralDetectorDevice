-- file Debounce_v1_0.vhd
-- Debounce_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 4 Aug 2016
-- date modified: 5 Apr 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debounce_v1_0 is
	generic (
		tdead: natural range 0 to 10000 := 100 -- in tkclk clocks
	);
	port (
		reset: in std_logic;

		mclk: in std_logic;

		tkclk: in std_logic;

		noisy: in std_logic;
		clean: out std_logic
	);
end Debounce_v1_0;

architecture Debounce_v1_0 of Debounce_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- main operation (op)
	type stateOp_t is (
		stateOpIdle,
		stateOpDeadA, stateOpDeadB
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpIdle;

	signal clean_sig: std_logic;

begin

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	clean <= clean_sig;

	process (reset, mclk)
		variable i: natural range 0 to tdead;

	begin
		if reset='1' then
			i := 0;
			clean_sig <= '0';
			stateOp_next <= stateOpIdle;

		elsif rising_edge(mclk) then
			if stateOp=stateOpIdle then
				if noisy/=clean_sig then
					clean_sig <= noisy;

					i := 0;
					stateOp_next <= stateOpDeadA;
				end if;

			elsif stateOp=stateOpDeadA then
				if i=tdead then
					stateOp_next <= stateOpIdle;
				elsif tkclk='1' then
					stateOp_next <= stateOpDeadB;
				end if;
		
			elsif (stateOp=stateOpDeadB and tkclk='0') then
				i := i + 1;
				stateOp_next <= stateOpDeadA;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
		end if;
	end process;

end Debounce_v1_0;


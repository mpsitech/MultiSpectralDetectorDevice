-- file Timeout_v1_0.vhd
-- Timeout_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 16 Jan 2017
-- date modified: 6 Apr 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timeout_v1_0 is
	generic (
		twait: natural range 1 to 10000 -- in tkclk clocks
	);
	port (
		reset: in std_logic;

		mclk: in std_logic;

		tkclk: in std_logic;

		restart: in std_logic;
		timeout: out std_logic
	);
end Timeout_v1_0;

architecture Timeout_v1_0 of Timeout_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	-- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpWaitA, stateOpWaitB,
		stateOpDone
	);
	signal stateOp: stateOp_t := stateOpInit;

begin

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	timeout <= '1' when (stateOp=stateOpDone and restart='0') else '0';

	process (reset, mclk, stateOp)
		variable i: natural range 0 to twait;

	begin
		if reset='1' then
			stateOp <= stateOpInit;

		elsif rising_edge(mclk) then
			if (restart='1' or stateOp=stateOpInit) then
				i := 0;

				if restart='1' then
					stateOp <= stateOpInit;
				else
					stateOp <= stateOpWaitA;
				end if;

			elsif stateOp=stateOpWaitA then
				if i=twait then
					stateOp <= stateOpDone;

				elsif tkclk='1' then
					stateOp <= stateOpWaitB;
				end if;
		
			elsif stateOp=stateOpWaitB then
				if tkclk='0' then
					i := i + 1;
					stateOp <= stateOpWaitA;
				end if;

			elsif stateOp=stateOpDone then
				-- if restart='1' then
				-- 	stateOp <= stateOpInit;
				-- end if;
			end if;
		end if;
	end process;

end Timeout_v1_0;


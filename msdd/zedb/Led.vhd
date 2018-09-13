-- file Led.vhd
-- Led easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 9 Aug 2018
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Led is
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		reqInvSetTon15: in std_logic;
		ackInvSetTon15: out std_logic;

		setTon15Ton15: in std_logic_vector(7 downto 0);

		reqInvSetTon60: in std_logic;
		ackInvSetTon60: out std_logic;

		setTon60Ton60: in std_logic_vector(7 downto 0);

		d15pwm: out std_logic;
		d60pwm: out std_logic
	);
end Led;

architecture Led of Led is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- 15deg LED PWM (15)
	type state15_t is (
		state15Init,
		state15Inv,
		state15Start,
		state15RunA, state15RunB
	);
	signal state15: state15_t := state15Init;

	signal ackInvSetTon15_sig: std_logic;
	signal d15pwm_sig: std_logic;

	-- IP sigs.15.cust --- INSERT

	---- 60deg LED PWM (60)
	type state60_t is (
		state60Init,
		state60Inv,
		state60Start,
		state60RunA, state60RunB
	);
	signal state60: state60_t := state60Init;

	signal ackInvSetTon60_sig: std_logic;
	signal d60pwm_sig: std_logic;

	-- IP sigs.60.cust --- INSERT

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: 15deg LED PWM (15)
	------------------------------------------------------------------------

	-- IP impl.15.wiring --- BEGIN
	ackInvSetTon15_sig <= '1' when state15=state15Inv else '0';
	ackInvSetTon15 <= ackInvSetTon15_sig;
	d15pwm <= d15pwm_sig;
	-- IP impl.15.wiring --- END

	-- IP impl.15.rising --- BEGIN
	process (reset, mclk, state15)
		-- IP impl.15.rising.vars --- RBEGIN
		variable i: natural range 0 to 100;
		-- IP impl.15.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.15.rising.asyncrst --- BEGIN
			state15 <= state15Init;
			d15pwm_sig <= '0';
			-- IP impl.15.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (state15=state15Init or (state15/=state15Inv and reqInvSetTon15='1')) then
				-- IP impl.15.rising.syncrst --- BEGIN
				d15pwm_sig <= '0';

				-- IP impl.15.rising.syncrst --- END

				if reqInvSetTon15='1' then
					state15 <= state15Inv;

				else
					state15 <= state15Start;
				end if;

			elsif state15=state15Inv then
				if reqInvSetTon15='0' then
					state15 <= state15Init;
				end if;

			elsif state15=state15Start then
				-- IP impl.15.rising.start.ext --- IBEGIN
				i := 0;

				if to_integer(unsigned(setTon15Ton15))=0 then
					d15pwm_sig <= '0';
				else
					d15pwm_sig <= '1';
				end if;
				-- IP impl.15.rising.start.ext --- IEND

				if tkclk='0' then
					state15 <= state15RunB;

				else
					state15 <= state15RunA;
				end if;

			elsif state15=state15RunA then
				if tkclk='0' then
					if i=100 then
						state15 <= state15Start;

					else
						-- IP impl.15.rising.runA --- IBEGIN
						if i=to_integer(unsigned(setTon15Ton15)) then
							d15pwm_sig <= '0';
						end if;
						-- IP impl.15.rising.runA --- IEND

						state15 <= state15RunB;
					end if;
				end if;

			elsif state15=state15RunB then
				if tkclk='1' then
					i := i + 1; -- IP impl.15.rising.runB --- ILINE

					state15 <= state15RunA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.15.rising --- END

	------------------------------------------------------------------------
	-- implementation: 60deg LED PWM (60)
	------------------------------------------------------------------------

	-- IP impl.60.wiring --- BEGIN
	ackInvSetTon60_sig <= '1' when state60=state60Inv else '0';
	ackInvSetTon60 <= ackInvSetTon60_sig;
	d60pwm <= d60pwm_sig;
	-- IP impl.60.wiring --- END

	-- IP impl.60.rising --- BEGIN
	process (reset, mclk, state60)
		-- IP impl.60.rising.vars --- RBEGIN
		variable i: natural range 0 to 100;
		-- IP impl.60.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.60.rising.asyncrst --- BEGIN
			state60 <= state60Init;
			d60pwm_sig <= '0';
			-- IP impl.60.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (state60=state60Init or (state60/=state60Inv and reqInvSetTon60='1')) then
				-- IP impl.60.rising.syncrst --- BEGIN
				d60pwm_sig <= '0';

				-- IP impl.60.rising.syncrst --- END

				if reqInvSetTon60='1' then
					state60 <= state60Inv;

				else
					state60 <= state60Start;
				end if;

			elsif state60=state60Inv then
				if reqInvSetTon60='0' then
					state60 <= state60Init;
				end if;

			elsif state60=state60Start then
				-- IP impl.60.rising.start.ext --- IBEGIN
				i := 0;

				if to_integer(unsigned(setTon60Ton60))=0 then
					d60pwm_sig <= '0';
				else
					d60pwm_sig <= '1';
				end if;
				-- IP impl.60.rising.start.ext --- IEND

				if tkclk='0' then
					state60 <= state60RunB;

				else
					state60 <= state60RunA;
				end if;

			elsif state60=state60RunA then
				if tkclk='0' then
					if i=100 then
						state60 <= state60Start;

					else
						-- IP impl.60.rising.runA --- IBEGIN
						if i=to_integer(unsigned(setTon60Ton60)) then
							d60pwm_sig <= '0';
						end if;
						-- IP impl.60.rising.runA --- IEND

						state60 <= state60RunB;
					end if;
				end if;

			elsif state60=state60RunB then
				if tkclk='1' then
					i := i + 1; -- IP impl.60.rising.runB --- ILINE

					state60 <= state60RunA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.60.rising --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Led;



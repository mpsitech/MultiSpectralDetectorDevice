-- file Quad7seg_v1_0.vhd
-- Quad7seg_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 28 Nov 2016
-- date modified: 28 Nov 2016

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Quad7seg_v1_0 is
	port (
		reset: in std_logic;

		tkclk: in std_logic;

		ssa: out std_logic_vector(3 downto 0);
		sscdp: out std_logic;
		ssc: out std_logic_vector(6 downto 0);

		d: in std_logic_vector(15 downto 0)
	);
end Quad7seg_v1_0;

architecture Quad7seg_v1_0 of Quad7seg_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- main operation (op)
	signal digit: natural range 0 to 3 := 0;
	signal value: natural range 0 to 15 := 0;

begin

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	ssa <= "1110" when digit=0
		else "1101" when digit=1
		else "1011" when digit=2
		else "0111" when digit=3
		else "1111";

	sscdp <= '1';

	ssc <= "1000000" when value=0
		else "1111001" when value=1
		else "0100100" when value=2
		else "0110000" when value=3
		else "0011001" when value=4
		else "0010010" when value=5
		else "0000010" when value=6
		else "1111000" when value=7
		else "0000000" when value=8
		else "0010000" when value=9
		else "0001000" when value=10
		else "0000011" when value=11
		else "1000110" when value=12
		else "0100001" when value=13
		else "0000110" when value=14
		else "0001110" when value=15
		else "1111111";

	process (reset, tkclk)
		variable i: natural range 0 to 25; -- 400Hz/4=100Hz refresh rate

	begin
		if reset='1' then
			i := 0;
			
			digit <= 0;
			value <= 0;

		elsif rising_edge(tkclk) then
			i := i + 1;

			if i=25 then
				i := 0;

				if digit=0 then
					value <= to_integer(unsigned(d(7 downto 4)));
					digit <= 1;
				elsif digit=1 then
					value <= to_integer(unsigned(d(11 downto 8)));
					digit <= 2;
				elsif digit=2 then
					value <= to_integer(unsigned(d(15 downto 12)));
					digit <= 3;
				elsif digit=3 then
					value <= to_integer(unsigned(d(3 downto 0)));
					digit <= 0;
				end if;
			end if;
		end if;
	end process;

end Quad7seg_v1_0;


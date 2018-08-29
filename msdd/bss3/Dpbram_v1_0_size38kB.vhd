-- file Dpbram_v1_0_size38kB.vhd
-- Dpbram_v1_0_size38kB dpbram_v1_0 implementation
-- author Alexander Wirthmueller
-- date created: 26 Aug 2018
-- date modified: 26 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Dpbram_v1_0_size38kB is
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
end Dpbram_v1_0_size38kB;

architecture Dpbram_v1_0_size38kB of Dpbram_v1_0_size38kB is

	-- IP sigs --- BEGIN
	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	signal enA1: std_logic := '0';
	signal enA2: std_logic := '0';
	signal enA3: std_logic := '0';
	signal enA4: std_logic := '0';
	signal enA5: std_logic := '0';
	signal enA6: std_logic := '0';
	signal enA7: std_logic := '0';
	signal enA8: std_logic := '0';
	signal enA9: std_logic := '0';
	signal enA10: std_logic := '0';
	signal enA11: std_logic := '0';
	signal enA12: std_logic := '0';
	signal enA13: std_logic := '0';
	signal enA14: std_logic := '0';
	signal enA15: std_logic := '0';
	signal enA16: std_logic := '0';
	signal enA17: std_logic := '0';
	signal enA18: std_logic := '0';
	signal enA0: std_logic := '0';

	signal drdA1: std_logic_vector(7 downto 0) := x"00";
	signal drdA2: std_logic_vector(7 downto 0) := x"00";
	signal drdA3: std_logic_vector(7 downto 0) := x"00";
	signal drdA4: std_logic_vector(7 downto 0) := x"00";
	signal drdA5: std_logic_vector(7 downto 0) := x"00";
	signal drdA6: std_logic_vector(7 downto 0) := x"00";
	signal drdA7: std_logic_vector(7 downto 0) := x"00";
	signal drdA8: std_logic_vector(7 downto 0) := x"00";
	signal drdA9: std_logic_vector(7 downto 0) := x"00";
	signal drdA10: std_logic_vector(7 downto 0) := x"00";
	signal drdA11: std_logic_vector(7 downto 0) := x"00";
	signal drdA12: std_logic_vector(7 downto 0) := x"00";
	signal drdA13: std_logic_vector(7 downto 0) := x"00";
	signal drdA14: std_logic_vector(7 downto 0) := x"00";
	signal drdA15: std_logic_vector(7 downto 0) := x"00";
	signal drdA16: std_logic_vector(7 downto 0) := x"00";
	signal drdA17: std_logic_vector(7 downto 0) := x"00";
	signal drdA18: std_logic_vector(7 downto 0) := x"00";
	signal drdA0: std_logic_vector(7 downto 0) := x"00";

	signal enB1: std_logic := '0';
	signal enB2: std_logic := '0';
	signal enB3: std_logic := '0';
	signal enB4: std_logic := '0';
	signal enB5: std_logic := '0';
	signal enB6: std_logic := '0';
	signal enB7: std_logic := '0';
	signal enB8: std_logic := '0';
	signal enB9: std_logic := '0';
	signal enB10: std_logic := '0';
	signal enB11: std_logic := '0';
	signal enB12: std_logic := '0';
	signal enB13: std_logic := '0';
	signal enB14: std_logic := '0';
	signal enB15: std_logic := '0';
	signal enB16: std_logic := '0';
	signal enB17: std_logic := '0';
	signal enB18: std_logic := '0';
	signal enB0: std_logic := '0';

	signal drdB1: std_logic_vector(7 downto 0) := x"00";
	signal drdB2: std_logic_vector(7 downto 0) := x"00";
	signal drdB3: std_logic_vector(7 downto 0) := x"00";
	signal drdB4: std_logic_vector(7 downto 0) := x"00";
	signal drdB5: std_logic_vector(7 downto 0) := x"00";
	signal drdB6: std_logic_vector(7 downto 0) := x"00";
	signal drdB7: std_logic_vector(7 downto 0) := x"00";
	signal drdB8: std_logic_vector(7 downto 0) := x"00";
	signal drdB9: std_logic_vector(7 downto 0) := x"00";
	signal drdB10: std_logic_vector(7 downto 0) := x"00";
	signal drdB11: std_logic_vector(7 downto 0) := x"00";
	signal drdB12: std_logic_vector(7 downto 0) := x"00";
	signal drdB13: std_logic_vector(7 downto 0) := x"00";
	signal drdB14: std_logic_vector(7 downto 0) := x"00";
	signal drdB15: std_logic_vector(7 downto 0) := x"00";
	signal drdB16: std_logic_vector(7 downto 0) := x"00";
	signal drdB17: std_logic_vector(7 downto 0) := x"00";
	signal drdB18: std_logic_vector(7 downto 0) := x"00";
	signal drdB0: std_logic_vector(7 downto 0) := x"00";
	-- IP sigs --- END

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myBram0 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA0,
			DOB => drdB0,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA0,
			ENB => enB0,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram1 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA1,
			DOB => drdB1,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA1,
			ENB => enB1,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram10 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA10,
			DOB => drdB10,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA10,
			ENB => enB10,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram11 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA11,
			DOB => drdB11,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA11,
			ENB => enB11,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram12 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA12,
			DOB => drdB12,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA12,
			ENB => enB12,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram13 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA13,
			DOB => drdB13,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA13,
			ENB => enB13,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram14 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA14,
			DOB => drdB14,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA14,
			ENB => enB14,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram15 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA15,
			DOB => drdB15,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA15,
			ENB => enB15,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram16 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA16,
			DOB => drdB16,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA16,
			ENB => enB16,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram17 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA17,
			DOB => drdB17,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA17,
			ENB => enB17,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram18 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA18,
			DOB => drdB18,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA18,
			ENB => enB18,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram2 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA2,
			DOB => drdB2,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA2,
			ENB => enB2,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram3 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA3,
			DOB => drdB3,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA3,
			ENB => enB3,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram4 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA4,
			DOB => drdB4,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA4,
			ENB => enB4,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram5 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA5,
			DOB => drdB5,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA5,
			ENB => enB5,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram6 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA6,
			DOB => drdB6,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA6,
			ENB => enB6,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram7 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA7,
			DOB => drdB7,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA7,
			ENB => enB7,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram8 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA8,
			DOB => drdB8,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA8,
			ENB => enB8,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	myBram9 : RAMB16_S9_S9
		generic map (
			INIT_A => x"000000",
			INIT_B => x"000000",
			SRVAL_A => x"000000",
			SRVAL_B => x"000000",
			WRITE_MODE_A => "WRITE_FIRST",
			WRITE_MODE_B => "WRITE_FIRST",
			SIM_COLLISION_CHECK => "ALL"
		)
		port map (
			DOA => drdA9,
			DOB => drdB9,
			DOPA => open,
			DOPB => open,
			ADDRA => aA(10 downto 0),
			ADDRB => aB(10 downto 0),
			CLKA => clkA,
			CLKB => clkB,
			DIA => dwrA,
			DIB => dwrB,
			DIPA => "0",
			DIPB => "0",
			ENA => enA9,
			ENB => enB9,
			SSRA => '0',
			SSRB => '0',
			WEA => weA,
			WEB => weB
		);

	-- IP impl --- BEGIN
	------------------------------------------------------------------------
	-- implementation 
	------------------------------------------------------------------------

	enA0 <= '1' when (aA(15 downto 11)="00000" and enA='1') else '0';
	enA1 <= '1' when (aA(15 downto 11)="00001" and enA='1') else '0';
	enA2 <= '1' when (aA(15 downto 11)="00010" and enA='1') else '0';
	enA3 <= '1' when (aA(15 downto 11)="00011" and enA='1') else '0';
	enA4 <= '1' when (aA(15 downto 11)="00100" and enA='1') else '0';
	enA5 <= '1' when (aA(15 downto 11)="00101" and enA='1') else '0';
	enA6 <= '1' when (aA(15 downto 11)="00110" and enA='1') else '0';
	enA7 <= '1' when (aA(15 downto 11)="00111" and enA='1') else '0';
	enA8 <= '1' when (aA(15 downto 11)="01000" and enA='1') else '0';
	enA9 <= '1' when (aA(15 downto 11)="01001" and enA='1') else '0';
	enA10 <= '1' when (aA(15 downto 11)="01010" and enA='1') else '0';
	enA11 <= '1' when (aA(15 downto 11)="01011" and enA='1') else '0';
	enA12 <= '1' when (aA(15 downto 11)="01100" and enA='1') else '0';
	enA13 <= '1' when (aA(15 downto 11)="01101" and enA='1') else '0';
	enA14 <= '1' when (aA(15 downto 11)="01110" and enA='1') else '0';
	enA15 <= '1' when (aA(15 downto 11)="01111" and enA='1') else '0';
	enA16 <= '1' when (aA(15 downto 11)="10000" and enA='1') else '0';
	enA17 <= '1' when (aA(15 downto 11)="10001" and enA='1') else '0';
	enA18 <= '1' when (aA(15 downto 11)="10010" and enA='1') else '0';

	drdA <= drdA0 when aA(15 downto 11)="00000"
		else drdA1 when aA(15 downto 11)="00001"
		else drdA2 when aA(15 downto 11)="00010"
		else drdA3 when aA(15 downto 11)="00011"
		else drdA4 when aA(15 downto 11)="00100"
		else drdA5 when aA(15 downto 11)="00101"
		else drdA6 when aA(15 downto 11)="00110"
		else drdA7 when aA(15 downto 11)="00111"
		else drdA8 when aA(15 downto 11)="01000"
		else drdA9 when aA(15 downto 11)="01001"
		else drdA10 when aA(15 downto 11)="01010"
		else drdA11 when aA(15 downto 11)="01011"
		else drdA12 when aA(15 downto 11)="01100"
		else drdA13 when aA(15 downto 11)="01101"
		else drdA14 when aA(15 downto 11)="01110"
		else drdA15 when aA(15 downto 11)="01111"
		else drdA16 when aA(15 downto 11)="10000"
		else drdA17 when aA(15 downto 11)="10001"
		else drdA18 when aA(15 downto 11)="10010"
		else x"00";

	enB0 <= '1' when (aB(15 downto 11)="00000" and enB='1') else '0';
	enB1 <= '1' when (aB(15 downto 11)="00001" and enB='1') else '0';
	enB2 <= '1' when (aB(15 downto 11)="00010" and enB='1') else '0';
	enB3 <= '1' when (aB(15 downto 11)="00011" and enB='1') else '0';
	enB4 <= '1' when (aB(15 downto 11)="00100" and enB='1') else '0';
	enB5 <= '1' when (aB(15 downto 11)="00101" and enB='1') else '0';
	enB6 <= '1' when (aB(15 downto 11)="00110" and enB='1') else '0';
	enB7 <= '1' when (aB(15 downto 11)="00111" and enB='1') else '0';
	enB8 <= '1' when (aB(15 downto 11)="01000" and enB='1') else '0';
	enB9 <= '1' when (aB(15 downto 11)="01001" and enB='1') else '0';
	enB10 <= '1' when (aB(15 downto 11)="01010" and enB='1') else '0';
	enB11 <= '1' when (aB(15 downto 11)="01011" and enB='1') else '0';
	enB12 <= '1' when (aB(15 downto 11)="01100" and enB='1') else '0';
	enB13 <= '1' when (aB(15 downto 11)="01101" and enB='1') else '0';
	enB14 <= '1' when (aB(15 downto 11)="01110" and enB='1') else '0';
	enB15 <= '1' when (aB(15 downto 11)="01111" and enB='1') else '0';
	enB16 <= '1' when (aB(15 downto 11)="10000" and enB='1') else '0';
	enB17 <= '1' when (aB(15 downto 11)="10001" and enB='1') else '0';
	enB18 <= '1' when (aB(15 downto 11)="10010" and enB='1') else '0';

	drdB <= drdB0 when aB(15 downto 11)="00000"
		else drdB1 when aB(15 downto 11)="00001"
		else drdB2 when aB(15 downto 11)="00010"
		else drdB3 when aB(15 downto 11)="00011"
		else drdB4 when aB(15 downto 11)="00100"
		else drdB5 when aB(15 downto 11)="00101"
		else drdB6 when aB(15 downto 11)="00110"
		else drdB7 when aB(15 downto 11)="00111"
		else drdB8 when aB(15 downto 11)="01000"
		else drdB9 when aB(15 downto 11)="01001"
		else drdB10 when aB(15 downto 11)="01010"
		else drdB11 when aB(15 downto 11)="01011"
		else drdB12 when aB(15 downto 11)="01100"
		else drdB13 when aB(15 downto 11)="01101"
		else drdB14 when aB(15 downto 11)="01110"
		else drdB15 when aB(15 downto 11)="01111"
		else drdB16 when aB(15 downto 11)="10000"
		else drdB17 when aB(15 downto 11)="10001"
		else drdB18 when aB(15 downto 11)="10010"
		else x"00";
	-- IP impl --- END

end Dpbram_v1_0_size38kB;


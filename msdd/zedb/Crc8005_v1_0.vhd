-- file Crc8005_v1_0.vhd
-- Crc8005_v1_0 crcspec_v1_0 implementation
-- author Alexander Wirthmueller
-- date created: 9 Aug 2018
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Crc8005_v1_0 is
	port (
		reset: in std_logic;
		mclk: in std_logic;

		req: in std_logic;
		ack: out std_logic;
		dne: out std_logic;

		captNotFin: in std_logic;

		d: in std_logic_vector(7 downto 0);
		strbD: in std_logic;

		crc: out std_logic_vector(15 downto 0)
	);
end Crc8005_v1_0;

architecture Crc8005_v1_0 of Crc8005_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpCaptA, stateOpCaptB, stateOpCaptC,
		stateOpDone
	);
	signal stateOp: stateOp_t := stateOpInit;

	signal crcold: std_logic_vector(15 downto 0);
	signal dinc: std_logic_vector(7 downto 0);

	signal crc_sig: std_logic_vector(15 downto 0);

begin

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	ack <= '1' when (stateOp=stateOpCaptA or stateOp=stateOpCaptB or stateOp=stateOpCaptC or stateOp=stateOpDone) else '0';
	dne <= '1' when stateOp=stateOpDone else '0';

	crc <= crc_sig;
	
	process (reset, mclk)
	begin
		if reset='1' then
			stateOp <= stateOpInit;
			crcold <= x"0000";
			dinc <= x"00";
			crc_sig <= x"0000";

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or req='0') then
				crcold <= x"0000";
				dinc <= x"00";
				crc_sig <= x"0000";

				if (req='1' and captNotFin='1') then
					stateOp <= stateOpCaptA;
				else
					stateOp <= stateOpInit;
				end if;

			elsif stateOp=stateOpCaptA then
				if captNotFin='0' then
					stateOp <= stateOpDone;
				elsif strbD='1' then
					crcold <= crc_sig;
					dinc <= d;
					stateOp <= stateOpCaptB;
				end if;

			elsif stateOp=stateOpCaptB then
				crc_sig(15) <= dinc(7) xor dinc(6) xor dinc(5) xor dinc(4) xor dinc(3) xor dinc(2) xor dinc(1) xor dinc(0) xor crcold(7) xor crcold(8) xor crcold(9) xor crcold(10) xor crcold(11) xor crcold(12) xor crcold(13) xor crcold(14) xor crcold(15);
				crc_sig(14) <= crcold(6);
				crc_sig(13) <= crcold(5);
				crc_sig(12) <= crcold(4);
				crc_sig(11) <= crcold(3);
				crc_sig(10) <= crcold(2);
				crc_sig(9) <= dinc(7) xor crcold(1) xor crcold(15);
				crc_sig(8) <= dinc(7) xor dinc(6) xor crcold(0) xor crcold(14) xor crcold(15);
				crc_sig(7) <= dinc(6) xor dinc(5) xor crcold(13) xor crcold(14);
				crc_sig(6) <= dinc(5) xor dinc(4) xor crcold(12) xor crcold(13);
				crc_sig(5) <= dinc(4) xor dinc(3) xor crcold(11) xor crcold(12);
				crc_sig(4) <= dinc(3) xor dinc(2) xor crcold(10) xor crcold(11);
				crc_sig(3) <= dinc(2) xor dinc(1) xor crcold(9) xor crcold(10);
				crc_sig(2) <= dinc(1) xor dinc(0) xor crcold(8) xor crcold(9);
				crc_sig(1) <= dinc(7) xor dinc(6) xor dinc(5) xor dinc(4) xor dinc(3) xor dinc(2) xor dinc(1) xor crcold(9) xor crcold(10) xor crcold(11) xor crcold(12) xor crcold(13) xor crcold(14) xor crcold(15);
				crc_sig(0) <= dinc(7) xor dinc(6) xor dinc(5) xor dinc(4) xor dinc(3) xor dinc(2) xor dinc(1) xor dinc(0) xor crcold(8) xor crcold(9) xor crcold(10) xor crcold(11) xor crcold(12) xor crcold(13) xor crcold(14) xor crcold(15);

				stateOp <= stateOpCaptC;

			elsif stateOp=stateOpCaptC then
				if captNotFin='0' then
					stateOp <= stateOpDone;
				elsif strbD='0' then
					stateOp <= stateOpCaptA;
				end if;

			elsif stateOp=stateOpDone then
				-- if req='0' then
				-- 	stateOp <= stateOpInit;
				-- end if;
			end if;
		end if;
	end process;

end Crc8005_v1_0;


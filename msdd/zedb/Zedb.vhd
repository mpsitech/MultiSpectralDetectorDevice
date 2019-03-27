-- file Zedb.vhd
-- ZedBoard global constants and types
-- author Alexander Wirthmueller
-- date created: 18 Oct 2018
-- date modified: 18 Oct 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Dbecore is
	constant fls8: std_logic_vector(7 downto 0) := x"AA";
	constant fls16: std_logic_vector(15 downto 0) := x"AAAA";
	constant fls32: std_logic_vector(31 downto 0) := x"AAAAAAAA";

	constant tru8: std_logic_vector(7 downto 0) := x"55";
	constant tru16: std_logic_vector(15 downto 0) := x"5555";
	constant tru32: std_logic_vector(31 downto 0) := x"55555555";

	constant ixOpbufBuffer: natural := 0;
	constant ixOpbufController: natural := 1;
	constant ixOpbufCommand: natural := 2;
	constant ixOpbufLength: natural := 3;
	constant ixOpbufCrc: natural := 5;
end Dbecore;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Zedb is
	constant tixVControllerAdxl: std_logic_vector(7 downto 0) := x"01";
	constant tixVControllerAlign: std_logic_vector(7 downto 0) := x"02";
	constant tixVControllerLed: std_logic_vector(7 downto 0) := x"03";
	constant tixVControllerLwiracq: std_logic_vector(7 downto 0) := x"04";
	constant tixVControllerLwirif: std_logic_vector(7 downto 0) := x"05";
	constant tixVControllerServo: std_logic_vector(7 downto 0) := x"06";
	constant tixVControllerState: std_logic_vector(7 downto 0) := x"07";
	constant tixVControllerTkclksrc: std_logic_vector(7 downto 0) := x"08";
	constant tixVControllerTrigger: std_logic_vector(7 downto 0) := x"09";
	constant tixVControllerVgaacq: std_logic_vector(7 downto 0) := x"0A";

	constant tixVStateNc: std_logic_vector(7 downto 0) := x"00";
	constant tixVStateReady: std_logic_vector(7 downto 0) := x"01";
	constant tixVStateActive: std_logic_vector(7 downto 0) := x"02";

	constant tixWBufferCmdretToHostif: std_logic_vector(7 downto 0) := x"01";
	constant tixWBufferHostifToCmdinv: std_logic_vector(7 downto 0) := x"02";
	constant tixWBufferAbufLwiracqToHostif: std_logic_vector(7 downto 0) := x"04";
	constant tixWBufferAbufVgaacqToHostif: std_logic_vector(7 downto 0) := x"08";
	constant tixWBufferBbufLwiracqToHostif: std_logic_vector(7 downto 0) := x"10";
	constant tixWBufferBbufVgaacqToHostif: std_logic_vector(7 downto 0) := x"20";

	constant tixVAdxlCommandGetAx: std_logic_vector(7 downto 0) := x"00";
	constant tixVAdxlCommandGetAy: std_logic_vector(7 downto 0) := x"01";
	constant tixVAdxlCommandGetAz: std_logic_vector(7 downto 0) := x"02";

	constant tixVAlignCommandSetSeq: std_logic_vector(7 downto 0) := x"00";

	constant tixVLedCommandSetTon15: std_logic_vector(7 downto 0) := x"00";
	constant tixVLedCommandSetTon60: std_logic_vector(7 downto 0) := x"01";

	constant tixVLwiracqCommandSetRng: std_logic_vector(7 downto 0) := x"00";
	constant tixVLwiracqCommandGetInfo: std_logic_vector(7 downto 0) := x"01";

	constant tixVLwirifCommandSetRng: std_logic_vector(7 downto 0) := x"00";

	constant tixVServoCommandSetTheta: std_logic_vector(7 downto 0) := x"00";
	constant tixVServoCommandSetPhi: std_logic_vector(7 downto 0) := x"01";

	constant tixVStateCommandGet: std_logic_vector(7 downto 0) := x"00";

	constant tixVTkclksrcCommandGetTkst: std_logic_vector(7 downto 0) := x"00";
	constant tixVTkclksrcCommandSetTkst: std_logic_vector(7 downto 0) := x"01";

	constant tixVTriggerCommandSetRng: std_logic_vector(7 downto 0) := x"00";
	constant tixVTriggerCommandSetTdlyLwir: std_logic_vector(7 downto 0) := x"01";
	constant tixVTriggerCommandSetTdlyVisr: std_logic_vector(7 downto 0) := x"02";
	constant tixVTriggerCommandSetTfrm: std_logic_vector(7 downto 0) := x"03";

	constant tixVVgaacqCommandSetRng: std_logic_vector(7 downto 0) := x"00";
	constant tixVVgaacqCommandGetInfo: std_logic_vector(7 downto 0) := x"01";
end Zedb;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Oled128x32_v1_0_lib is
	type bitmap32x128_t is array(0 to 31) of std_logic_vector(0 to 127);
	type char4x20_t is array(0 to 3, 0 to 19) of character;
	type hex4x16_t is array(0 to 3) of std_logic_vector(63 downto 0);
	type bin4x16_t is array(0 to 3) of std_logic_vector(15 downto 0);
end Oled128x32_v1_0_lib;


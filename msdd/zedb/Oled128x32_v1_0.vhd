-- file Oled128x32_v1_0.vhd
-- Oled128x32_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 27 Feb 2017
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;
use work.Oled128x32_v1_0_lib.all;

entity Oled128x32_v1_0 is
	generic (
		fMclk: natural range 1 to 1000000;

		textNotBitmap: std_logic := '0';
		numNotChar: std_logic := '0';
		binNotHex: std_logic := '0';

		Tfrm: natural range 10 to 1000 := 100
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;
		run: in std_logic;

		bitmap: in bitmap32x128_t;
		char: in char4x20_t;
		hex: in hex4x16_t;
		bin: in bin4x16_t;

		vdd: out std_logic;
		vbat: out std_logic;

		nres: out std_logic;
		dNotC: out std_logic;

		sclk: out std_logic;
		mosi: out std_logic
	);
end Oled128x32_v1_0;

architecture Oled128x32_v1_0 of Oled128x32_v1_0 is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Spimaster_v1_0 is
		generic (
			fMclk: natural range 1 to 1000000 := 100000;

			cpol: std_logic := '0';
			cpha: std_logic := '0';

			nssByteNotXfer: std_logic := '0';

			fSclk: natural range 1 to 50000000 := 10000000;
			Nstop: natural range 1 to 8 := 1
		);
		port (
			reset: in std_logic;
			mclk: in std_logic;

			req: in std_logic;
			ack: out std_logic;
			dne: out std_logic;

			len: in std_logic_vector(16 downto 0);

			send: in std_logic_vector(7 downto 0);
			strbSend: out std_logic;

			recv: out std_logic_vector(7 downto 0);
			strbRecv: out std_logic;

			nss: out std_logic;
			sclk: out std_logic;
			mosi: out std_logic;
			miso: in std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpStartA, stateOpStartB, stateOpStartC, stateOpStartD, stateOpStartE,
		stateOpStartF, stateOpStartG, stateOpStartH, stateOpStartI, stateOpStartJ,
		stateOpStartK,
		stateOpRunA, stateOpRunB, stateOpRunC, stateOpRunD,
		stateOpBitmapA, stateOpBitmapB, stateOpBitmapC, stateOpBitmapD,
		stateOpTextA, stateOpTextB, stateOpTextC, stateOpTextD, stateOpTextE,
		stateOpTextF, stateOpTextG,
		stateOpStopA, stateOpStopB, stateOpStopC
	);
	signal stateOp: stateOp_t;

	type dm_t is array(0 to 6) of std_logic_vector(0 to 4);
	signal dm: dm_t;
	
	constant dmA: dm_t := ("00100", "01010", "10001", "10001", "11111", "10001", "10001");
	constant dmB: dm_t := ("11110", "10001", "10001", "11110", "10001", "10001", "11110");
	constant dmC: dm_t := ("01111", "10000", "10000", "10000", "10000", "10000", "01111");
	constant dmD: dm_t := ("11110", "10001", "10001", "10001", "10001", "10001", "11110");
	constant dmE: dm_t := ("11111", "10000", "10000", "11110", "10000", "10000", "11111");
	constant dmF: dm_t := ("11111", "10000", "10000", "11110", "10000", "10000", "10000");
	constant dmG: dm_t := ("01111", "10000", "10000", "10111", "10001", "10001", "01111");
	constant dmH: dm_t := ("10001", "10001", "10001", "11111", "10001", "10001", "10001");
	constant dmI: dm_t := ("00100", "00100", "00100", "00100", "00100", "00100", "00100");
	constant dmJ: dm_t := ("11111", "00001", "00001", "00001", "00001", "10001", "01110");
	constant dmK: dm_t := ("10001", "10010", "10100", "11000", "10100", "10010", "10001");
	constant dmL: dm_t := ("10000", "10000", "10000", "10000", "10000", "10000", "11111");
	constant dmM: dm_t := ("10001", "11011", "10101", "10001", "10001", "10001", "10001");
	constant dmN: dm_t := ("10001", "11001", "10101", "10011", "10001", "10001", "10001");
	constant dmO: dm_t := ("01110", "10001", "10001", "10001", "10001", "10001", "01110");
	constant dmP: dm_t := ("11110", "10001", "10001", "11110", "10000", "10000", "10000");
	constant dmQ: dm_t := ("01110", "10001", "10001", "10001", "10001", "01110", "00001");
	constant dmR: dm_t := ("11110", "10001", "10001", "11110", "10001", "10001", "10001");
	constant dmS: dm_t := ("01111", "10000", "10000", "01110", "00001", "00001", "11110");
	constant dmT: dm_t := ("11111", "00100", "00100", "00100", "00100", "00100", "00100");
	constant dmU: dm_t := ("10001", "10001", "10001", "10001", "10001", "10001", "01110");
	constant dmV: dm_t := ("10001", "10001", "10001", "10001", "10001", "01010", "00100");
	constant dmW: dm_t := ("10001", "10001", "10001", "10001", "10101", "11011", "10001");
	constant dmX: dm_t := ("10001", "10001", "01010", "00100", "01010", "10001", "10001");
	constant dmY: dm_t := ("10001", "10001", "01010", "00100", "00100", "00100", "00100");
	constant dmZ: dm_t := ("11111", "00001", "00010", "00100", "01000", "10000", "11111");
	constant dm0: dm_t := ("01110", "10001", "10011", "10101", "11001", "10001", "01110");
	constant dm1: dm_t := ("00010", "00110", "01010", "00010", "00010", "00010", "00010");
	constant dm2: dm_t := ("01110", "10001", "00010", "00100", "01000", "10000", "11111");
	constant dm3: dm_t := ("01110", "10001", "00001", "01110", "00001", "10001", "01110");
	constant dm4: dm_t := ("00010", "00110", "01010", "10010", "11111", "00010", "00010");
	constant dm5: dm_t := ("11111", "10000", "10000", "11110", "00001", "00001", "11110");
	constant dm6: dm_t := ("01110", "10001", "10000", "11110", "10001", "10001", "01110");
	constant dm7: dm_t := ("11111", "00001", "00010", "11111", "00100", "01000", "10000");
	constant dm8: dm_t := ("01110", "10001", "10001", "01110", "10001", "10001", "01110");
	constant dm9: dm_t := ("01110", "10001", "10001", "01111", "00001", "00001", "11110");
	constant dmDot: dm_t := ("00000", "00000", "00000", "00000", "00000", "01100", "01100");
	constant dmParl: dm_t := ("00010", "00100", "01000", "01000", "01000", "00100", "00010");
	constant dmParr: dm_t := ("01000", "00100", "00010", "00010", "00010", "00100", "01000");
	constant dmBral: dm_t := ("01110", "01000", "01000", "01000", "01000", "01000", "01110");
	constant dmBrar: dm_t := ("01110", "00010", "00010", "00010", "00010", "00010", "01110");
	constant dmLt: dm_t := ("00001", "00010", "00100", "01000", "00100", "00010", "00001");
	constant dmGt: dm_t := ("10000", "01000", "00100", "00010", "00100", "01000", "10000");
	constant dmPlus: dm_t := ("00000", "00100", "00100", "11111", "00100", "00100", "00000");
	constant dmDash: dm_t := ("00000", "00000", "00000", "11111", "00000", "00000", "00000");
	constant dmStar: dm_t := ("00000", "00000", "01010", "00100", "01010", "00000", "00000");
	constant dmSlash: dm_t := ("00000", "00001", "00010", "00100", "01000", "10000", "00000");
	constant dmPercent: dm_t := ("11000", "11001", "00010", "00100", "01000", "10011", "00011");
	constant dmComma: dm_t := ("00000", "00000", "00000", "01100", "01100", "00100", "01000");
	constant dmEqual: dm_t := ("00000", "00000", "11111", "00000", "11111", "00000", "00000");
	constant dmVbar: dm_t := ("00100", "00100", "00100", "00100", "00100", "00100", "00100");
	constant dmHat: dm_t := ("00100", "01010", "10001", "00000", "00000", "00000", "00000");
	constant dmBlank: dm_t := ("00000", "00000", "00000", "00000", "00000", "00000", "00000");

	signal charval: character;
	signal charvalHex: character;
	signal charvalBin: character;

	signal hexval: std_logic_vector(3 downto 0);
	signal binval: std_logic;

	signal Tfrmrun: std_logic;

	signal spilen: std_logic_vector(16 downto 0);

	signal spisend: std_logic_vector(7 downto 0);

	signal dNotC_sig: std_logic;

	---- frame clock (tfrm)
	type stateTfrm_t is (
		stateTfrmIdle,
		stateTfrmRunA, stateTfrmRunB
	);
	signal stateTfrm: stateTfrm_t := stateTfrmIdle;

	signal strbTfrm: std_logic;

	---- mySpi
	signal strbSpisend: std_logic;

	---- handshake
	-- op to mySpi
	signal reqSpi: std_logic;
	signal ackSpi: std_logic;
	signal dneSpi: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '0',
			cpha => '0',

			nssByteNotXfer => '0',

			fSclk => 5000000,
			Nstop => 1
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqSpi,
			ack => ackSpi,
			dne => dneSpi,

			len => spilen,

			send => spisend,
			strbSend => strbSpisend,

			recv => open,
			strbRecv => open,

			nss => open,
			sclk => sclk,
			mosi => mosi,
			miso => '0'
		);

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	dm <= dmA when (charval='A' or charval='a')
		else dmB when (charval='B' or charval='b')
		else dmC when (charval='C' or charval='c')
		else dmD when (charval='D' or charval='d')
		else dmE when (charval='E' or charval='e')
		else dmF when (charval='F' or charval='f')
		else dmG when (charval='G' or charval='g')
		else dmH when (charval='H' or charval='h')
		else dmI when (charval='I' or charval='i')
		else dmJ when (charval='J' or charval='j')
		else dmK when (charval='K' or charval='k')
		else dmL when (charval='L' or charval='l')
		else dmM when (charval='M' or charval='m')
		else dmN when (charval='N' or charval='n')
		else dmO when (charval='O' or charval='o')
		else dmP when (charval='P' or charval='p')
		else dmQ when (charval='Q' or charval='q')
		else dmR when (charval='R' or charval='r')
		else dmS when (charval='S' or charval='s')
		else dmT when (charval='T' or charval='t')
		else dmU when (charval='U' or charval='u')
		else dmV when (charval='V' or charval='v')
		else dmW when (charval='W' or charval='w')
		else dmX when (charval='X' or charval='x')
		else dmY when (charval='Y' or charval='y')
		else dmZ when (charval='Z' or charval='z')
		else dm0 when charval='0'
		else dm1 when charval='1'
		else dm2 when charval='2'
		else dm3 when charval='3'
		else dm4 when charval='4'
		else dm5 when charval='5'
		else dm6 when charval='6'
		else dm7 when charval='7'
		else dm8 when charval='8'
		else dm9 when charval='9'
		else dmDot when charval='.'
		else dmParl when charval='('
		else dmParr when charval=')'
		else dmBral when charval='['
		else dmBrar when charval=']'
		else dmLt when charval='<'
		else dmGt when charval='>'
		else dmPlus when charval='+'
		else dmDash when charval='-'
		else dmStar when charval='*'
		else dmSlash when charval='/'
		else dmPercent when charval='%'
		else dmComma when charval=','
		else dmEqual when charval='='
		else dmVbar when charval='|'
		else dmHat when charval='^'
		else dmBlank;

	charvalHex <= '0' when hexval="0000"
		else '1' when hexval="0001"
		else '2' when hexval="0010"
		else '3' when hexval="0011"
		else '4' when hexval="0100"
		else '5' when hexval="0101"
		else '6' when hexval="0110"
		else '7' when hexval="0111"
		else '8' when hexval="1000"
		else '9' when hexval="1001"
		else 'A' when hexval="1010"
		else 'B' when hexval="1011"
		else 'C' when hexval="1100"
		else 'D' when hexval="1101"
		else 'E' when hexval="1110"
		else 'F' when hexval="1111";

	charvalBin <= '0' when binval='0'
		else '1' when binval='1';

	Tfrmrun <= '1' when (stateOp=stateOpRunA or stateOp=stateOpRunB or stateOp=stateOpRunC or stateOp=stateOpRunD
		or stateOp=stateOpBitmapA or stateOp=stateOpBitmapB or stateOp=stateOpBitmapC or stateOp=stateOpBitmapD
		or stateOp=stateOpTextA or stateOp=stateOpTextB or stateOp=stateOpTextC or stateOp=stateOpTextD or stateOp=stateOpTextE
		or stateOp=stateOpTextF or stateOp=stateOpTextG) else '0';

	vdd <= '1' when (stateOp=stateOpInit or stateOp=stateOpIdle or stateOp=stateOpStartA or stateOp=stateOpStartB) else '0';
	vbat <= '1' when (stateOp=stateOpInit or stateOp=stateOpIdle or stateOp=stateOpStartA or stateOp=stateOpStartB or stateOp=stateOpStartC or stateOp=stateOpStartD or stateOp=stateOpStartE or stateOp=stateOpStartF or stateOp=stateOpStartG or stateOp=stateOpStartF or stateOp=stateOpStartG or stateOp=stateOpStartH or stateOp=stateOpStartI or stateOp=stateOpStopB or stateOp=stateOpStopC) else '0';

	nres <= '0' when stateOp=stateOpStartE else '1';
	dNotC <= dNotC_sig;

	process (reset, mclk)
		constant lenAuxbuf: natural := 12;

		type auxbuf_t is array(0 to lenAuxbuf-1) of std_logic_vector(7 downto 0);
		constant auxbuf: auxbuf_t := (x"8D", x"14", x"D9", x"F1", x"81", x"0F", x"A0", x"C0", x"60", x"DA", x"20", x"AF"); -- 8D14, D9F1, 810F, A0, C0, 60, DA20, AF

		variable bytecnt: natural range 0 to lenAuxbuf;

		variable i: natural range 0 to 4;
		variable j: natural range 0 to 128;
		variable k: natural range 0 to 20;
		variable l: natural range 0 to 6;

		variable m: natural range 0 to 100*10; -- vdd on to reset, vbat on to display on, display on to running / vbat off to vdd off 100ms (use tkclk as source)
		variable n: natural range 0 to ((3*fMclk)/1000); -- reset low for 3us

	begin
		if reset='1' then
			stateOp <= stateOpInit;
			reqSpi <= '0';
			spilen <= std_logic_vector(to_unsigned(0, 17));
			spisend <= x"00";

		elsif rising_edge(mclk) then
			if stateOp=stateOpInit then
				reqSpi <= '0';
				spilen <= std_logic_vector(to_unsigned(0, 17));
				spisend <= x"00";

				stateOp <= stateOpIdle;

			elsif stateOp=stateOpIdle then
				if run='1' then
					m := 0;
					stateOp <= stateOpStartA;
				end if;

			elsif stateOp=stateOpStartA then
				if tkclk='1' then
					if m=100*10 then
						m := 0;
						stateOp <= stateOpStartC;
					else
						stateOp <= stateOpStartB;
					end if;
				end if;

			elsif stateOp=stateOpStartB then
				if tkclk='0' then
					m := m + 1;
					stateOp <= stateOpStartA;
				end if;

			elsif stateOp=stateOpStartC then -- vdd='0' from here
				if tkclk='1' then
					if m=100*10 then
						n := 0;

						stateOp <= stateOpStartE;
					else
						stateOp <= stateOpStartD;
					end if;
				end if;

			elsif stateOp=stateOpStartD then
				if tkclk='0' then
					m := m + 1;
					stateOp <= stateOpStartC;
				end if;

			elsif stateOp=stateOpStartE then -- nres='0' only here
				if n=((3*fMclk)/1000) then
					dNotC_sig <= '0';
					spilen <= std_logic_vector(to_unsigned(lenAuxbuf, 17));

					bytecnt := 0;

					stateOp <= stateOpStartH;
				else
					n := n + 1;
				end if;

			elsif stateOp=stateOpStartF then
				if dneSpi='1' then
					reqSpi <= '0';

					m := 0;

					stateOp <= stateOpStartJ;
				elsif strbSpisend='0' then
					stateOp <= stateOpStartG;
				end if;
			
			elsif stateOp=stateOpStartG then
				bytecnt := bytecnt + 1;
				stateOp <= stateOpStartH;

			elsif stateOp=stateOpStartH then
				reqSpi <= '1';
			
				spisend <= auxbuf(bytecnt);
			
				stateOp <= stateOpStartI;
			
			elsif stateOp=stateOpStartI then
				if strbSpisend='1' then
					stateOp <= stateOpStartF;
				end if;
			
			elsif stateOp=stateOpStartJ then -- vbat='0' from here
				if tkclk='1' then
					if m=100*10 then
						stateOp <= stateOpRunA;
					else
						stateOp <= stateOpStartK;
					end if;
				end if;

			elsif stateOp=stateOpStartK then
				if tkclk='0' then
					m := m + 1;
					stateOp <= stateOpStartJ;
				end if;

			elsif stateOp=stateOpRunA then -- Tfrmrun='1' from here
				if run='0' then
					dNotC_sig <= '0';
					spilen <= std_logic_vector(to_unsigned(1, 17));
					spisend <= x"AE";

					stateOp <= stateOpStopA;
				elsif strbTfrm='1' then
					i := 0;
					stateOp <= stateOpRunB;
				end if;

			elsif stateOp=stateOpRunB then
				if i=4 then
					stateOp <= stateOpRunA;
				else
					dNotC_sig <= '0';

					reqSpi <= '1';
					spilen <= std_logic_vector(to_unsigned(1, 17));
					spisend <= x"B" & std_logic_vector(to_unsigned(i, 4)); -- set page
					
					stateOp <= stateOpRunC;
				end if;

			elsif stateOp=stateOpRunC then
				if dneSpi='1' then
					reqSpi <= '0';

					dNotC_sig <= '1';
					spilen <= std_logic_vector(to_unsigned(128, 17));

					j := 0;
					if textNotBitmap='0' then
						stateOp <= stateOpBitmapC;
					else
						k := 0;
						l := 0;
						stateOp <= stateOpTextC;
					end if;
				end if;

			elsif stateOp=stateOpRunD then
				i := i + 1;
				stateOp <= stateOpRunB;

			elsif stateOp=stateOpBitmapA then
				if dneSpi='1' then
					reqSpi <= '0';
					stateOp <= stateOpRunD;
				elsif strbSpisend='0' then
					stateOp <= stateOpBitmapB;
				end if;

			elsif stateOp=stateOpBitmapB then
				j := j + 1;
				stateOp <= stateOpBitmapC;
			
			elsif stateOp=stateOpBitmapC then
				reqSpi <= '1';
			
				if i=0 then
					spisend <= bitmap(7)(j) & bitmap(6)(j) & bitmap(5)(j) & bitmap(4)(j) & bitmap(3)(j) & bitmap(2)(j) & bitmap(1)(j) & bitmap(0)(j); -- bitmap(7 downto 0)(j);
				elsif i=1 then
					spisend <= bitmap(15)(j) & bitmap(14)(j) & bitmap(13)(j) & bitmap(12)(j) & bitmap(11)(j) & bitmap(10)(j) & bitmap(9)(j) & bitmap(8)(j); -- bitmap(15 downto 8)(j);
				elsif i=2 then
					spisend <= bitmap(23)(j) & bitmap(22)(j) & bitmap(21)(j) & bitmap(20)(j) & bitmap(19)(j) & bitmap(18)(j) & bitmap(17)(j) & bitmap(16)(j); -- bitmap(23 downto 16)(j);
				elsif i=3 then
					spisend <= bitmap(31)(j) & bitmap(30)(j) & bitmap(29)(j) & bitmap(28)(j) & bitmap(27)(j) & bitmap(26)(j) & bitmap(25)(j) & bitmap(24)(j); -- bitmap(31 downto 24)(j);
				end if;

				stateOp <= stateOpBitmapD;
			
			elsif stateOp=stateOpBitmapD then
				if strbSpisend='1' then
					stateOp <= stateOpBitmapA;
				end if;

			elsif stateOp=stateOpTextA then
				if dneSpi='1' then
					reqSpi <= '0';
					stateOp <= stateOpRunD;
				elsif strbSpisend='0' then
					stateOp <= stateOpTextB;
				end if;
			
			elsif stateOp=stateOpTextB then
				j := j + 1;
			
				if k<20 then
					l := l + 1;
					if l=6 then
						l := 0;
			
						k := k + 1;
					end if;
				end if;
			
				stateOp <= stateOpTextC;
			
			elsif stateOp=stateOpTextC then
				if (numNotChar='1' and binNotHex='0' and ((k>=1 and k<=4) or (k>=6 and k<=9) or (k>=11 and k<=14) or (k>=16 and k<=19))) then
					if (k>=1 and k<=4) then
						hexval <= hex(i)(63-(k-1)*4 downto 63-(k-1)*4-3);
					elsif (k>=6 and k<=9) then
						hexval <= hex(i)(63-(k-2)*4 downto 63-(k-2)*4-3);
					elsif (k>=11 and k<=14) then
						hexval <= hex(i)(63-(k-3)*4 downto 63-(k-3)*4-3);
					elsif (k>=16 and k<=19) then
						hexval <= hex(i)(63-(k-4)*4 downto 63-(k-4)*4-3);
					end if;
			
					stateOp <= stateOpTextD;
			
				elsif (numNotChar='1' and binNotHex='1' and ((k>=1 and k<=4) or (k>=6 and k<=9) or (k>=11 and k<=14) or (k>=16 and k<=19))) then
					if (k>=1 and k<=4) then
						binval <= bin(i)(15-(k-1));
					elsif (k>=6 and k<=9) then
						binval <= bin(i)(15-(k-2));
					elsif (k>=11 and k<=14) then
						binval <= bin(i)(15-(k-3));
					elsif (k>=16 and k<=19) then
						binval <= bin(i)(15-(k-4));
					end if;
			
					stateOp <= stateOpTextE;
			
				else
					if numNotChar='0' then
						charval <= char(i,k);
					elsif (numNotChar='1' and binNotHex='0' and k=0) then
						charval <= 'X';
					elsif (numNotChar='1' and binNotHex='1' and k=0) then
						charval <= 'B';
					else
						charval <= ' ';
					end if;
			
					stateOp <= stateOpTextF;
				end if;
				
			elsif stateOp=stateOpTextD then
				charval <= charvalHex;
				stateOp <= stateOpTextF;
			
			elsif stateOp=stateOpTextE then
				charval <= charvalBin;
				stateOp <= stateOpTextF;
			
			elsif stateOp=stateOpTextF then
				reqSpi <= '1';
			
				if k=20 then
					spisend <= x"00";
				else
					if l<5 then
						spisend <= '0' & dm(6)(l) & dm(5)(l) & dm(4)(l) & dm(3)(l) & dm(2)(l) & dm(1)(l) & dm(0)(l); -- '0' & dm(6 downto 0)(l);
					else
						spisend <= x"00";
					end if;
				end if;

				stateOp <= stateOpTextG;
			
			elsif stateOp=stateOpTextG then
				if strbSpisend='1' then
					stateOp <= stateOpTextA;
				end if;

			elsif stateOp=stateOpStopA then
				if dneSpi='1' then
					reqSpi <= '0';

					m := 0;

					stateOp <= stateOpStopB;
				end if;

			elsif stateOp=stateOpStopB then -- vbat='1' from here
				if tkclk='1' then
					if m=100*10 then
						stateOp <= stateOpInit;
					else
						stateOp <= stateOpStopC;
					end if;
				end if;

			elsif stateOp=stateOpStopC then
				if tkclk='0' then
					m := m + 1;
					stateOp <= stateOpStopB;
				end if;
			end if;
		end if;	
	end process;

	------------------------------------------------------------------------
	-- implementation: frame clock
	------------------------------------------------------------------------

	process (reset, mclk, stateTfrm)
		variable i: natural range 0 to Tfrm;

	begin
		if reset='1' then
			stateTfrm <= stateTfrmIdle;
			strbTfrm <= '0';

		elsif rising_edge(mclk) then
			if Tfrmrun='0' then
				stateTfrm <= stateTfrmIdle;
				strbTfrm <= '0';

			elsif stateTfrm=stateTfrmIdle then
				if Tfrmrun='1' then
					i := 0;
					stateTfrm <= stateTfrmRunA;
				end if;

			elsif stateTfrm=stateTfrmRunA then
				if tkclk='1' then
					if i=0 then
						strbTfrm <= '1';
					end if;

					stateTfrm <= stateTfrmRunB;
				end if;

			elsif stateTfrm=stateTfrmRunB then
				strbTfrm <= '0';
				
				if tkclk='0' then
					i := i + 1;
					if i=Tfrm then
						i := 0;
					end if;

					stateTfrm <= stateTfrmRunA;
				end if;
			end if;
		end if;
	end process;

end Oled128x32_v1_0;

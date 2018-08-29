-- file Adxl.vhd
-- Adxl easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 26 Aug 2018
-- date modified: 26 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Bss3.all;

entity Adxl is
	generic (
		res: std_logic_vector(1 downto 0) := "01";
		rate: std_logic_vector(3 downto 0) := "1010";

		Tsmp: natural range 10 to 10000 := 100; -- in tkclk periods
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		getAxAx: out std_logic_vector(15 downto 0);

		getAyAy: out std_logic_vector(15 downto 0);

		getAzAz: out std_logic_vector(15 downto 0);

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic;
		miso: in std_logic
	);
end Adxl;

architecture Adxl of Adxl is

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
		stateOpSetRes,
		stateOpSetRate,
		stateOpSetPwr,
		stateOpSetA, stateOpSetB, stateOpSetC, stateOpSetD,
		stateOpReady,
		stateOpGetA, stateOpGetB, stateOpGetC
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpSetRes;

	signal Tsmprun: std_logic;

	signal ax, ax_next: std_logic_vector(15 downto 0);
	signal ay, ay_next: std_logic_vector(15 downto 0);
	signal az, az_next: std_logic_vector(15 downto 0);

	signal spilen: std_logic_vector(16 downto 0);
	signal spisend, spisend_next: std_logic_vector(7 downto 0);

	-- IP sigs.op.cust --- INSERT

	---- sample clock (tsmp)
	type stateTsmp_t is (
		stateTsmpInit,
		stateTsmpReady,
		stateTsmpRunA, stateTsmpRunB, stateTsmpRunC
	);
	signal stateTsmp, stateTsmp_next: stateTsmp_t := stateTsmpInit;

	signal strbTsmp: std_logic;

	-- IP sigs.tsmp.cust --- INSERT

	---- mySpi
	signal strbSpisend: std_logic;

	signal spirecv: std_logic_vector(7 downto 0);
	signal strbSpirecv: std_logic;

	---- handshake
	-- op to mySpi
	signal reqSpi, reqSpi_next: std_logic;
	signal dneSpi: std_logic;

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	mySpi : Spimaster_v1_0
		generic map (
			fMclk => fMclk,

			cpol => '1',
			cpha => '1',

			nssByteNotXfer => '0',

			fSclk => 5000000,
			Nstop => 1
		)
		port map (
			reset => reset,
			mclk => mclk,

			req => reqSpi,
			ack => open,
			dne => dneSpi,

			len => spilen,

			send => spisend,
			strbSend => strbSpisend,

			recv => spirecv,
			strbRecv => strbSpirecv,

			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => miso
		);

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	Tsmprun <= '1' when (stateOp=stateOpReady or stateOp=stateOpGetA or stateOp=stateOpGetB or stateOp=stateOpGetC) else '0';

	getAxAx <= ax;
	getAyAy <= ay;
	getAzAz <= az;
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
	constant lenRxbuf: natural := 7;
	type rxbuf_t is array(0 to lenRxbuf-1) of std_logic_vector(7 downto 0);
	variable rxbuf: rxbuf_t;

	constant lenTxbuf: natural := 2;
	type txbuf_t is array(0 to lenTxbuf-1) of std_logic_vector(7 downto 0);
	variable txbuf: txbuf_t;

	constant ixTxbufCmd: natural := 0;

	constant cmdSetRes: std_logic_vector(7 downto 0) := x"31";
	constant ixTxbufSetResRes: natural := 1;

	constant cmdSetRate: std_logic_vector(7 downto 0) := x"2C";
	constant ixTxbufSetRateRate: natural := 1;

	constant cmdSetPwr: std_logic_vector(7 downto 0) := x"2D";
	constant ixTxbufSetPwrPwr: natural := 1;

	constant cmdGetData: std_logic_vector(7 downto 0) := x"F2";
	constant ixRxbufGetDataAx: natural := 1;
	constant ixRxbufGetDataAy: natural := 3;
	constant ixRxbufGetDataAz: natural := 5;
	
	-- settings (write): DATA_FORMAT/RANGE 0x31 and BW_RATE 0x2C (2 bytes)
	-- 00-110001 RRRRRRRR and 00-101100 BBBBBBBB

	-- RRRRRRRR e.g. 0000 0 0 RR (01 for 4g)
	-- BBBBBBBB e.g. 000 0 BBBB (400Hz/1100 for 100Hz fsmp)

	-- then POWER_CTL 0x2D (2 bytes)
	
	-- data: burst read 0x32 (7 bytes)
	-- 11-110010 6xDDDDDDDD

	variable bytecnt: natural range 0 to lenRxbuf;

	variable x: std_logic_vector(15 downto 0);
	variable y: std_logic_vector(15 downto 0);
	variable z: std_logic_vector(15 downto 0);
	-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- BEGIN
			stateOp_next <= stateOpSetRes;
			ax_next <= x"0000";
			ay_next <= x"0000";
			az_next <= x"0000";
			reqSpi_next <= '0';
			spisend_next <= x"00";
			-- IP impl.op.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateOp=stateOpSetRes then
				-- IP impl.op.rising.setRes --- IBEGIN
				txbuf(ixTxbufCmd) := cmdSetRes;
				txbuf(ixTxbufSetResRes) := "000000" & res;
	
				spilen <= std_logic_vector(to_unsigned(lenTxbuf, 17));
	
				bytecnt := 0;
				-- IP impl.op.rising.setRes --- IEND

				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetRate then
				-- IP impl.op.rising.setRate --- IBEGIN
				txbuf(ixTxbufCmd) := cmdSetRate;
				txbuf(ixTxbufSetRateRate) := "0000" & rate;
	
				spilen <= std_logic_vector(to_unsigned(lenTxbuf, 17));
	
				bytecnt := 0;
				-- IP impl.op.rising.setRate --- IEND

				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetPwr then
				-- IP impl.op.rising.setPwr --- IBEGIN
				txbuf(ixTxbufCmd) := cmdSetPwr;
				txbuf(ixTxbufSetPwrPwr) := x"08";
	
				spilen <= std_logic_vector(to_unsigned(lenTxbuf, 17));
	
				bytecnt := 0;
				-- IP impl.op.rising.setPwr --- IEND

				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetA then
				if dneSpi='1' then
					reqSpi_next <= '0'; -- IP impl.op.rising.setA --- ILINE

					if txbuf(ixTxbufCmd)=cmdSetRes then
						stateOp_next <= stateOpSetRate;

					elsif txbuf(ixTxbufCmd)=cmdSetRate then
						stateOp_next <= stateOpSetPwr;

					else
						stateOp_next <= stateOpReady;
					end if;

				else
					stateOp_next <= stateOpSetB;
				end if;

			elsif stateOp=stateOpSetB then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.setB --- ILINE

				stateOp_next <= stateOpSetC;

			elsif stateOp=stateOpSetC then
				-- IP impl.op.rising.setC --- IBEGIN
				reqSpi_next <= '1';
	
				spisend_next <= txbuf(bytecnt); -- reason for reqSpi_next
				-- IP impl.op.rising.setC --- IEND

				stateOp_next <= stateOpSetD;

			elsif stateOp=stateOpSetD then
				if strbSpisend='1' then
					stateOp_next <= stateOpSetA;
				end if;

			elsif stateOp=stateOpReady then
				if strbTsmp='1' then
					-- IP impl.op.rising.ready --- IBEGIN
					reqSpi_next <= '1';
	
					spilen <= std_logic_vector(to_unsigned(lenRxbuf, 17));
	
					spisend_next <= cmdGetData;
	
					bytecnt := 0;
					-- IP impl.op.rising.ready --- IEND

					stateOp_next <= stateOpGetA;
				end if;

			elsif stateOp=stateOpGetA then
				if dneSpi='1' then
					-- IP impl.op.rising.getA.done --- IBEGIN
					reqSpi_next <= '0';
	
					x := rxbuf(ixRxbufGetDataAx) & rxbuf(ixRxbufGetDataAx+1);
					ax_next <= x;
					
					y := rxbuf(ixRxbufGetDataAy) & rxbuf(ixRxbufGetDataAy+1);
					ay_next <= y;
					
					z := rxbuf(ixRxbufGetDataAz) & rxbuf(ixRxbufGetDataAz+1);
					az_next <= z;
					-- IP impl.op.rising.getA.done --- IEND

					stateOp_next <= stateOpReady;

				elsif strbSpirecv='0' then
					stateOp_next <= stateOpGetB;
				end if;

			elsif stateOp=stateOpGetB then
				if strbSpirecv='1' then
					rxbuf(bytecnt) := spirecv; -- IP impl.op.rising.getB.copy --- ILINE

					stateOp_next <= stateOpGetC;
				end if;

			elsif stateOp=stateOpGetC then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.getC --- ILINE

				stateOp_next <= stateOpGetA;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	-- IP impl.op.falling --- BEGIN
	process (mclk)
		-- IP impl.op.falling.vars --- BEGIN
		-- IP impl.op.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			ax <= ax_next;
			ay <= ay_next;
			az <= az_next;
			reqSpi <= reqSpi_next;
			spisend <= spisend_next;
		end if;
	end process;
	-- IP impl.op.falling --- END

	------------------------------------------------------------------------
	-- implementation: sample clock (tsmp)
	------------------------------------------------------------------------

	-- IP impl.tsmp.wiring --- BEGIN
	strbTsmp <= '1' when (stateTsmp=stateTsmpRunA and tkclk='1') else '0';
	-- IP impl.tsmp.wiring --- END

	-- IP impl.tsmp.rising --- BEGIN
	process (reset, mclk, stateTsmp)
		-- IP impl.tsmp.rising.vars --- RBEGIN
		variable i: natural range 0 to Tsmp;
		-- IP impl.tsmp.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tsmp.rising.asyncrst --- BEGIN
			stateTsmp_next <= stateTsmpInit;
			-- IP impl.tsmp.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTsmp=stateTsmpInit or Tsmprun='0') then
				if Tsmprun='0' then
					stateTsmp_next <= stateTsmpInit;

				else
					stateTsmp_next <= stateTsmpReady;
				end if;

			elsif stateTsmp=stateTsmpReady then
				if tkclk='0' then
					i := 0; -- IP impl.tsmp.rising.ready.prepRun --- ILINE

					stateTsmp_next <= stateTsmpRunA;
				end if;

			elsif stateTsmp=stateTsmpRunA then
				if tkclk='1' then
					stateTsmp_next <= stateTsmpRunC;
				end if;

			elsif stateTsmp=stateTsmpRunB then
				if tkclk='1' then
					stateTsmp_next <= stateTsmpRunC;
				end if;

			elsif stateTsmp=stateTsmpRunC then
				if tkclk='0' then
					i := i + 1; -- IP impl.tsmp.rising.runC.inc --- ILINE

					if i=Tsmp then
						i := 0; -- IP impl.tsmp.rising.runC.prepRun --- ILINE

						stateTsmp_next <= stateTsmpRunA;

					else
						stateTsmp_next <= stateTsmpRunB;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.tsmp.rising --- END

	-- IP impl.tsmp.falling --- BEGIN
	process (mclk)
		-- IP impl.tsmp.falling.vars --- BEGIN
		-- IP impl.tsmp.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateTsmp <= stateTsmp_next;
		end if;
	end process;
	-- IP impl.tsmp.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Adxl;



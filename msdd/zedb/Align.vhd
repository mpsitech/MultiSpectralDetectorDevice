-- file Align.vhd
-- Align easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 9 Aug 2018
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Align is
	generic (
		fMclk: natural range 1 to 1000000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;

		reqInvSetSeq: in std_logic;
		ackInvSetSeq: out std_logic;

		setSeqLenSeq: in std_logic_vector(7 downto 0);
		setSeqSeq: in std_logic_vector(255 downto 0);

		trigrng: in std_logic;
		strbVisl: in std_logic;

		nss: out std_logic;
		sclk: out std_logic;
		mosi: out std_logic
	);
end Align;

architecture Align of Align is

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
		stateOpInv,
		stateOpReady,
		stateOpSetA, stateOpSetB, stateOpSetC, stateOpSetD
	);
	signal stateOp: stateOp_t := stateOpInit;

	signal spilen: std_logic_vector(16 downto 0);
	signal spisend: std_logic_vector(7 downto 0);
	signal ackInvSetSeq_sig: std_logic;

	-- IP sigs.op.cust --- INSERT

	---- mySpi
	signal strbSpisend: std_logic;

	---- handshake
	-- op to mySpi
	signal reqSpi: std_logic;
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

			cpol => '0',
			cpha => '0',

			nssByteNotXfer => '0',

			fSclk => 8333333,
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

			recv => open,
			strbRecv => open,

			nss => nss,
			sclk => sclk,
			mosi => mosi,
			miso => '0'
		);

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	-- IP impl.op.wiring --- BEGIN
	ackInvSetSeq_sig <= '1' when stateOp=stateOpInv else '0';
	ackInvSetSeq <= ackInvSetSeq_sig;
	-- IP impl.op.wiring --- END

	-- IP impl.op.rising --- BEGIN
	process (reset, mclk, stateOp)
		-- IP impl.op.rising.vars --- RBEGIN
		constant sizeTxbuf: natural := 2;
		type txbuf_t is array(0 to sizeTxbuf-1) of std_logic_vector(7 downto 0);
		variable txbuf: txbuf_t := (x"00", x"00");

		variable bytecnt: natural range 0 to sizeTxbuf;

		variable i: natural range 0 to 31;

		variable x: std_logic_vector(7 downto 0);

		variable zero: std_logic;
		-- IP impl.op.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.op.rising.asyncrst --- RBEGIN
			stateOp <= stateOpInit;
			spisend <= x"00";
			reqSpi <= '0';

			zero := '1';
			-- IP impl.op.rising.asyncrst --- REND

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and reqInvSetSeq='1')) then
				-- IP impl.op.rising.syncrst --- RBEGIN
				spisend <= x"00";
				reqSpi <= '0';
				
				i := 0;
				-- IP impl.op.rising.syncrst --- REND

				if reqInvSetSeq='1' then
					stateOp <= stateOpInv;

				else
					stateOp <= stateOpReady;
				end if;

			elsif stateOp=stateOpInv then
				if reqInvSetSeq='0' then
					stateOp <= stateOpInit;
				end if;

			elsif stateOp=stateOpReady then
				-- IP impl.op.rising.ready.ext --- IBEGIN
				if trigrng='0' then
					i := 0;
				end if;
				-- IP impl.op.rising.ready.ext --- IEND

				if (strbVisl='1' or zero='1') then
					-- IP impl.op.rising.ready --- IBEGIN
					if zero='1' then
						x := x"00";
					else
						x := setSeqSeq(8*(32-i)-1 downto 8*(32-i-1));
					end if;
	
					txbuf(0)(3 downto 0) := x(7 downto 4);
					txbuf(1)(7 downto 4) := x(3 downto 0);
	
					spilen <= std_logic_vector(to_unsigned(sizeTxbuf, 17));
	
					bytecnt := 0;
	
					zero := '0';
					-- IP impl.op.rising.ready --- IEND

					stateOp <= stateOpSetC;
				end if;

			elsif stateOp=stateOpSetA then
				if dneSpi='1' then
					-- IP impl.op.rising.setA.done --- IBEGIN
					reqSpi <= '0';

					i := i + 1;
					if i=to_integer(unsigned(setSeqLenSeq)) then
						i := 0;
					end if;
					-- IP impl.op.rising.setA.done --- IEND

					stateOp <= stateOpReady;

				else
					stateOp <= stateOpSetB;
				end if;

			elsif stateOp=stateOpSetB then
				bytecnt := bytecnt + 1; -- IP impl.op.rising.setB --- ILINE

				stateOp <= stateOpSetC;

			elsif stateOp=stateOpSetC then
				-- IP impl.op.rising.setC --- IBEGIN
				reqSpi <= '1';

				spisend <= txbuf(bytecnt); -- reason for reqSpi not simple logic
				-- IP impl.op.rising.setC --- IEND

				stateOp <= stateOpSetD;

			elsif stateOp=stateOpSetD then
				if strbSpisend='1' then
					stateOp <= stateOpSetA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.op.rising --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Align;



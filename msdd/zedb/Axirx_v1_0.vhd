-- file Axirx_v1_0.vhd
-- Axirx_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 6 Mar 2017
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Axirx_v1_0 is
	port(
		reset: in std_logic;

		mclk: in std_logic;

		req: in std_logic;
		ack: out std_logic;
		dne: out std_logic;

		len: in std_logic_vector(16 downto 0);

		d: out std_logic_vector(7 downto 0);
		strbD: out std_logic;

		enRx: in std_logic;
		rx: in std_logic_vector(31 downto 0);
		strbRx: in std_logic
	);
end Axirx_v1_0;

architecture Axirx_v1_0 of Axirx_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- receive operation
	type stateRecv_t is (
		stateRecvInit,
		stateRecvWaitStartA, stateRecvWaitStartB,
		stateRecvDataA, stateRecvDataB,
		stateRecvDoneA, stateRecvDoneB,
		stateRecvErr
	);
	signal stateRecv: stateRecv_t := stateRecvInit;

	signal d_sig: std_logic_vector(7 downto 0);

begin

	------------------------------------------------------------------------
	-- implementation: receive operation (recv)
	------------------------------------------------------------------------

	dne <= '1' when stateRecv=stateRecvDoneB else '0';

	strbD <= '0' when stateRecv=stateRecvDataA else '1';

	ack <= '1' when (stateRecv=stateRecvDataA or stateRecv=stateRecvDataB or stateRecv=stateRecvDoneA or stateRecv=stateRecvDoneB) else '0';

	d <= d_sig;

	process (reset, mclk)
		variable bytecnt: natural range 0 to 65536;

		constant tstrbhigh: natural := 2;
		variable i: natural range 0 to tstrbhigh;

	begin
		if reset='1' then
			stateRecv <= stateRecvInit;
			d_sig <= x"00";

		elsif rising_edge(mclk) then
			if (stateRecv=stateRecvInit or req='0') then
				d_sig <= x"00";

				bytecnt := 0;

				if req='0' then
					stateRecv <= stateRecvInit;
				else
					stateRecv <= stateRecvWaitStartA;
				end if;

			elsif stateRecv=stateRecvWaitStartA then
				if to_integer(unsigned(len))=0 then
					stateRecv <= stateRecvDoneB;
				elsif enRx='0' then
					stateRecv <= stateRecvWaitStartB;
				end if;

			elsif stateRecv=stateRecvWaitStartB then
				if enRx='1' then
					stateRecv <= stateRecvDataA;
				end if;

			elsif stateRecv=stateRecvDataA then
				if enRx='0' then
					stateRecv <= stateRecvErr;

				elsif strbRx='1' then
					d_sig <= rx(7 downto 0);

					bytecnt := bytecnt + 1; -- byte count received

					if bytecnt=to_integer(unsigned(len)) then
						stateRecv <= stateRecvDoneA;
					else
						i := 0;
						stateRecv <= stateRecvDataB;
					end if;
				end if;

			elsif stateRecv=stateRecvDataB then
				if i<tstrbhigh then
					i := i + 1;
				end if;

				if i=tstrbhigh then
					if strbRx='0' then
						stateRecv <= stateRecvDataA;
					end if;
				end if;

			elsif stateRecv=stateRecvDoneA then
				if enRx='0' then
					stateRecv <= stateRecvDoneB;
				end if;

			elsif stateRecv=stateRecvDoneB then
				-- if req='0' then
				-- 	stateRecv <= stateRecvInit;
				-- end if;

			elsif stateRecv=stateRecvErr then
				-- if req='0' then
				-- 	stateRecv <= stateRecvInit;
				-- end if;
			end if;
		end if;
	end process;

end Axirx_v1_0;


-- file Axitx_v1_0.vhd
-- Axitx_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 6 Mar 2017
-- date modified: 19 Jun 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Axitx_v1_0 is
	port(
		reset: in std_logic;

		mclk: in std_logic;

		req: in std_logic;
		ack: out std_logic;
		dne: out std_logic;

		len: in std_logic_vector(16 downto 0);

		d: in std_logic_vector(7 downto 0);
		strbD: out std_logic;

		enTx: in std_logic;
		tx: out std_logic_vector(31 downto 0);
		strbTx: in std_logic;

		stateSend_dbg: out std_logic_vector(7 downto 0)
	);
end Axitx_v1_0;

architecture Axitx_v1_0 of Axitx_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- send operation (send)
	type stateSend_t is (
		stateSendInit,
		stateSendWaitStartA, stateSendWaitStartB,
		stateSendLoad,
		stateSendDataA, stateSendDataB,
		stateSendDoneA, stateSendDoneB,
		stateSendErr
	);
	signal stateSend, stateSend_next: stateSend_t := stateSendInit;

	signal tx_sig: std_logic_vector(7 downto 0);

begin

	------------------------------------------------------------------------
	-- implementation: send operation (send)
	------------------------------------------------------------------------

	tx <= x"000000" & tx_sig;

	ack <= '1' when (stateSend=stateSendLoad or stateSend=stateSendDataA or stateSend=stateSendDataB or stateSend=stateSendDoneA or stateSend=stateSendDoneB) else '0';

	dne <= '1' when stateSend=stateSendDoneB else '0';

	strbD <= '0' when stateSend=stateSendDataB else '1';

	stateSend_dbg <= x"00" when stateSend=stateSendInit
				else x"10" when stateSend=stateSendWaitStartA
				else x"11" when stateSend=stateSendWaitStartB
				else x"20" when stateSend=stateSendLoad
				else x"30" when stateSend=stateSendDataA
				else x"31" when stateSend=stateSendDataB
				else x"40" when stateSend=stateSendDoneA
				else x"41" when stateSend=stateSendDoneB
				else x"50" when stateSend=stateSendErr
				else x"FF";

	process (reset, mclk)
		variable bytecnt: natural range 0 to 65536;

		constant tstrblow: natural := 4;
		variable i: natural range 0 to tstrblow;

	begin
		if reset='1' then
			stateSend_next <= stateSendInit;
			tx_sig <= x"FF";

		elsif rising_edge(mclk) then
			if (stateSend=stateSendInit or req='0') then
				tx_sig <= x"FF";

				bytecnt := 0;

				if req='0' then
					stateSend_next <= stateSendInit;
				else
					stateSend_next <= stateSendWaitStartA;
				end if;

			elsif stateSend=stateSendWaitStartA then
				if to_integer(unsigned(len))=0 then
					stateSend_next <= stateSendDoneB;
				elsif enTx='0' then
					stateSend_next <= stateSendWaitStartB;
				end if;

			elsif stateSend=stateSendWaitStartB then
				if enTx='1' then
					stateSend_next <= stateSendLoad;
				end if;

			elsif stateSend=stateSendLoad then
				tx_sig <= d;

				bytecnt := bytecnt + 1; -- byte count put out for send

				stateSend_next <= stateSendDataA;

			elsif stateSend=stateSendDataA then
				if bytecnt=to_integer(unsigned(len)) then
					stateSend_next <= stateSendDoneA;
				elsif strbTx='1' then
					i := 0;
					stateSend_next <= stateSendDataB;
				end if;

			elsif stateSend=stateSendDataB then
				if i<tstrblow then
					i := i + 1;
				end if;

				if i=tstrblow then
					if enTx='0' then
						stateSend_next <= stateSendErr;
					elsif strbTx='0' then
						stateSend_next <= stateSendLoad;
					end if;
				end if;

			elsif stateSend=stateSendDoneA then
				if enTx='0' then
					stateSend_next <= stateSendDoneB;
				end if;

			elsif stateSend=stateSendDoneB then
				-- if req='0' then
				-- 	stateSend_next <= stateSendInit;
				-- end if;

			elsif stateSend=stateSendErr then
				-- if req='0' then
				-- 	stateSend_next <= stateSendInit;
				-- end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateSend <= stateSend_next;
		end if;
	end process;

end Axitx_v1_0;


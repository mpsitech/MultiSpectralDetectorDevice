-- file Tkclksrc_Easy_v1_0.vhd
-- Tkclksrc_Easy_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 15 Dec 2017
-- date modified: 11 Apr 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Tkclksrc is
	generic (
		fMclk: natural range 1 to 1000000 := 50000
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: out std_logic;

		getTkstTkst: out std_logic_vector(31 downto 0);

		reqInvSetTkst: in std_logic;
		ackInvSetTkst: out std_logic;

		setTkstTkst: in std_logic_vector(31 downto 0)
	);
end Tkclksrc;

architecture Tkclksrc of Tkclksrc is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpInv,
		stateOpRun
	);
	signal stateOp, stateOp_next: stateOp_t := stateOpInit;

	signal tkclk_sig, tkclk_sig_next: std_logic;
	signal tkst, tkst_next: std_logic_vector(31 downto 0);

begin

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	tkclk <= tkclk_sig;

	getTkstTkst <= tkst;

	ackInvSetTkst <= '1' when stateOp=stateOpInv else '0';

	process (reset, mclk)
		variable i: natural range 0 to (fMclk/10)/2;

	begin
		if reset='1' then
			stateOp_next <= stateOpInit;
			tkclk_sig_next <= '0';
			tkst_next <= (others => '0');

			i := 0;

		elsif rising_edge(mclk) then
			if (stateOp=stateOpInit or (stateOp/=stateOpInv and reqInvSetTkst='1')) then
				tkclk_sig_next <= '0';

				i := 0;

				if reqInvSetTkst='1' then
					tkst_next <= setTkstTkst;
					stateOp_next <= stateOpInv;
				else
					stateOp_next <= stateOpRun;
				end if;

			elsif stateOp=stateOpInv then
				if reqInvSetTkst='0' then
					stateOp_next <= stateOpRun;
				end if;

			elsif stateOp=stateOpRun then
				i := i + 1;
				if i=(fMclk/10)/2 then
					i := 0;
					if tkclk_sig='1' then
						tkst_next <= std_logic_vector(unsigned(tkst) + 1);
					end if;
					tkclk_sig_next <= not tkclk_sig;
				end if;
			end if;
		end if;
	end process;

	process (mclk)
	begin
		if falling_edge(mclk) then
			stateOp <= stateOp_next;
			tkclk_sig <= tkclk_sig_next;
			tkst <= tkst_next;
		end if;
	end process;

end Tkclksrc;


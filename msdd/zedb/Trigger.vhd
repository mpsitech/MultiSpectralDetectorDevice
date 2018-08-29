-- file Trigger.vhd
-- Trigger easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 26 Aug 2018
-- date modified: 26 Aug 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Trigger is
	generic (
		fMclk: natural range 1 to 1000000 := 50000 -- in kHz
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		reqInvSetRng: in std_logic;
		ackInvSetRng: out std_logic;

		setRngRng: in std_logic_vector(7 downto 0);
		setRngBtnNotTfrm: in std_logic_vector(7 downto 0);

		reqInvSetTdlyLwir: in std_logic;
		ackInvSetTdlyLwir: out std_logic;

		setTdlyLwirTdlyLwir: in std_logic_vector(15 downto 0);

		reqInvSetTdlyVisr: in std_logic;
		ackInvSetTdlyVisr: out std_logic;

		setTdlyVisrTdlyVisr: in std_logic_vector(15 downto 0);

		reqInvSetTfrm: in std_logic;
		ackInvSetTfrm: out std_logic;

		setTfrmTfrm: in std_logic_vector(15 downto 0);

		rng: out std_logic;
		strbLwir: out std_logic;
		strbVisl: out std_logic;
		btn: in std_logic;
		trigVisl: out std_logic;
		trigVisr: out std_logic
	);
end Trigger;

architecture Trigger of Trigger is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- LWIR strobe (lwir)
	type stateLwir_t is (
		stateLwirInit,
		stateLwirInv,
		stateLwirReadyA, stateLwirReadyB,
		stateLwirDelayA, stateLwirDelayB,
		stateLwirOn
	);
	signal stateLwir, stateLwir_next: stateLwir_t := stateLwirInit;

	signal ackInvSetTdlyLwir_sig: std_logic;
	signal strbLwir_sig: std_logic;

	-- IP sigs.lwir.cust --- INSERT

	---- frame clock (tfrm)
	type stateTfrm_t is (
		stateTfrmInit,
		stateTfrmInv,
		stateTfrmReady,
		stateTfrmRunA, stateTfrmRunB, stateTfrmRunC,
		stateTfrmBtnA, stateTfrmBtnB, stateTfrmBtnC
	);
	signal stateTfrm, stateTfrm_next: stateTfrm_t := stateTfrmInit;

	signal ackInvSetRng_sig, ackInvSetRng_sig_next: std_logic;
	signal ackInvSetTfrm_sig, ackInvSetTfrm_sig_next: std_logic;
	signal rng_sig: std_logic;
	signal strbTfrm: std_logic;

	-- IP sigs.tfrm.cust --- INSERT

	---- VIS-L trigger (visl)
	type stateVisl_t is (
		stateVislInit,
		stateVislReady,
		stateVislOn
	);
	signal stateVisl, stateVisl_next: stateVisl_t := stateVislInit;

	signal trigVisl_sig: std_logic;

	-- IP sigs.visl.cust --- INSERT

	---- VIS-R trigger (visr)
	type stateVisr_t is (
		stateVisrInit,
		stateVisrInv,
		stateVisrReadyA, stateVisrReadyB,
		stateVisrDelayA, stateVisrDelayB,
		stateVisrOn
	);
	signal stateVisr, stateVisr_next: stateVisr_t := stateVisrInit;

	signal ackInvSetTdlyVisr_sig: std_logic;
	signal trigVisr_sig: std_logic;

	-- IP sigs.visr.cust --- INSERT

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: LWIR strobe (lwir)
	------------------------------------------------------------------------

	-- IP impl.lwir.wiring --- BEGIN
	ackInvSetTdlyLwir_sig <= '1' when stateLwir=stateLwirInv else '0';
	ackInvSetTdlyLwir <= ackInvSetTdlyLwir_sig;
	strbLwir_sig <= '1' when ((stateLwir=stateLwirReadyA and strbTfrm='1') or stateLwir=stateLwirOn) else '0';
	strbLwir <= strbLwir_sig;
	-- IP impl.lwir.wiring --- END

	-- IP impl.lwir.rising --- BEGIN
	process (reset, mclk, stateLwir)
		-- IP impl.lwir.rising.vars --- RBEGIN
		variable i: natural range 0 to 65535; -- delay counter
		-- IP impl.lwir.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.lwir.rising.asyncrst --- BEGIN
			stateLwir_next <= stateLwirInit;
			-- IP impl.lwir.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateLwir=stateLwirInit or (stateLwir/=stateLwirInv and (reqInvSetTdlyLwir='1' or setRngRng=fls8))) then
				if reqInvSetTdlyLwir='1' then
					stateLwir_next <= stateLwirInv;

				else
					-- IP impl.lwir.rising.syncrst --- BEGIN
					-- IP impl.lwir.rising.syncrst --- END

					if setRngRng=fls8 then
						stateLwir_next <= stateLwirInit;

					elsif to_integer(unsigned(setTdlyLwirTdlyLwir))=0 then
						stateLwir_next <= stateLwirReadyA;

					else
						stateLwir_next <= stateLwirReadyB;
					end if;
				end if;

			elsif stateLwir=stateLwirInv then
				if reqInvSetTdlyLwir='0' then
					stateLwir_next <= stateLwirInit;
				end if;

			elsif stateLwir=stateLwirReadyA then
				-- IP impl.lwir.rising.readyA --- INSERT

			elsif stateLwir=stateLwirReadyB then
				if strbTfrm='1' then
					i := 0; -- IP impl.lwir.rising.readyB.prepDelay --- ILINE

					stateLwir_next <= stateLwirDelayA;
				end if;

			elsif stateLwir=stateLwirDelayA then
				if tkclk='0' then
					i := i + 1; -- IP impl.lwir.rising.delayA.inc --- ILINE

					stateLwir_next <= stateLwirDelayB;
				end if;

			elsif stateLwir=stateLwirDelayB then
				if tkclk='1' then
					if i=to_integer(unsigned(setTdlyLwirTdlyLwir)) then
						stateLwir_next <= stateLwirOn;

					else
						stateLwir_next <= stateLwirDelayA;
					end if;
				end if;

			elsif stateLwir=stateLwirOn then
				stateLwir_next <= stateLwirReadyB;
			end if;
		end if;
	end process;
	-- IP impl.lwir.rising --- END

	-- IP impl.lwir.falling --- BEGIN
	process (mclk)
		-- IP impl.lwir.falling.vars --- BEGIN
		-- IP impl.lwir.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateLwir <= stateLwir_next;
		end if;
	end process;
	-- IP impl.lwir.falling --- END

	------------------------------------------------------------------------
	-- implementation: frame clock (tfrm)
	------------------------------------------------------------------------

	-- IP impl.tfrm.wiring --- BEGIN
	ackInvSetRng <= ackInvSetRng_sig;
	ackInvSetTfrm <= ackInvSetTfrm_sig;
	rng_sig <= '1' when setRngRng=tru8 else '0';
	rng <= rng_sig;
	strbTfrm <= '1' when ((stateTfrm=stateTfrmRunA or stateTfrm=stateTfrmBtnB) and tkclk='1') else '0';
	strbVisl <= strbTfrm;
	-- IP impl.tfrm.wiring --- END

	-- IP impl.tfrm.rising --- BEGIN
	process (reset, mclk, stateTfrm)
		-- IP impl.tfrm.rising.vars --- RBEGIN
		variable i: natural range 0 to 65535; -- frame rate counter
		-- IP impl.tfrm.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tfrm.rising.asyncrst --- BEGIN
			stateTfrm_next <= stateTfrmInit;
			ackInvSetRng_sig_next <= '0';
			ackInvSetTfrm_sig_next <= '0';
			-- IP impl.tfrm.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTfrm=stateTfrmInit or (stateTfrm/=stateTfrmInv and (reqInvSetRng='1' or reqInvSetTfrm='1' or setRngRng=fls8))) then
				if reqInvSetRng='1' then
					-- IP impl.tfrm.rising.init.invSetRng --- IBEGIN
					ackInvSetRng_sig_next <= '1';
					ackInvSetTfrm_sig_next <= '0';
					-- IP impl.tfrm.rising.init.invSetRng --- IEND

					stateTfrm_next <= stateTfrmInv;

				elsif reqInvSetTfrm='1' then
					-- IP impl.tfrm.rising.init.invSetTfrm --- IBEGIN
					ackInvSetRng_sig_next <= '0';
					ackInvSetTfrm_sig_next <= '1';
					-- IP impl.tfrm.rising.init.invSetTfrm --- IEND

					stateTfrm_next <= stateTfrmInv;

				else
					-- IP impl.tfrm.rising.syncrst --- BEGIN
					ackInvSetRng_sig_next <= '0';
					ackInvSetTfrm_sig_next <= '0';

					-- IP impl.tfrm.rising.syncrst --- END

					if setRngRng=fls8 then
						stateTfrm_next <= stateTfrmInit;

					else
						stateTfrm_next <= stateTfrmReady;
					end if;
				end if;

			elsif stateTfrm=stateTfrmInv then
				if ((reqInvSetRng='0' and ackInvSetRng_sig='1') or (reqInvSetTfrm='0' and ackInvSetTfrm_sig='1')) then
					stateTfrm_next <= stateTfrmInit;
				end if;

			elsif stateTfrm=stateTfrmReady then
				if setRngBtnNotTfrm=fls8 then
					if tkclk='0' then
						i := 0; -- IP impl.tfrm.rising.ready.prepRun --- ILINE

						stateTfrm_next <= stateTfrmRunA;
					end if;

				else
					if btn='0' then
						stateTfrm_next <= stateTfrmBtnA;
					end if;
				end if;

			elsif stateTfrm=stateTfrmRunA then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunB then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmRunC;
				end if;

			elsif stateTfrm=stateTfrmRunC then
				if tkclk='0' then
					i := i + 1; -- IP impl.tfrm.rising.runC.inc --- ILINE

					if i=to_integer(unsigned(setTfrmTfrm)) then
						i := 0; -- IP impl.tfrm.rising.runC.prepRun --- ILINE

						stateTfrm_next <= stateTfrmRunA;

					else
						stateTfrm_next <= stateTfrmRunB;
					end if;
				end if;

			elsif stateTfrm=stateTfrmBtnA then
				if (btn='1' and tkclk='0') then
					stateTfrm_next <= stateTfrmBtnB;
				end if;

			elsif stateTfrm=stateTfrmBtnB then
				if tkclk='1' then
					stateTfrm_next <= stateTfrmBtnC;
				end if;

			elsif stateTfrm=stateTfrmBtnC then
				if btn='0' then
					stateTfrm_next <= stateTfrmBtnA;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.tfrm.rising --- END

	-- IP impl.tfrm.falling --- BEGIN
	process (mclk)
		-- IP impl.tfrm.falling.vars --- BEGIN
		-- IP impl.tfrm.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateTfrm <= stateTfrm_next;
			ackInvSetRng_sig <= ackInvSetRng_sig_next;
			ackInvSetTfrm_sig <= ackInvSetTfrm_sig_next;
		end if;
	end process;
	-- IP impl.tfrm.falling --- END

	------------------------------------------------------------------------
	-- implementation: VIS-L trigger (visl)
	------------------------------------------------------------------------

	-- IP impl.visl.wiring --- BEGIN
	trigVisl_sig <= '1' when ((stateVisl=stateVislReady and strbTfrm='1') or stateVisl=stateVislOn) else '0';
	trigVisl <= trigVisl_sig;
	-- IP impl.visl.wiring --- END

	-- IP impl.visl.rising --- BEGIN
	process (reset, mclk, stateVisl)
		-- IP impl.visl.rising.vars --- RBEGIN
		variable j: natural range 0 to (fMclk/1000); -- counter to 1µs
		-- IP impl.visl.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.visl.rising.asyncrst --- BEGIN
			stateVisl_next <= stateVislInit;
			-- IP impl.visl.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateVisl=stateVislInit or setRngRng=fls8) then
				-- IP impl.visl.rising.syncrst --- BEGIN
				-- IP impl.visl.rising.syncrst --- END

				if setRngRng=fls8 then
					stateVisl_next <= stateVislInit;

				else
					stateVisl_next <= stateVislReady;
				end if;

			elsif stateVisl=stateVislReady then
				if strbTfrm='1' then
					j := 0; -- IP impl.visl.rising.ready --- ILINE

					stateVisl_next <= stateVislOn;
				end if;

			elsif stateVisl=stateVislOn then
				j := j + 1; -- IP impl.visl.rising.on.ext --- ILINE

				if j=fMclk/10 then
					stateVisl_next <= stateVislReady;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.visl.rising --- END

	-- IP impl.visl.falling --- BEGIN
	process (mclk)
		-- IP impl.visl.falling.vars --- BEGIN
		-- IP impl.visl.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateVisl <= stateVisl_next;
		end if;
	end process;
	-- IP impl.visl.falling --- END

	------------------------------------------------------------------------
	-- implementation: VIS-R trigger (visr)
	------------------------------------------------------------------------

	-- IP impl.visr.wiring --- BEGIN
	ackInvSetTdlyVisr_sig <= '1' when stateVisr=stateVisrInv else '0';
	ackInvSetTdlyVisr <= ackInvSetTdlyVisr_sig;
	trigVisr_sig <= '1' when ((stateVisr=stateVisrReadyA and strbTfrm='1') or stateVisr=stateVisrOn) else '0';
	trigVisr <= trigVisr_sig;
	-- IP impl.visr.wiring --- END

	-- IP impl.visr.rising --- BEGIN
	process (reset, mclk, stateVisr)
		-- IP impl.visr.rising.vars --- RBEGIN
		variable i: natural range 0 to 65535; -- delay counter
		variable j: natural range 0 to (fMclk/1000); -- counter to 1µs
		-- IP impl.visr.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.visr.rising.asyncrst --- BEGIN
			stateVisr_next <= stateVisrInit;
			-- IP impl.visr.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateVisr=stateVisrInit or (stateVisr/=stateVisrInv and (reqInvSetTdlyVisr='1' or setRngRng=fls8))) then
				if reqInvSetTdlyVisr='1' then
					stateVisr_next <= stateVisrInv;

				else
					-- IP impl.visr.rising.syncrst --- BEGIN
					-- IP impl.visr.rising.syncrst --- END

					if setRngRng=fls8 then
						stateVisr_next <= stateVisrInit;

					elsif to_integer(unsigned(setTdlyVisrTdlyVisr))=0 then
						stateVisr_next <= stateVisrReadyA;

					else
						stateVisr_next <= stateVisrReadyB;
					end if;
				end if;

			elsif stateVisr=stateVisrInv then
				if reqInvSetTdlyVisr='0' then
					stateVisr_next <= stateVisrInit;
				end if;

			elsif stateVisr=stateVisrReadyA then
				if strbTfrm='1' then
					j := 0; -- IP impl.visr.rising.readyA --- ILINE

					stateVisr_next <= stateVisrOn;
				end if;

			elsif stateVisr=stateVisrReadyB then
				if strbTfrm='1' then
					-- IP impl.visr.rising.readyB.prepDelay --- IBEGIN
					i := 0;
					j := 0;
					-- IP impl.visr.rising.readyB.prepDelay --- IEND

					stateVisr_next <= stateVisrDelayA;
				end if;

			elsif stateVisr=stateVisrDelayA then
				if tkclk='0' then
					i := i + 1; -- IP impl.visr.rising.delayA.inc --- ILINE

					stateVisr_next <= stateVisrDelayB;
				end if;

			elsif stateVisr=stateVisrDelayB then
				if tkclk='1' then
					if i=to_integer(unsigned(setTdlyVisrTdlyVisr)) then
						stateVisr_next <= stateVisrOn;

					else
						stateVisr_next <= stateVisrDelayA;
					end if;
				end if;

			elsif stateVisr=stateVisrOn then
				j := j + 1; -- IP impl.visr.rising.on.ext --- ILINE

				if j=fMclk/10 then
					if to_integer(unsigned(setTdlyVisrTdlyVisr))=0 then
						stateVisr_next <= stateVisrReadyA;

					else
						stateVisr_next <= stateVisrReadyB;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.visr.rising --- END

	-- IP impl.visr.falling --- BEGIN
	process (mclk)
		-- IP impl.visr.falling.vars --- BEGIN
		-- IP impl.visr.falling.vars --- END
	begin
		if falling_edge(mclk) then
			stateVisr <= stateVisr_next;
		end if;
	end process;
	-- IP impl.visr.falling --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Trigger;



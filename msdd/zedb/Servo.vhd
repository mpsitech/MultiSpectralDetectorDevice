-- file Servo.vhd
-- Servo easy model controller implementation
-- author Alexander Wirthmueller
-- date created: 9 Aug 2018
-- date modified: 10 Sep 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Servo is
	generic (
		fMclk: natural range 1 to 1000000 := 50000 -- in kHz
	);
	port (
		reset: in std_logic;
		mclk: in std_logic;
		tkclk: in std_logic;

		reqInvSetTheta: in std_logic;
		ackInvSetTheta: out std_logic;

		setThetaTheta: in std_logic_vector(15 downto 0);

		reqInvSetPhi: in std_logic;
		ackInvSetPhi: out std_logic;

		setPhiPhi: in std_logic_vector(15 downto 0);

		tpwm: out std_logic;
		ppwm: out std_logic
	);
end Servo;

architecture Servo of Servo is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- phi axis servo PWM (phi)
	type statePhi_t is (
		statePhiInit,
		statePhiInv,
		statePhiOn,
		statePhiOff
	);
	signal statePhi: statePhi_t := statePhiInit;

	signal ackInvSetPhi_sig: std_logic;
	signal ppwm_sig: std_logic;

	-- IP sigs.phi.cust --- INSERT

	---- theta axis servo PWM (theta)
	type stateTheta_t is (
		stateThetaInit,
		stateThetaInv,
		stateThetaOn,
		stateThetaOff
	);
	signal stateTheta: stateTheta_t := stateThetaInit;

	signal ackInvSetTheta_sig: std_logic;
	signal tpwm_sig: std_logic;

	-- IP sigs.theta.cust --- INSERT

	---- microsecond clock (tus)
	type stateTus_t is (
		stateTusInit,
		stateTusRun
	);
	signal stateTus: stateTus_t := stateTusInit;

	signal strbTus: std_logic;

	-- IP sigs.tus.cust --- INSERT

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	------------------------------------------------------------------------
	-- implementation: phi axis servo PWM (phi)
	------------------------------------------------------------------------

	-- IP impl.phi.wiring --- BEGIN
	ackInvSetPhi_sig <= '1' when statePhi=statePhiInv else '0';
	ackInvSetPhi <= ackInvSetPhi_sig;
	ppwm_sig <= '1' when statePhi=statePhiOn else '0';
	ppwm <= ppwm_sig;
	-- IP impl.phi.wiring --- END

	-- IP impl.phi.rising --- BEGIN
	process (reset, mclk, statePhi)
		-- IP impl.phi.rising.vars --- RBEGIN
		constant imax: natural := 20000; -- 50Hz or 20ms
		variable i: natural range 0 to imax;

		variable ioff: natural range 0 to imax;
		-- IP impl.phi.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.phi.rising.asyncrst --- BEGIN
			statePhi <= statePhiInit;
			-- IP impl.phi.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (statePhi=statePhiInit or (statePhi/=statePhiInv and reqInvSetPhi='1')) then
				-- IP impl.phi.rising.syncrst --- RBEGIN
				i := 0;
				ioff := 1500 + to_integer(signed(setPhiPhi));
				-- IP impl.phi.rising.syncrst --- REND

				if reqInvSetPhi='1' then
					statePhi <= statePhiInv;

				else
					statePhi <= statePhiOn;
				end if;

			elsif statePhi=statePhiInv then
				if reqInvSetPhi='0' then
					statePhi <= statePhiInit;
				end if;

			elsif statePhi=statePhiOn then
				if strbTus='1' then
					i := i + 1; -- IP impl.phi.rising.on.inc --- ILINE

					if i=ioff then
						statePhi <= statePhiOff;
					end if;
				end if;

			elsif statePhi=statePhiOff then
				if strbTus='1' then
					i := i + 1; -- IP impl.phi.rising.off.inc --- ILINE

					if i=imax then
						i := 0; -- IP impl.phi.rising.off.prepOn --- ILINE

						statePhi <= statePhiOn;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.phi.rising --- END

	------------------------------------------------------------------------
	-- implementation: theta axis servo PWM (theta)
	------------------------------------------------------------------------

	-- IP impl.theta.wiring --- BEGIN
	ackInvSetTheta_sig <= '1' when stateTheta=stateThetaInv else '0';
	ackInvSetTheta <= ackInvSetTheta_sig;
	tpwm_sig <= '1' when stateTheta=stateThetaOn else '0';
	tpwm <= tpwm_sig;
	-- IP impl.theta.wiring --- END

	-- IP impl.theta.rising --- BEGIN
	process (reset, mclk, stateTheta)
		-- IP impl.theta.rising.vars --- RBEGIN
		constant imax: natural := 20000; -- 50Hz or 20ms
		variable i: natural range 0 to imax;

		variable ioff: natural range 0 to imax;
		-- IP impl.theta.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.theta.rising.asyncrst --- BEGIN
			stateTheta <= stateThetaInit;
			-- IP impl.theta.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if (stateTheta=stateThetaInit or (stateTheta/=stateThetaInv and reqInvSetTheta='1')) then
				-- IP impl.theta.rising.syncrst --- RBEGIN
				i := 0;
				ioff := 1500 + to_integer(signed(setThetaTheta));
				-- IP impl.theta.rising.syncrst --- REND

				if reqInvSetTheta='1' then
					stateTheta <= stateThetaInv;

				else
					stateTheta <= stateThetaOn;
				end if;

			elsif stateTheta=stateThetaInv then
				if reqInvSetTheta='0' then
					stateTheta <= stateThetaInit;
				end if;

			elsif stateTheta=stateThetaOn then
				if strbTus='1' then
					i := i + 1; -- IP impl.theta.rising.on.inc --- ILINE

					if i=ioff then
						stateTheta <= stateThetaOff;
					end if;
				end if;

			elsif stateTheta=stateThetaOff then
				if strbTus='1' then
					i := i + 1; -- IP impl.theta.rising.off.inc --- ILINE

					if i=imax then
						i := 0; -- IP impl.theta.rising.off.prepOn --- ILINE

						stateTheta <= stateThetaOn;
					end if;
				end if;
			end if;
		end if;
	end process;
	-- IP impl.theta.rising --- END

	------------------------------------------------------------------------
	-- implementation: microsecond clock (tus)
	------------------------------------------------------------------------

	-- IP impl.tus.wiring --- BEGIN
	-- IP impl.tus.wiring --- END

	-- IP impl.tus.rising --- BEGIN
	process (reset, mclk, stateTus)
		-- IP impl.tus.rising.vars --- RBEGIN
		variable i: natural range 0 to (fMclk/1000); -- µs counter
		-- IP impl.tus.rising.vars --- REND

	begin
		if reset='1' then
			-- IP impl.tus.rising.asyncrst --- BEGIN
			stateTus <= stateTusInit;
			strbTus <= '0';
			-- IP impl.tus.rising.asyncrst --- END

		elsif rising_edge(mclk) then
			if stateTus=stateTusInit then
				stateTus <= stateTusRun;

			elsif stateTus=stateTusRun then
				-- IP impl.tus.rising.run --- IBEGIN
				i := i + 1;

				if i=(fMclk/1000) then
					i := 0;

					strbTus <= '1';
				else
					strbTus <= '0';
				end if;
				-- IP impl.tus.rising.run --- IEND
			end if;
		end if;
	end process;
	-- IP impl.tus.rising --- END

	------------------------------------------------------------------------
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Servo;

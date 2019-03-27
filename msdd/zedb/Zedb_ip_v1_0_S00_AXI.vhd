-- file Zedb_ip_v1_0_S00_AXI.vhd
-- Zedb_ip_v1_0_S00_AXI zynq_ip_AXI_v1_0 wrapper implementation
-- author Alexander Wirthmueller
-- date created: 18 Oct 2018
-- date modified: 18 Oct 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Zedb_ip_v1_0_S00_AXI is
	generic (
		C_S_AXI_DATA_WIDTH: integer := 32;
		C_S_AXI_ADDR_WIDTH: integer := 4
	);
	port (
		S_AXI_ACLK: in std_logic;
		S_AXI_ARESETN: in std_logic;
		S_AXI_AWADDR: in std_logic_vector(3 downto 0);
		S_AXI_AWPROT: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID: in std_logic;
		S_AXI_AWREADY: out std_logic;
		S_AXI_WDATA: in std_logic_vector(31 downto 0);
		S_AXI_WSTRB: in std_logic_vector(3 downto 0);
		S_AXI_WVALID: in std_logic;
		S_AXI_WREADY: out std_logic;
		S_AXI_BRESP: out std_logic_vector(1 downto 0);
		S_AXI_BVALID: out std_logic;
		S_AXI_BREADY: in std_logic;
		S_AXI_ARADDR: in std_logic_vector(3 downto 0);
		S_AXI_ARPROT: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID: in std_logic;
		S_AXI_ARREADY: out std_logic;
		S_AXI_RDATA: out std_logic_vector(31 downto 0);
		S_AXI_RRESP: out std_logic_vector(1 downto 0);
		S_AXI_RVALID: out std_logic;
		S_AXI_RREADY: in std_logic;

		sw: in std_logic_vector(7 downto 0);
		gnd: out std_logic_vector(1 downto 0);
		JA: out std_logic_vector(7 downto 0);
		nxss: out std_logic;
		xsck: out std_logic;
		xmosi: out std_logic;
		xmiso: in std_logic;
		nass: out std_logic;
		asck: out std_logic;
		amosi: out std_logic;
		btnC: in std_logic;
		btnL: in std_logic;
		btnR: in std_logic;
		d60pwm: out std_logic;
		d15pwm: out std_logic;
		niss: out std_logic;
		isck: out std_logic;
		irxd: in std_logic;
		nirst: out std_logic;
		imclk: out std_logic;
		iscl: out std_logic;
		isda: inout std_logic;
		extclk: in std_logic;
		oledVdd: out std_logic;
		oledVbat: out std_logic;
		oledRes: out std_logic;
		oledDc: out std_logic;
		oledSclk: out std_logic;
		oledSdin: out std_logic;
		tpwm: out std_logic;
		ppwm: out std_logic;
		sgrn: out std_logic;
		sred: out std_logic;
		lmio: out std_logic_vector(1 downto 0);
		rmio: out std_logic_vector(1 downto 0);
		itxd: out std_logic
	);
end Zedb_ip_v1_0_S00_AXI;

architecture Zedb_ip_v1_0_S00_AXI of Zedb_ip_v1_0_S00_AXI is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Top is
		generic (
			fExtclk: natural range 1 to 1000000 := 100000;
			fMclk: natural range 1 to 1000000 := 50000
		);
		port (
			sw: in std_logic_vector(7 downto 0);
			gnd: out std_logic_vector(1 downto 0);
			JA: out std_logic_vector(7 downto 0);
			nxss: out std_logic;
			xsck: out std_logic;
			xmosi: out std_logic;
			xmiso: in std_logic;
			nass: out std_logic;
			asck: out std_logic;
			amosi: out std_logic;
			btnC: in std_logic;
			btnL: in std_logic;
			btnR: in std_logic;

			enRx: in std_logic;
			rx: in std_logic_vector(31 downto 0);
			strbRx: in std_logic;

			enTx: in std_logic;
			tx: out std_logic_vector(31 downto 0);
			strbTx: in std_logic;

			d60pwm: out std_logic;
			d15pwm: out std_logic;
			niss: out std_logic;
			isck: out std_logic;
			irxd: in std_logic;
			nirst: out std_logic;
			imclk: out std_logic;
			iscl: out std_logic;
			isda: inout std_logic;
			extclk: in std_logic;
			oledVdd: out std_logic;
			oledVbat: out std_logic;
			oledRes: out std_logic;
			oledDc: out std_logic;
			oledSclk: out std_logic;
			oledSdin: out std_logic;
			tpwm: out std_logic;
			ppwm: out std_logic;
			sgrn: out std_logic;
			sred: out std_logic;
			lmio: out std_logic_vector(1 downto 0);
			rmio: out std_logic_vector(1 downto 0);
			itxd: out std_logic
		);
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	signal axi_awaddr: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready: std_logic;
	signal axi_wready: std_logic;
	signal axi_bresp: std_logic_vector(1 downto 0);
	signal axi_bvalid: std_logic;
	signal axi_araddr: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready: std_logic;
	signal axi_rdata: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp: std_logic_vector(1 downto 0);
	signal axi_rvalid: std_logic;

	constant ADDR_LSB: integer := (C_S_AXI_DATA_WIDTH/32)+1;
	constant OPT_MEM_ADDR_BITS: integer := 1;

	signal slv_reg0: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_ld: std_logic;
	signal slv_reg_rden: std_logic;
	signal slv_reg_wren: std_logic;
	signal byte_index: integer;

	---- main operation (op)
	type stateOp_t is (
		stateOpInit,
		stateOpIdle,
		stateOpWrA, stateOpWrB, stateOpWrC, stateOpWrD,
		stateOpRdA, stateOpRdB, stateOpRdC, stateOpRdD, stateOpRdE
	);
	signal stateOp: stateOp_t := stateOpInit;

	signal enRx: std_logic := '0';
	signal rx: std_logic_vector(31 downto 0);

	signal enTx: std_logic := '0';
	signal tx: std_logic_vector(31 downto 0);

	---- rx/tx strobe (strb)
	type stateStrb_t is (
		stateStrbIdle,
		stateStrbRx,
		stateStrbTx
	);
	signal stateStrb: stateStrb_t := stateStrbIdle;

	signal strbRx: std_logic;
	signal strbTx: std_logic;

	---- timeout (to)
	type stateTo_t is (
		stateToInit,
		stateToWait,
		stateToDone
	);
	signal stateTo: stateTo_t := stateToInit;

	signal timeout: std_logic;

	--- handshake
	signal reqOpToStrbRx: std_logic;
	signal reqOpToStrbTx: std_logic;

	signal reqOpToToRestart: std_logic;

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myTop : Top
		generic map (
			fExtclk => 100000,
			fMclk => 50000
		)
		port map (
			sw => sw,
			gnd => gnd,
			JA => JA,
			nxss => nxss,
			xsck => xsck,
			xmosi => xmosi,
			xmiso => xmiso,
			nass => nass,
			asck => asck,
			amosi => amosi,
			btnC => btnC,
			btnL => btnL,
			btnR => btnR,

			enRx => enRx,
			rx => rx,
			strbRx => strbRx,

			enTx => enTx,
			tx => tx,
			strbTx => strbTx,

			d60pwm => d60pwm,
			d15pwm => d15pwm,
			niss => niss,
			isck => isck,
			irxd => irxd,
			nirst => nirst,
			imclk => imclk,
			iscl => iscl,
			isda => isda,
			extclk => extclk,
			oledVdd => oledVdd,
			oledVbat => oledVbat,
			oledRes => oledRes,
			oledDc => oledDc,
			oledSclk => oledSclk,
			oledSdin => oledSdin,
			tpwm => tpwm,
			ppwm => ppwm,
			sgrn => sgrn,
			sred => sred,
			lmio => lmio,
			rmio => rmio,
			itxd => itxd
		);

	------------------------------------------------------------------------
	-- implementation
	------------------------------------------------------------------------

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				axi_awready <= '0';
			else
				if (axi_awready='0' and S_AXI_AWVALID='1' and S_AXI_WVALID='1') then
					axi_awready <= '1';
				else
					axi_awready <= '0';
				end if;
			end if;
		end if;
	end process;

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				axi_awaddr <= (others => '0');
			else
				if (axi_awready='0' and S_AXI_AWVALID='1' and S_AXI_WVALID='1') then
					axi_awaddr <= S_AXI_AWADDR;
				end if;
			end if;
		end if;
	end process;

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				axi_wready <= '0';
			else
				if (axi_wready='0' and S_AXI_WVALID='1' and S_AXI_AWVALID='1') then
					axi_wready <= '1';
				else
					axi_wready <= '0';
				end if;
			end if;
		end if;
	end process;

	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

	process (S_AXI_ACLK)
		variable loc_addr: std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				slv_reg0 <= (others => '0');
				slv_reg1 <= (others => '0');
				slv_reg2 <= (others => '0');
				slv_reg3 <= (others => '0');
			else
				loc_addr := axi_awaddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB);
				if slv_reg_wren='1' then
					case loc_addr is
						when b"00" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index)='1' then
									slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"01" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index)='1' then
									slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"10" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index)='1' then
									slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"11" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if S_AXI_WSTRB(byte_index)='1' then
									slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when others =>
							slv_reg0 <= slv_reg0;
							slv_reg1 <= slv_reg1;
							slv_reg2 <= slv_reg2;
							slv_reg3 <= slv_reg3;
					end case;
				end if;
			end if;
		end if;
	end process;

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				axi_bvalid <= '0';
				axi_bresp <= "00";
			else
				if (axi_awready='1' and S_AXI_AWVALID='1' and axi_wready='1' and S_AXI_WVALID='1' and axi_bvalid='0') then
					axi_bvalid <= '1';
					axi_bresp <= "00";
				elsif (S_AXI_BREADY='1' and axi_bvalid='1') then
					axi_bvalid <= '0';
				end if;
			end if;
		end if;
	end process;

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				slv_reg_ld <= '0';
				axi_arready <= '0';
				axi_araddr <= (others => '1');
			else
				if (slv_reg_ld='0' and axi_arready='0' and S_AXI_ARVALID='1') then
					slv_reg_ld <= '1';
					axi_araddr	<= S_AXI_ARADDR;
				elsif (slv_reg_ld='1' and axi_arready='0' and S_AXI_ARVALID='1') then
					slv_reg_ld <= '0';
					axi_arready <= '1';
				else
					slv_reg_ld <= '0';
					axi_arready <= '0';
				end if;
			end if;
		end if;
	end process;

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				axi_rvalid <= '0';
				axi_rresp	<= "00";
			else
				if (axi_arready='1' and S_AXI_ARVALID='1' and axi_rvalid='0') then
					axi_rvalid <= '1';
					axi_rresp	<= "00";
				elsif (axi_rvalid='1' and S_AXI_RREADY='1') then
					axi_rvalid <= '0';
				end if;
			end if;
		end if;
	end process;

	slv_reg_rden <= slv_reg_ld and S_AXI_ARVALID and (not axi_rvalid) ;

	------------------------------------------------------------------------
	-- implementation: main operation (op)
	------------------------------------------------------------------------

	process (S_AXI_ARESETN, S_AXI_ACLK)
		variable loc_waddr: std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
		variable loc_raddr: std_logic_vector(OPT_MEM_ADDR_BITS downto 0);

	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN='0' then
				stateOp <= stateOpInit;
				enRx <= '0';
				enTx <= '0';
				axi_rdata <= (others => '0');
				reqOpToStrbRx <= '0';
				reqOpToStrbTx <= '0';
				reqOpToToRestart <= '0';

			else
				loc_waddr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
				loc_raddr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

				if stateOp=stateOpInit then
					axi_rdata <= (others => '0');
					reqOpToStrbRx <= '0';
					reqOpToStrbTx <= '0';
					reqOpToToRestart <= '0';

					stateOp <= stateOpIdle;

				elsif stateOp=stateOpIdle then
					if (axi_bvalid='1' and loc_waddr="00" and slv_reg0=x"AAAAAAAA") then
						enRx <= '1';
						stateOp <= stateOpWrA;
					elsif (axi_bvalid='1' and loc_waddr="10" and slv_reg2=x"AAAAAAAA") then
						enTx <= '1';
						stateOp <= stateOpRdA;
					end if;

				elsif stateOp=stateOpWrA then
					if axi_bvalid='0' then
						reqOpToToRestart <= '1';
						stateOp <= stateOpWrB;
					end if;

				elsif stateOp=stateOpWrB then
					if axi_bvalid='1' then
						if slv_reg0=x"AAAAAAAA" then
							if loc_waddr="01" then
								rx <= slv_reg1;

								reqOpToStrbRx <= '1';

								stateOp <= stateOpWrC;

							else
								stateOp <= stateOpWrA;
							end if;
						else
							enRx <= '0';
							stateOp <= stateOpWrD;
						end if;

					elsif timeout='1' then
						stateOp <= stateOpInit;
					else
						reqOpToToRestart <= '0';
					end if;

				elsif stateOp=stateOpWrC then
					reqOpToStrbRx <= '0';

					if axi_bvalid='0' then
						reqOpToToRestart <= '1';
						stateOp <= stateOpWrB;
					end if;

				elsif stateOp=stateOpWrD then
					if axi_bvalid='0' then
						stateOp <= stateOpInit;
					end if;

				elsif stateOp=stateOpRdA then
					if axi_bvalid='0' then
						reqOpToToRestart <= '1';

						stateOp <= stateOpRdB;
					end if;

				elsif stateOp=stateOpRdB then
					if axi_bvalid='1' then
						if slv_reg2=x"AAAAAAAA" then
							stateOp <= stateOpRdA;
						else
							enTx <= '0';
							stateOp <= stateOpRdE;
						end if;

					elsif slv_reg_rden='1'	then
						if loc_raddr="11" then
							axi_rdata <= tx;

							reqOpToStrbTx <= '1';

							stateOp <= stateOpRdC;
						else
							reqOpToToRestart <= '1';
						end if;

					elsif timeout='1' then
						stateOp <= stateOpInit;
					else
						reqOpToToRestart <= '0';
					end if;

				elsif stateOp=stateOpRdC then
					reqOpToStrbTx <= '0';

					if axi_rvalid='1' then
						stateOp <= stateOpRdD;
					end if;

				elsif stateOp=stateOpRdD then
					if axi_rvalid='0' then
						reqOpToToRestart <= '1';

						stateOp <= stateOpRdB;
					end if;

				elsif stateOp=stateOpRdE then
					if axi_bvalid='0' then
						stateOp <= stateOpInit;
					end if;
				end if;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: rx/tx strobe (strb)
	------------------------------------------------------------------------

	strbRx <= '1' when stateStrb=stateStrbRx else '0';

	strbTx <= '1' when stateStrb=stateStrbTx else '0';

	process (S_AXI_ARESETN, S_AXI_ACLK)
		variable i: natural range 0 to 4;
	begin
		if S_AXI_ARESETN='0' then
			stateStrb <= stateStrbIdle;
		elsif rising_edge(S_AXI_ACLK) then
			if stateStrb=stateStrbIdle then
				if reqOpToStrbRx='1' then
					i := 0;
					stateStrb <= stateStrbRx;
				elsif reqOpToStrbTx='1' then
					i := 0;
					stateStrb <= stateStrbTx;
				end if;

			elsif stateStrb=stateStrbRx then
				i := i + 1;

				if i=4 then
					stateStrb <= stateStrbIdle;
				end if;

			elsif stateStrb=stateStrbTx then
				i := i + 1;

				if i=4 then
					stateStrb <= stateStrbIdle;
				end if;
			end if;
		end if;
	end process;

	------------------------------------------------------------------------
	-- implementation: timeout (to)
	------------------------------------------------------------------------

	timeout <= '1' when (stateTo=stateToDone and reqOpToToRestart='0') else '0';

	process (S_AXI_ARESETN, S_AXI_ACLK, stateTo)
		constant twait: natural := 10000; -- in axiclk clocks ; for 50MHz, 10000 eq. 200us, 100000 eq. 2ms
		variable i: natural range 0 to twait;

	begin
		if S_AXI_ARESETN='0' then
			stateTo <= stateToInit;

		elsif rising_edge(S_AXI_ACLK) then
			if (reqOpToToRestart='1' or stateTo=stateToInit) then
				i := 0;

				if reqOpToToRestart='1' then
					stateTo <= stateToInit;
				else
					stateTo <= stateToWait;
				end if;

			elsif stateTo=stateToWait then
				if i=twait then
					stateTo <= stateToDone;
				else
					i := i + 1;
				end if;

			elsif stateTo=stateToDone then
				-- if reqOpToToRestart='1' then
				-- 	stateTo <= stateToInit;
				-- end if;
			end if;
		end if;
	end process;

end Zedb_ip_v1_0_S00_AXI;


-- file Zedb_ip_v1_0.vhd
-- Zedb_ip_v1_0 zynq_ip_v1_0 wrapper implementation
-- author Alexander Wirthmueller
-- date created: 18 Oct 2018
-- date modified: 18 Oct 2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Dbecore.all;
use work.Zedb.all;

entity Zedb_ip_v1_0 is
	generic (
		C_S00_AXI_DATA_WIDTH: integer := 32;
		C_S00_AXI_ADDR_WIDTH: integer := 4
	);
	port (
		s00_axi_aclk: in std_logic;
		s00_axi_aresetn: in std_logic;
		s00_axi_awaddr: in std_logic_vector(3 downto 0);
		s00_axi_awprot: in std_logic_vector(2 downto 0);
		s00_axi_awvalid: in std_logic;
		s00_axi_awready: out std_logic;
		s00_axi_wdata: in std_logic_vector(31 downto 0);
		s00_axi_wstrb: in std_logic_vector(3 downto 0);
		s00_axi_wvalid: in std_logic;
		s00_axi_wready: out std_logic;
		s00_axi_bresp: out std_logic_vector(1 downto 0);
		s00_axi_bvalid: out std_logic;
		s00_axi_bready: in std_logic;
		s00_axi_araddr: in std_logic_vector(3 downto 0);
		s00_axi_arprot: in std_logic_vector(2 downto 0);
		s00_axi_arvalid: in std_logic;
		s00_axi_arready: out std_logic;
		s00_axi_rdata: out std_logic_vector(31 downto 0);
		s00_axi_rresp: out std_logic_vector(1 downto 0);
		s00_axi_rvalid: out std_logic;
		s00_axi_rready: in std_logic;

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
end Zedb_ip_v1_0;

architecture Zedb_ip_v1_0 of Zedb_ip_v1_0 is

	------------------------------------------------------------------------
	-- component declarations
	------------------------------------------------------------------------

	component Zedb_ip_v1_0_S00_AXI is
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
	end component;

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	---- other
	-- IP sigs.oth.cust --- INSERT

begin

	------------------------------------------------------------------------
	-- sub-module instantiation
	------------------------------------------------------------------------

	myZedb_ip_AXI : Zedb_ip_v1_0_S00_AXI
		generic map (
			C_S_AXI_DATA_WIDTH => 32,
			C_S_AXI_ADDR_WIDTH => 4
		)
		port map (
			S_AXI_ACLK => s00_axi_aclk,
			S_AXI_ARESETN => s00_axi_aresetn,
			S_AXI_AWADDR => s00_axi_awaddr,
			S_AXI_AWPROT => s00_axi_awprot,
			S_AXI_AWVALID => s00_axi_awvalid,
			S_AXI_AWREADY => s00_axi_awready,
			S_AXI_WDATA => s00_axi_wdata,
			S_AXI_WSTRB => s00_axi_wstrb,
			S_AXI_WVALID => s00_axi_wvalid,
			S_AXI_WREADY => s00_axi_wready,
			S_AXI_BRESP => s00_axi_bresp,
			S_AXI_BVALID => s00_axi_bvalid,
			S_AXI_BREADY => s00_axi_bready,
			S_AXI_ARADDR => s00_axi_araddr,
			S_AXI_ARPROT => s00_axi_arprot,
			S_AXI_ARVALID => s00_axi_arvalid,
			S_AXI_ARREADY => s00_axi_arready,
			S_AXI_RDATA => s00_axi_rdata,
			S_AXI_RRESP => s00_axi_rresp,
			S_AXI_RVALID => s00_axi_rvalid,
			S_AXI_RREADY => s00_axi_rready,

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
	-- implementation: other 
	------------------------------------------------------------------------

	
	-- IP impl.oth.cust --- INSERT

end Zedb_ip_v1_0;


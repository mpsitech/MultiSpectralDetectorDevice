-- file Spimaster_v1_0.vhd
-- Spimaster_v1_0 module implementation
-- author Alexander Wirthmueller
-- date created: 17 May 2016
-- date modified: 28 Jan 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Spimaster_v1_0 is
	generic (
		fMclk: natural range 0 to 1000000;
	
		cpol: std_logic := '0';
		cpha: std_logic := '0';

		nssByteNotXfer: std_logic := '0';

		fSclk: natural range 0 to 50000000;
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
end Spimaster_v1_0;

architecture Spimaster_v1_0 of Spimaster_v1_0 is

	------------------------------------------------------------------------
	-- signal declarations
	------------------------------------------------------------------------

	-- transfer operation (xfer)
	type stateXfer_t is (
		stateXferInit,
		stateXferIdle,
		stateXferLoad,
		stateXferDataA, stateXferDataB,
		stateXferStore,
		stateXferStop,
		stateXferDone
	);
	signal stateXfer: stateXfer_t := stateXferInit;

	signal sclk_sig: std_logic;
	signal mosi_sig: std_logic;
	
	signal recv_sig: std_logic_vector(7 downto 0);

begin

	------------------------------------------------------------------------
	-- implementation: transfer operation (xfer)
	------------------------------------------------------------------------

	sclk_sig <= '1' when stateXfer=stateXferDataB else '0';

	nss <= '0' when (stateXfer=stateXferLoad or stateXfer=stateXferDataA or stateXfer=stateXferDataB or stateXfer=stateXferStore or (nssByteNotXfer='0' and stateXfer=stateXferStop)) else '1';

	sclk <= sclk_sig when cpol='0' else not sclk_sig;

	mosi <= mosi_sig;
	
	ack <= '1' when (stateXfer=stateXferLoad or stateXfer=stateXferDataA or stateXfer=stateXferDataB or stateXfer=stateXferStore or stateXfer=stateXferStop
				or stateXfer=stateXferDone) else '0';

	dne <= '1' when stateXfer=stateXferDone else '0';

	strbSend <= '0' when (stateXfer=stateXferDataA or stateXfer=stateXferDataB or stateXfer=stateXferStore or stateXfer=stateXferStop) else '1';

	recv <= recv_sig;
	
	strbRecv <= '0' when (stateXfer=stateXferLoad or stateXfer=stateXferDataA or stateXfer=stateXferDataB or stateXfer=stateXferStore) else '1';

	process (reset, mclk)
		variable send_var: std_logic_vector(7 downto 0);

		variable recvraw: std_logic_vector(7 downto 0);
		
		variable bitcnt: natural range 0 to 7;
		variable bytecnt: natural range 0 to 65536;

		variable i: natural range 0 to (1000*fMclk)/fSclk;
		variable j: natural range 0 to Nstop;

	begin
		if reset='1' then
			stateXfer <= stateXferInit;
			mosi_sig <= '0';
			recv_sig <= x"00";

		elsif rising_edge(mclk) then
			if stateXfer=stateXferInit then
				mosi_sig <= '0';
				recv_sig <= x"00";
				
				bytecnt := 0;

				stateXfer <= stateXferIdle;

			elsif stateXfer=stateXferIdle then
				if req='1' then
					if to_integer(unsigned(len))=0 then
						stateXfer <= stateXferDone;
					else
						stateXfer <= stateXferLoad;
					end if;
				end if;

			elsif stateXfer=stateXferLoad then
				if req='0' then
					stateXfer <= stateXferInit;

				else
					send_var := send;
						
					recvraw := x"00";

					bitcnt := 0;
					bytecnt := bytecnt + 1; -- byte count put out for send

					if cpha='0' then
						mosi_sig <= send_var(7-bitcnt);
					end if;

					i := 0;

					stateXfer <= stateXferDataA;
				end if;

			elsif stateXfer=stateXferDataA then -- sclk='0'
				i := i + 1;

				if i=((1000*fMclk)/fSclk)/2 then
					if cpha='0' then
						recvraw(7-bitcnt) := miso;
					elsif cpha='1' then
						mosi_sig <= send_var(7-bitcnt);
					end if;

					i := 0;

					stateXfer <= stateXferDataB;
				end if;

			elsif stateXfer=stateXferDataB then -- sclk='1'
				i := i + 1;

				if i=((1000*fMclk)/fSclk)/2 then
					i := 0;

					if cpha='1' then
						recvraw(7-bitcnt) := miso;
					end if;
					
					if bitcnt=7 then
						recv_sig <= recvraw;

						j := 0;
						
						stateXfer <= stateXferStore;

					else	
						bitcnt := bitcnt + 1;

						if cpha='0' then
							mosi_sig <= send_var(7-bitcnt);
						end if;
						
						stateXfer <= stateXferDataA;
					end if;
				end if;

			elsif stateXfer=stateXferStore then
				i := i + 1;
				stateXfer <= stateXferStop;
				
			elsif stateXfer=stateXferStop then
				i := i + 1;
				if i=(1000*fMclk)/fSclk then
					i := 0;

					j := j + 1;

					if j=Nstop then
						if bytecnt=to_integer(unsigned(len)) then
							stateXfer <= stateXferDone;
						else
							stateXfer <= stateXferLoad;
						end if;
					end if;
				end if;

			elsif stateXfer=stateXferDone then
				if req='0' then
					stateXfer <= stateXferInit;
				end if;
			end if;
		end if;
	end process;

end Spimaster_v1_0;


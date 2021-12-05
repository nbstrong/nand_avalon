library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nand_avalon is
	port
	(
		clk					: in	std_logic := '0';
		resetn				: in	std_logic := '0';
		readdata				: out	std_logic_vector(31 downto 0);
		writedata			: in	std_logic_vector(31 downto 0) := x"00000000";
		pread					: in	std_logic := '1';
		pwrite				: in	std_logic := '1';
		address				: in	std_logic_vector(1 downto 0);
		
		-- NAND chip control hardware interface. These signals should be bound to physical pins.
		nand_cle				: out	std_logic := '0';
		nand_ale				: out	std_logic := '0';
		nand_nwe				: out	std_logic := '1';
		nand_nwp				: out	std_logic := '0';
		nand_nce				: out	std_logic := '1';
		nand_nre				: out std_logic := '1';
		nand_rnb				: in	std_logic;
		-- NAND chip data hardware interface. These signals should be boiund to physical pins.
		nand_data			: inout	std_logic_vector(15 downto 0)
		
	);
end nand_avalon;

architecture action of nand_avalon is
	component nand_master
		port
		(
			nand_cle, nand_ale, nand_nwe, nand_nwp, nand_nce, nand_nre, busy : out std_logic;
			clk, enable, nand_rnb, nreset, activate : in std_logic;
			data_out : out std_logic_vector(7 downto 0);
			data_in, cmd_in : in std_logic_vector(7 downto 0);
			nand_data : inout std_logic_vector(15 downto 0)
		);
	end component;
	signal nreset 			: std_logic;
	signal n_data_out 	: std_logic_vector(7 downto 0);
	signal n_data_in		: std_logic_vector(7 downto 0);
	signal n_busy			: std_logic;
	signal n_activate		: std_logic;
	signal n_cmd_in		: std_logic_vector(7 downto 0);
	signal prev_pwrite	: std_logic;
	signal prev_address	: std_logic_vector(1 downto 0);
begin
	NANDA: nand_master
	port map
	(
		clk => clk, enable => '0',
		nand_cle => nand_cle, nand_ale => nand_ale, nand_nwe => nand_nwe, nand_nwp => nand_nwp, nand_nce => nand_nce, nand_nre => nand_nre,
		nand_rnb => nand_rnb, nand_data => nand_data,
		nreset => resetn, data_out => n_data_out, data_in => n_data_in, busy => n_busy, activate => n_activate, cmd_in => n_cmd_in
	);
	
	-- Registers:
	-- 0x00:		Data IO
	-- 0x04:		Command input
	-- 0x08:		Status output
	
	readdata(7 downto 0)	<= n_data_out when address = "00" else
									"0000000"&n_busy when address = "10" else
									"00000000";
									
	n_activate	<= '1' when (prev_address = "01" and prev_pwrite = '0' and pwrite = '1' and n_busy = '0') else
						'0';
						
	CONTROL_INPUTS:process(clk, address, pwrite, writedata)
	begin
		if(rising_edge(clk))then
			if(pwrite = '0' and address = "00")then
				n_data_in		<= writedata(7 downto 0);
			elsif(pwrite = '0' and address = "01")Then
				n_cmd_in			<= writedata(7 downto 0);
			end if;
		end if;
	end process;
	
	TRACK_ADDRESS:process(clk, address, pwrite)
	begin
		if(rising_edge(clk))then
			prev_address	<= address;
			prev_pwrite		<= pwrite;
		end if;
	end process;

end action;
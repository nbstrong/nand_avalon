-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Title							: ONFI compliant NAND interface
-- File							: testbench.vhd
-- Author						: Alexey Lyashko <pradd@opencores.org>
-- License						: LGPL
-------------------------------------------------------------------------------------------------
-- Description:
-- This is the testbench file for the NAND_MASTER module
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onfi.all;

entity tb is
	--port
	--(
	--);
end tb;

architecture test of tb is
	component nand_master
		port
		(
			-- System clock
			clk					: in	std_logic;
			-- NAND chip control hardware interface. These signals should be bound to physical pins.
			nand_cle				: out	std_logic := '0';
			nand_ale				: out	std_logic := '0';
			nand_nwe				: out	std_logic := '1';
			nand_nwp				: out	std_logic := '0';
			nand_nce				: out	std_logic := '1';
			nand_nre				: out std_logic := '1';
			nand_rnb				: in	std_logic;
			-- NAND chip data hardware interface. These signals should be boiund to physical pins.
			nand_data			: inout	std_logic_vector(15 downto 0);
			
			-- Component interface
			nreset				: in	std_logic := '1';
			data_out				: out	std_logic_vector(7 downto 0);
			data_in				: in	std_logic_vector(7 downto 0);
			busy					: out	std_logic := '0';
			activate				: in	std_logic := '0';
			cmd_in				: in	std_logic_vector(7 downto 0)
		);
	end component;
	-- Internal interface
	signal nand_cle : std_logic;
	signal nand_ale : std_logic;
	signal nand_nwe : std_logic;
	signal nand_nwp : std_logic;
	signal nand_nce :	std_logic;
	signal nand_nre : std_logic;
	signal nand_rnb : std_logic := '1';
	signal nand_data: std_logic_vector(15 downto 0);
	signal nreset   : std_logic := '1';
	signal data_out : std_logic_vector(7 downto 0);
	signal data_in  : std_logic_vector(7 downto 0);
	signal busy     : std_logic;
	signal activate : std_logic;
	signal cmd_in   : std_logic_vector(7 downto 0);
	signal clk	: std_logic := '1';
begin
	NM:nand_master
	port map
	(
		clk => clk,
		nand_cle => nand_cle,
		nand_ale => nand_ale,
		nand_nwe => nand_nwe,
		nand_nwp => nand_nwp,
		nand_nce => nand_nce,
		nand_nre => nand_nre,
		nand_rnb => nand_rnb,
		nand_data=> nand_data,
		nreset   => nreset,
		data_out => data_out,
		data_in  => data_in,
		busy     => busy,
		activate => activate,
		cmd_in   => cmd_in
	);
	
	CLOCK:process
	begin
		clk <= '1';
		wait for 1.25ns;
		clk <= '0';
		wait for 1.25ns;
	end process;

	TP: process
	begin
		activate <= '0';
		nreset <= '1';
		nand_data <= "ZZZZZZZZZZZZZZZZ";
		
		-- Enable the chip
		wait for 5ns;
		cmd_in <= x"09";
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		
		
		-- Read JEDEC ID
		data_in <= x"00";
		cmd_in <= x"03";
		wait for 5ns;
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		
		-- Provide ID
		wait for 155ns;
		nand_data <= x"002c";
		wait for 32.5ns;
		nand_data <= x"00e5";
		wait for 32.5ns;
		nand_data <= x"00ff";
		wait for 32.5ns;
		nand_data <= x"0003";
		wait for 32.5ns;
		nand_data <= x"0086";
		wait for 32.5ns;
		nand_data <= "ZZZZZZZZZZZZZZZZ";
		wait for 5ns;
		
		-- Read the bytes of the ID
		cmd_in <= x"0e";
		-- 1
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 2
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 3
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 4
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		wait for 2.5ns;
		-- 5
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		
		cmd_in <= x"08";
		wait for 2.5ns;
		activate <= '1';
		wait for 2.5ns;
		activate <= '0';
		
		
		wait;
	end process;

end test;
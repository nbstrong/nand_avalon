-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Title						: ONFI compliant NAND interface
-- File							: onfi_package.vhd
-- Author						: Alexey Lyashko <pradd@opencores.org>
-- License						: LGPL
-------------------------------------------------------------------------------------------------
-- Description:
-- This file contains clock cycle duration definition, delay timing constants as well as 
-- definition of FSM states and types used in the module.
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package onfi is
	-- Clock cycle length in ns
	-- IMPORTANT!!! The 'clock_cycle' is configured for 400MHz, change it appropriately!
	constant clock_cycle	: real := 2.5;

	-- NAND interface delays.
	-- Delays of 7.5ns may need to be fixed to 7.0.
	constant	t_cls		:	integer	:= integer(10.0	/ clock_cycle);
	constant	t_clh		:	integer	:= integer(5.0 	/ clock_cycle);
	constant	t_wp		:	integer	:= integer(10.0 	/ clock_cycle);
	constant	t_wh		:	integer	:= integer(7.5		/ clock_cycle);
	constant	t_wc		:	integer	:= integer(20.0	/ clock_cycle);
	constant	t_ds		:	integer	:= integer(7.5		/ clock_cycle);
	constant	t_dh		:	integer	:= integer(5.0		/ clock_cycle);
	constant	t_als		:	integer	:= integer(10.0	/ clock_cycle);
	constant	t_alh		:	integer	:= integer(5.0		/ clock_cycle);
	constant	t_rr		:	integer	:= integer(20.0	/ clock_cycle);
	constant	t_rea		:	integer	:= integer(16.0	/ clock_cycle);
	constant	t_rp		:	integer	:= integer(10.0	/ clock_cycle);
	constant	t_reh		:	integer	:= integer(7.5		/ clock_cycle);
	constant	t_wb		:	integer	:= integer(100.0	/ clock_cycle);
	constant	t_rst		:	integer	:= integer(5000.0	/ clock_cycle);
	constant	t_bers	:	integer	:=	integer(700000.0 / clock_cycle);
	constant	t_whr		:	integer	:=	integer(80.0	/ clock_cycle);
	constant	t_prog	:	integer	:=	integer(600000.0 / clock_cycle);
	constant	t_adl		:	integer	:=	integer(70.0	/ clock_cycle);
	
	type latch_t is (LATCH_CMD, LATCH_ADDR);
	type io_t is (IO_READ, IO_WRITE);
	
	type master_state_t is 
	(
		M_IDLE,								-- NAND Master is in idle state - awaits commands.
		M_RESET,								-- NAND Master is being reset.
		M_WAIT,								-- NAND Master waits for current operation to complete.
		M_DELAY,								-- Execute timed delay.
		M_NAND_RESET,						-- NAND Master executes NAND 'reset' command.
		M_NAND_READ_PARAM_PAGE,			-- Read ONFI parameter page.
		M_NAND_READ_ID,					-- Read the JEDEC ID of the chip.
		M_NAND_BLOCK_ERASE,				-- Erase block specified by address in current_address.
		M_NAND_READ_STATUS,				--	Read status byte.
		M_NAND_READ,						-- Reads page into the buffer.
		M_NAND_READ_8,
		M_NAND_READ_16,
		M_NAND_PAGE_PROGRAM,				-- Program one page.
		-- interface commands
		MI_GET_STATUS,						-- Returns the status byte.
		MI_CHIP_ENABLE,					-- Sets CE# to 0.
		MI_CHIP_DISABLE,					-- Sets CE# to 1.
		MI_WRITE_PROTECT,					-- Sets WP# to 0.
		MI_WRITE_ENABLE,					--	Sets WP# to 1.
		MI_RESET_INDEX,					-- Resets page_idx (used as indes into arrays) to 0.
		-- The following states depend on 'page_idx' pointer. If its value goes beyond the limits
		-- of the array, it is then reset to 0.
		MI_GET_ID_BYTE,					-- Gets chip_id(page_idx) byte.
		MI_GET_PARAM_PAGE_BYTE,			-- Gets page_param(page_idx) byte.
		MI_GET_DATA_PAGE_BYTE,			-- Gets page_data(page_idx) byte.
		MI_SET_DATA_PAGE_BYTE,			-- Sets value at page_data(page_idx).
		MI_GET_CURRENT_ADDRESS_BYTE,	-- Gets current_address(page_idx) byte.
		MI_SET_CURRENT_ADDRESS_BYTE,	-- Sets value at current_address(page_idx).
		-- Command processor bypass commands
		MI_BYPASS_ADDRESS,				-- Send address byte directly to NAND chip
		MI_BYPASS_COMMAND,				-- Send command byte directly to NAND chip
		MI_BYPASS_DATA_WR,				-- Send data byte directly to NAND chip
		MI_BYPASS_DATA_RD					-- Read data byte directly from NAND chip
	);
	
	type master_substate_t is
	(
		MS_BEGIN,
		MS_SUBMIT_COMMAND,
		MS_SUBMIT_COMMAND1,
		MS_SUBMIT_ADDRESS,
		MS_WRITE_DATA0,
		MS_WRITE_DATA1,
		MS_WRITE_DATA2,
		MS_WRITE_DATA3,
		MS_READ_DATA0,
		MS_READ_DATA1,
		MS_READ_DATA2,
		MS_DELAY,
		MS_WAIT,
		MS_END
	);
	
	type page_t is array (0 to 8628) of std_logic_vector(7 downto 0);
	type param_page_t is array (0 to 255) of std_logic_vector(7 downto 0);
	type nand_id_t is array (0 to 4) of std_logic_vector(7 downto 0);
	type nand_address_t is array (0 to 4) of std_logic_vector(7 downto 0);
	type states_t is array (0 to 255) of master_state_t;
	
	constant	max_page_idx	:	integer	:=	8626;
end onfi;

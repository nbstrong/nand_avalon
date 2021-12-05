-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Title						: ONFI compliant NAND interface
-- File							: io_unit.vhd
-- Author						: Alexey Lyashko <pradd@opencores.org>
-- License						: LGPL
-------------------------------------------------------------------------------------------------
-- Description:
-- This file implements data IO unit of the controller.
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onfi.all;

entity io_unit is
	generic (io_type : io_t);
	port
	(
		clk					:	in	std_logic;
		activate				:	in	std_logic;
		data_in				:	in	std_logic_vector(15 downto 0);
		
		io_ctrl				:	out std_logic := '1';
		data_out				:	out std_logic_vector(15 downto 0);
		busy					:	out std_logic
	);
end io_unit;



architecture action of io_unit is
	type io_state_t is (IO_IDLE, IO_HOLD, IO_DELAY);
	signal state			: io_state_t := IO_IDLE;
	signal n_state			: io_state_t := IO_IDLE;
	signal delay			: integer := 0;
	signal data_reg		: std_logic_vector(15 downto 0);
begin

	busy <= 	'1' when state /= IO_IDLE else
				'0';
	
	data_out	<=	data_reg when	(io_type = IO_WRITE and state /= IO_IDLE) or
										io_type = IO_READ else
										x"0000";
										
	io_ctrl	<=	'0' when state = IO_DELAY and n_state = IO_HOLD else
					'1';

	IO: process(clk, activate)
	begin
		if(rising_edge(clk))then
			case state is
				when IO_IDLE =>
					if(io_type = IO_WRITE)then
						data_reg				<= data_in;
					end if;
					if(activate = '1')then
						if(io_type = IO_WRITE)then
							delay			<= t_wp;
						else
							delay			<= t_rea;
						end if;
						n_state 			<= IO_HOLD;
						state 			<= IO_DELAY;
					end if;
				
				when IO_HOLD =>
					if(io_type = IO_WRITE)then
						delay				<= t_wh;
					else
						delay				<= t_reh;
					end if;
					n_state				<= IO_IDLE;
					state					<= IO_DELAY;
					
				when IO_DELAY =>
					if(delay > 1)then
						delay 			<= delay - 1;
						if(delay = 2 and io_type = IO_READ)then
							data_reg 	<= data_in;
						end if;
					else
--						if(io_type = IO_READ and n_state = IO_IDLE)then
--							data_reg		<= data_in;									-- This thing needs to be checked with real hardware. Assignment may be needed somewhat earlier.
--						end if;
						state 			<= n_state;
					end if;
				
				when others =>
					state 				<= IO_IDLE;
			end case;
		end if;
	end process;
end action;
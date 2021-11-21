-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Title						: ONFI compliant NAND interface
-- File							: latch_unit.vhd
-- Author						: Alexey Lyashko <pradd@opencores.org>
-- License						: LGPL
-------------------------------------------------------------------------------------------------
-- Description:
-- This file implements command/address latch component of the NAND controller, which takes 
-- care of dispatching commands to a NAND chip.
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onfi.all;


entity latch_unit is
	generic (latch_type : latch_t);
	port
	(
		clk				:	in	std_logic;
		activate			:	in	std_logic;
		data_in			:	in	std_logic_vector(15 downto 0);
		
		latch_ctrl		:	out std_logic := '0';
		write_enable	:	out std_logic := '1';
		busy				:	out std_logic := '0';
		data_out			:	out std_logic_vector(15 downto 0)
	);

end latch_unit;


architecture action of latch_unit is
	type latch_state_t is (LATCH_IDLE, LATCH_HOLD, LATCH_WAIT, LATCH_DELAY);
	signal state 	: latch_state_t := LATCH_IDLE;
	signal n_state : latch_state_t := LATCH_IDLE;
	signal delay 	: integer := 0;
begin

	busy <= '1' when state /= LATCH_IDLE else '0';
	
	latch_ctrl <=	'1' when state = LATCH_HOLD or
									(state = LATCH_DELAY and 
									(n_state = LATCH_HOLD or
									n_state = LATCH_WAIT)) else 
						'0';
									
	write_enable <=	'0' when (state = LATCH_DELAY and n_state = LATCH_HOLD) else 
							'1' when state /= LATCH_IDLE else
							'H';
							
	data_out	<=	data_in when (state /= LATCH_IDLE and state /= LATCH_WAIT and n_state /= LATCH_IDLE) else
					"LLLLLLLLLLLLLLLL";

	LATCH:process(clk, activate)
	begin
		if(rising_edge(clk))then
			case state is
				when LATCH_IDLE =>
					if(activate = '1')then
						n_state			<= LATCH_HOLD;
						state 			<= LATCH_DELAY;
						delay				<= t_wp;
					end if;
				
				when LATCH_HOLD =>
					if(latch_type = LATCH_CMD)then
						delay				<= t_clh;
					else
						delay				<= t_wh;
					end if;
					n_state				<= LATCH_WAIT;
					state					<= LATCH_DELAY;
				
				when LATCH_WAIT =>
					if(latch_type = LATCH_CMD)then
						-- Delay has been commented out. It is component's responsibility to 
						--	execute proper delay on command submission.
--						state					<= LATCH_DELAY;
						state					<= LATCH_IDLE;
						n_state 				<= LATCH_IDLE;
--						delay					<=	t_wb;						
					else
						state					<= LATCH_IDLE;
					end if;
				
				when LATCH_DELAY =>
					if(delay > 1)then
						delay 			<= delay - 1;
					else
						state 			<= n_state;
					end if;
					
				when others =>
					state					<=	LATCH_IDLE;
			end case;
		end if;
	end process;
end action;
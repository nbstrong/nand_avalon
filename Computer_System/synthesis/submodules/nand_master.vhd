-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Title							: ONFI compliant NAND interface
-- File							: nand_master.vhd
-- Author						: Alexey Lyashko <pradd@opencores.org>
-- License						: LGPL
-------------------------------------------------------------------------------------------------
-- Description:
-- The nand_master entity is the topmost entity of this ONFi (Open NAND Flash interface <http://www.onfi.org>)
-- compliant NAND flash controller. It provides very simple interface and short and easy to use
-- set of commands.
-- It is important to mention, that the controller takes care of delays and proper NAND command
-- sequences. See documentation for further details.
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.onfi.all;

entity nand_master is
	port
	(
		-- System clock
		clk					: in	std_logic;
		enable 				: in	std_logic;
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
		nreset				: in	std_logic;
		data_out				: out	std_logic_vector(7 downto 0);
		data_in				: in	std_logic_vector(7 downto 0);
		busy					: out	std_logic := '0';
		activate				: in	std_logic;
		cmd_in				: in	std_logic_vector(7 downto 0)
	);
end nand_master;

-- Structural architecture of the NAND_MASTER component.
architecture struct of nand_master is
	-- Latch Unit.
	-- This component implements NAND's address and command latch interfaces.
	component latch_unit
		generic(latch_type : latch_t);
		port(
			activate,
			clk : in std_logic;
			data_in : in std_logic_vector(15 downto 0);
			latch_ctrl,
			write_enable,
			busy : out std_logic;
			data_out : out std_logic_vector(15 downto 0)
		);
	end component;
	
	-- Latch unit related signals
	signal cle_activate			:	std_logic;
	signal cle_latch_ctrl		:	std_logic;
	signal cle_write_enable		:	std_logic;
	signal cle_busy				:	std_logic;
	signal cle_data_in			:	std_logic_vector(15 downto 0);
	signal cle_data_out			:	std_logic_vector(15 downto 0);
	
	signal ale_activate			:	std_logic;
	signal ale_latch_ctrl		:	std_logic;
	signal ale_write_enable		:	std_logic;
	signal ale_busy				:	std_logic;
	signal ale_data_in			:	std_logic_vector(15 downto 0);
	signal ale_data_out			:	std_logic_vector(15 downto 0);

	-- IO Unit.
	-- This component implements NAND's read/write interfaces.
	component io_unit
		generic (io_type : io_t);
		port(
			activate,
			clk : in std_logic;
			data_in : in std_logic_vector(15 downto 0);
			io_ctrl,
			busy : out std_logic;
			data_out : out std_logic_vector(15 downto 0)
		);
	end component;
	
	-- IO Unit related signals
	signal io_rd_activate		:	std_logic;
	signal io_rd_io_ctrl			:	std_logic;
	signal io_rd_busy				:	std_logic;
	signal io_rd_data_in			:	std_logic_vector(15 downto 0);
	signal io_rd_data_out		:	std_logic_vector(15 downto 0);
	
	signal io_wr_activate		:	std_logic;
	signal io_wr_io_ctrl			:	std_logic;
	signal io_wr_busy				:	std_logic;
	signal io_wr_data_in			:	std_logic_vector(15 downto 0);
	signal io_wr_data_out		:	std_logic_vector(15 downto 0);
	
	-- FSM
	signal state 					:	master_state_t	:= M_RESET;
	signal n_state					:	master_state_t := M_RESET;
	signal substate				:	master_substate_t	:= MS_BEGIN;
	signal n_substate				:	master_substate_t := MS_BEGIN;
	
	signal delay 					:	integer := 0;
	
	signal byte_count				:	integer := 0;
	signal page_idx				:	integer := 0;
	signal page_data				:	page_t;
	signal page_param				:	param_page_t;
	signal chip_id					:	nand_id_t;
	signal current_address		:	nand_address_t;
	signal data_bytes_per_page	:	integer;
	signal oob_bytes_per_page	:	integer;
	signal addr_cycles			:	integer;
	signal state_switch			:	states_t	:= 
		(
			0	=>	M_RESET,
			1	=>	M_NAND_RESET,
			2	=>	M_NAND_READ_PARAM_PAGE,
			3	=>	M_NAND_READ_ID,
			4	=>	M_NAND_BLOCK_ERASE,
			5	=>	M_NAND_READ_STATUS,
			6	=>	M_NAND_READ,
			7	=>	M_NAND_PAGE_PROGRAM,
			8	=>	MI_GET_STATUS,
			9	=>	MI_CHIP_ENABLE,
			10	=>	MI_CHIP_DISABLE,
			11	=>	MI_WRITE_PROTECT,
			12	=>	MI_WRITE_ENABLE,
			13	=>	MI_RESET_INDEX,
			14	=>	MI_GET_ID_BYTE,
			15	=>	MI_GET_PARAM_PAGE_BYTE,
			16	=>	MI_GET_DATA_PAGE_BYTE,
			17	=>	MI_SET_DATA_PAGE_BYTE,
			18	=>	MI_GET_CURRENT_ADDRESS_BYTE,
			19	=>	MI_SET_CURRENT_ADDRESS_BYTE,
			20 => MI_BYPASS_ADDRESS,
			21 => MI_BYPASS_COMMAND,
			22 => MI_BYPASS_DATA_WR,
			23 => MI_BYPASS_DATA_RD,
			others => M_IDLE
		);
	
--	The following is a sort of a status register. Bit set to 1 means TRUE, bit set to 0 means FALSE:
--	0 - is ONFI compliant
--	1 - bus width (0 - x8 / 1 - x16)
--	2 - is chip enabled
--	3 - is chip write protected
--	4 - array pointer out of bounds
--	5 - 
--	6 - 
--	7 - 
	signal status					:	std_logic_vector(7 downto 0) := x"00";
begin

	-- Asynchronous command latch interface.
	ACL: latch_unit 
	generic map (latch_type => LATCH_CMD)
	port map
	(
		activate => cle_activate,
		latch_ctrl => cle_latch_ctrl,
		write_enable => cle_write_enable,
		busy => cle_busy,
		clk => clk,
		data_in => cle_data_in,
		data_out => cle_data_out
	);
	
	-- Asynchronous address latch interface.
	AAL: latch_unit 
	generic map (latch_type => LATCH_ADDR)
	port map
	(
		activate => ale_activate,
		latch_ctrl => ale_latch_ctrl,
		write_enable => ale_write_enable,
		busy => ale_busy,
		clk => clk,
		data_in => ale_data_in,
		data_out => ale_data_out
	);
	
	-- Output to NAND
	IO_WR: io_unit
	generic map (io_type => IO_WRITE)
	port map
	(
		clk => clk,
		activate => io_wr_activate,
		data_in => io_wr_data_in,
		data_out => io_wr_data_out,
		io_ctrl => io_wr_io_ctrl,
		busy => io_wr_busy
	);
	
	-- Input from NAND
	IO_RD: io_unit
	generic map (io_type => IO_READ)
	port map
	(
		clk => clk,
		activate => io_rd_activate,
		data_in => io_rd_data_in,
		data_out => io_rd_data_out,
		io_ctrl => io_rd_io_ctrl,
		busy => io_rd_busy
	);
	
	-- Busy indicator
	busy	<= '0'	when state = M_IDLE else
				'1';
	
	-- Bidirection NAND data interface.
	--nand_data	<=	(cle_data_out or ale_data_out or io_wr_data_out) when (cle_busy or ale_busy or io_wr_busy) = '1' else x"ZZZZ";
	nand_data	<=	cle_data_out when cle_busy = '1' else
						ale_data_out when ale_busy = '1' else
						io_wr_data_out when io_wr_busy = '1' else
						"ZZZZZZZZZZZZZZZZ";
	io_rd_data_in	<=	nand_data;
	
	-- Command Latch Enable
	nand_cle		<= cle_latch_ctrl;
	
	-- Address Latch Enable
	nand_ale		<= ale_latch_ctrl;
	
	-- Write Enable
	nand_nwe		<=	cle_write_enable and ale_write_enable and io_wr_io_ctrl;
	
	-- Read Enable
	nand_nre		<= io_rd_io_ctrl;
	
	-- Activation of command latch unit
	cle_activate	<=	'1'	when 	state = M_NAND_RESET or																			-- initiate submission of RESET command
											(state = M_NAND_READ_PARAM_PAGE and substate = MS_BEGIN) or							-- initiate submission of READ PARAMETER PAGE command
											(state = M_NAND_BLOCK_ERASE and substate = MS_BEGIN) or								-- initiate submission of BLOCK ERASE command
											(state = M_NAND_BLOCK_ERASE and substate = MS_SUBMIT_COMMAND1) or					-- initiate submission of BLOCK ERASE 2 command
											(state = M_NAND_READ_STATUS and substate = MS_BEGIN) or								-- initiate submission of READ STATUS command
											(state = M_NAND_READ and substate = MS_BEGIN) or										-- initiate read mode for READ command
											(state = M_NAND_READ and substate = MS_SUBMIT_COMMAND1) or							-- initiate submission of READ command
											(state = M_NAND_PAGE_PROGRAM and substate = MS_BEGIN) or								-- initiate write mode for PAGE PROGRAM command
											(state = M_NAND_PAGE_PROGRAM and substate = MS_SUBMIT_COMMAND1) or				-- initiate submission for PAGE PROGRAM command
											(state = M_NAND_READ_ID and substate = MS_BEGIN) or									-- initiate submission of READ ID command
											(state = MI_BYPASS_COMMAND and substate = MS_SUBMIT_COMMAND) else 							-- direct command byte submission
							'0';
							
	-- Activation of address latch unit
	ale_activate	<=	'1'	when	(state = M_NAND_READ_PARAM_PAGE and substate = MS_SUBMIT_COMMAND) or				-- initiate address submission for READ PARAMETER PAGE command
											(state = M_NAND_BLOCK_ERASE and substate = MS_SUBMIT_COMMAND) or					-- initiate address submission for BLOCK ERASE command
											(state = M_NAND_READ and substate = MS_SUBMIT_COMMAND) or							-- initiate address submission for READ command
											(state = M_NAND_PAGE_PROGRAM and substate = MS_SUBMIT_ADDRESS) or					-- initiate address submission for PAGE PROGRAM command
											(state = M_NAND_READ_ID and substate = MS_SUBMIT_COMMAND) or						-- initiate address submission for READ ID command
											(state = MI_BYPASS_ADDRESS and substate = MS_SUBMIT_ADDRESS) else								-- direct address byte submission
							'0';
							
	-- Activation of read byte mechanism
	io_rd_activate	<=	'1'	when 	(state = M_NAND_READ_PARAM_PAGE and substate = MS_READ_DATA0) or					-- initiate byte read for READ PARAMETER PAGE command
											(state = M_NAND_READ_STATUS and substate = MS_READ_DATA0) or						-- initiate byte read for READ STATUS command
											(state = M_NAND_READ and substate = MS_READ_DATA0) or									-- initiate byte read for READ command
											(state = M_NAND_READ_ID and substate = MS_READ_DATA0) or								-- initiate byte read for READ ID command
											(state = MI_BYPASS_DATA_RD and substate = MS_BEGIN) else 							-- reading byte directly from the chip
							'0';
							
	-- Activation of write byte mechanism
	io_wr_activate	<=	'1'	when 	(state = M_NAND_PAGE_PROGRAM and substate = MS_WRITE_DATA3)	or						-- initiate byte write for PAGE_PROGRAM command
											(state = MI_BYPASS_DATA_WR and substate = MS_WRITE_DATA0) else						-- writing byte directly to the chip
							'0';
	
	MASTER: process(clk, nreset, activate, cmd_in, data_in, state_switch)
		variable tmp_int		:	std_logic_vector(31 downto 0);
		variable tmp			:	integer;
	begin
		if(nreset = '0')then
			state							<= M_RESET;
			
--		elsif(activate = '1')then
--			state							<= state_switch(to_integer(unsigned(cmd_in)));
			
		elsif(rising_edge(clk) and enable = '0')then
			case state is
				-- RESET state. Speaks for itself
				when M_RESET =>
					state					<= M_IDLE;
					substate				<= MS_BEGIN;
					delay					<= 0;
					byte_count			<= 0;
					page_idx				<= 0;
					current_address(0)<= x"00";
					current_address(1)<= x"00";
					current_address(2)<= x"00";
					current_address(3)<= x"00";
					current_address(4)<= x"00";
					data_bytes_per_page 	<= 0;
					oob_bytes_per_page 	<= 0;
					addr_cycles			<= 0;
					status				<= x"08";		-- We start write protected!
					nand_nce				<= '1';
					nand_nwp				<= '0';
				
				-- This is in fact a command interpreter
				when M_IDLE =>
					if(activate = '1')then
						state				<= state_switch(to_integer(unsigned(cmd_in)));
					end if;
				
				-- Reset the NAND chip
				when M_NAND_RESET =>
					cle_data_in			<= x"00ff";
					state					<= M_WAIT;
					n_state				<= M_IDLE;
					delay					<= t_wb + 8;
					
				-- Read the status register of the controller
				when MI_GET_STATUS =>
					data_out				<= status;
					state					<= M_IDLE;
				
				-- Set CE# to '0' (enable NAND chip)
				when MI_CHIP_ENABLE =>
					nand_nce				<= '0';
					state					<= M_IDLE;
					status(2)			<= '1';
					
				-- Set CE# to '1' (disable NAND chip)
				when MI_CHIP_DISABLE =>
					nand_nce				<= '1';
					state					<= M_IDLE;
					status(2)			<= '0';
					
				-- Set WP# to '0' (enable write protection)
				when MI_WRITE_PROTECT =>
					nand_nwp				<= '0';
					status(3)			<= '1';
					state					<= M_IDLE;
				
				-- Set WP# to '1' (disable write protection)
				-- By default, this controller has WP# set to 0 on reset
				when MI_WRITE_ENABLE =>
					nand_nwp				<= '1';
					status(3)			<= '0';
					state					<= M_IDLE;
					
				-- Reset the index register.
				-- Index register holds offsets into JEDEC ID, Parameter Page buffer or Data Page buffer depending on
				-- the operation being performed
				when MI_RESET_INDEX =>
					page_idx				<= 0;
					state					<= M_IDLE;
					
				-- Read 1 byte from JEDEC ID and increment the index register.
				-- If the value points outside the 5 byte JEDEC ID array, 
				-- the register is reset to 0 and bit 4 of the status register
				-- is set to '1'
				when MI_GET_ID_BYTE =>
					if(page_idx < 5)then
						data_out				<= chip_id(page_idx);
						page_idx				<= page_idx + 1;
						status(4)			<= '0';
					else
						data_out				<= x"00";
						page_idx				<= 0;
						status(4)			<= '1';
					end if;
					state						<= M_IDLE;
					
				-- Read 1 byte from 256 bytes buffer that holds the Parameter Page.
				-- If the value goes beyond 255, then the register is reset and 
				-- bit 4 of the status register is set to '1'
				when MI_GET_PARAM_PAGE_BYTE =>
					if(page_idx < 256)then
						data_out				<= page_param(page_idx);
						page_idx				<= page_idx + 1;
						status(4)			<= '0';
					else
						data_out				<= x"00";
						page_idx				<= 0;
						status(4)			<= '1';
					end if;
					state						<= M_IDLE;
					
				-- Read 1 byte from the buffer that holds the content of last read 
				-- page. The limit is variable and depends on the values in 
				-- the Parameter Page. In case the index register points beyond 
				-- valid page content, its value is reset and bit 4 of the status
				-- register is set to '1'
				when MI_GET_DATA_PAGE_BYTE =>
					if(page_idx < data_bytes_per_page + oob_bytes_per_page)then
						data_out				<= page_data(page_idx);
						page_idx				<= page_idx + 1;
						status(4)			<= '0';
					else
						data_out				<= x"00";
						page_idx				<= 0;
						status(4)			<= '1';
					end if;
					state						<= M_IDLE;
				
				-- Write 1 byte into the Data Page buffer at offset specified by
				-- the index register. If the value of the index register points 
				-- beyond valid page content, its value is reset and bit 4 of
				-- the status register is set to '1'
				when MI_SET_DATA_PAGE_BYTE =>
					if(page_idx < data_bytes_per_page + oob_bytes_per_page)then
						page_data(page_idx)	<= data_in;
						page_idx					<= page_idx + 1;
						status(4)				<= '0';
					else
						page_idx					<= 0;
						status(4) 				<= '1';
					end if;
					state						<= M_IDLE;
					
				-- Gets the address byte specified by the index register. Bit 4 
				-- of the status register is set to '1' if the value of the index 
				-- register points beyond valid address data and the value of 
				-- the index register is reset
				when MI_GET_CURRENT_ADDRESS_BYTE =>
					if(page_idx < addr_cycles)then
						data_out					<= current_address(page_idx);
						page_idx					<= page_idx + 1;
						status(4)				<= '0';
					else
						page_idx					<= 0;
						status(4)				<= '1';
					end if;
					state						<= M_IDLE;
					
				-- Sets the value of the address byte specified by the index register.Bit 4 
				-- of the status register is set to '1' if the value of the index 
				-- register points beyond valid address data and the value of 
				-- the index register is reset
				when MI_SET_CURRENT_ADDRESS_BYTE =>
					if(page_idx < addr_cycles)then
						current_address(page_idx) <= data_in;
						page_idx					<= page_idx + 1;
						status(4)				<= '0';
					else
						page_idx					<= 0;
						status(4)				<= '1';
					end if;
					state						<= M_IDLE;
				
				-- Program one page.
				when M_NAND_PAGE_PROGRAM =>
					if(substate = MS_BEGIN)then
						cle_data_in		<= x"0080";
						substate			<= MS_SUBMIT_COMMAND;
						state 			<= M_WAIT;
						n_state			<= M_NAND_PAGE_PROGRAM;
						byte_count		<= 0;
						
					elsif(substate = MS_SUBMIT_COMMAND)then
						byte_count		<= byte_count + 1;
						ale_data_in		<= x"00"&current_address(byte_count);
						substate			<= MS_SUBMIT_ADDRESS;
						
					elsif(substate = MS_SUBMIT_ADDRESS)then
						if(byte_count < addr_cycles)then
							substate		<= MS_SUBMIT_COMMAND;
						else
							substate		<= MS_WRITE_DATA0;
						end if;
						state				<= M_WAIT;
						n_state			<= M_NAND_PAGE_PROGRAM;
						
					elsif(substate = MS_WRITE_DATA0)then
						delay				<= t_adl;
						state				<= M_DELAY;
						n_state			<= M_NAND_PAGE_PROGRAM;
						substate			<=	MS_WRITE_DATA1;
						page_idx			<= 0;
						byte_count		<= 0;

					elsif(substate = MS_WRITE_DATA1)then
						byte_count		<= byte_count + 1;
						page_idx			<= page_idx + 1;
						io_wr_data_in	<= x"00"&page_data(page_idx);
						if(status(1) = '0')then
							substate		<= MS_WRITE_DATA3;
						else
							substate		<= MS_WRITE_DATA2;
						end if;
						
					elsif(substate = MS_WRITE_DATA2)then
						page_idx			<= page_idx + 1;
						io_wr_data_in(15 downto 8) <= page_data(page_idx);
						substate			<= MS_WRITE_DATA3;
						
					elsif(substate = MS_WRITE_DATA3)then
						if(byte_count < data_bytes_per_page + oob_bytes_per_page)then
							substate		<= MS_WRITE_DATA1;
						else
							substate		<= MS_SUBMIT_COMMAND1;
						end if;
						n_state			<= M_NAND_PAGE_PROGRAM;
						state				<= M_WAIT;
						
					elsif(substate = MS_SUBMIT_COMMAND1)then
						cle_data_in		<= x"0010";
						n_state			<= M_NAND_PAGE_PROGRAM;
						state				<= M_WAIT;
						substate			<= MS_WAIT;
						
					elsif(substate = MS_WAIT)then
						delay				<= t_wb + t_prog;
						state				<= M_DELAY;
						n_state			<= M_NAND_PAGE_PROGRAM;
						substate			<= MS_END;
						byte_count		<= 0;
						page_idx			<= 0;
						
					elsif(substate = MS_END)then
						state				<= M_WAIT;
						n_state			<= M_IDLE;
						substate			<= MS_BEGIN;
					end if;
				
				
				-- Reads single page into the buffer.
				when M_NAND_READ =>
					if(substate = MS_BEGIN)then
						cle_data_in		<= x"0000";
						substate			<= MS_SUBMIT_COMMAND;
						state				<= M_WAIT;
						n_state			<= M_NAND_READ;
						byte_count		<= 0;
						
					elsif(substate = MS_SUBMIT_COMMAND)then
						byte_count		<= byte_count + 1;
						ale_data_in		<= x"00"&current_address(byte_count);
						substate			<= MS_SUBMIT_ADDRESS;
						
					elsif(substate = MS_SUBMIT_ADDRESS)then
						if(byte_count < addr_cycles)then
							substate		<= MS_SUBMIT_COMMAND;
						else
							substate		<= MS_SUBMIT_COMMAND1;
						end if;
						state				<= M_WAIT;
						n_state			<= M_NAND_READ;
						
					elsif(substate = MS_SUBMIT_COMMAND1)then
						cle_data_in		<= x"0030";
--						delay 			<= t_wb;
						substate			<= MS_DELAY;
						state 			<= M_WAIT;
						n_state			<= M_NAND_READ;
						
					elsif(substate = MS_DELAY)then
						delay				<= t_wb;
						substate			<= MS_READ_DATA0;
						state				<= M_WAIT; --M_DELAY;
						n_state			<= M_NAND_READ;
						byte_count		<= 0;
						page_idx			<= 0;
						
					elsif(substate = MS_READ_DATA0)then
						byte_count		<= byte_count + 1;
						n_state			<= M_NAND_READ;
						delay				<= t_rr;
						state				<= M_WAIT;
						substate			<= MS_READ_DATA1;
					
					elsif(substate = MS_READ_DATA1)then
						page_data(page_idx)	<= io_rd_data_out(7 downto 0);
						page_idx			<= page_idx + 1;
						if(byte_count = data_bytes_per_page + oob_bytes_per_page and status(1) = '0')then
							substate		<= MS_END;
						else
							if(status(1) = '0')then
								substate		<= MS_READ_DATA0;
							else
								substate		<= MS_READ_DATA2;
							end if;
						end if;
						
					elsif(substate = MS_READ_DATA2)then
						page_idx			<= page_idx + 1;
						page_data(page_idx)	<= io_rd_data_out(15 downto 8);
						if(byte_count = data_bytes_per_page + oob_bytes_per_page)then
							substate		<= MS_END;
						else
							substate		<= MS_READ_DATA0;
						end if;
						
					elsif(substate = MS_END)then
						substate			<= MS_BEGIN;
						state				<= M_IDLE;
						byte_count		<= 0;
					end if;
				
				-- Read status byte
				when M_NAND_READ_STATUS =>
					if(substate = MS_BEGIN)then
						cle_data_in		<= x"0070";
						substate			<= MS_SUBMIT_COMMAND;
						state				<= M_WAIT;
						n_state			<= M_NAND_READ_STATUS;
						
					elsif(substate = MS_SUBMIT_COMMAND)then
						delay				<= t_whr;
						substate			<= MS_READ_DATA0;
						state				<= M_DELAY;
						n_state			<= M_NAND_READ_STATUS;
						
					elsif(substate = MS_READ_DATA0)then
						substate			<= MS_READ_DATA1;
						state				<= M_WAIT;
						n_state			<= M_NAND_READ_STATUS;
						
					elsif(substate = MS_READ_DATA1)then						-- This is to make sure 'data_out' has valid data before 'busy' goes low.
						data_out			<= io_rd_data_out(7 downto 0);
						state				<= M_NAND_READ_STATUS;
						substate			<= MS_END;
						
					elsif(substate = MS_END)then
						substate			<= MS_BEGIN;
						state				<= M_IDLE;
					end if;
					
				-- Erase block specified by current_address
				when M_NAND_BLOCK_ERASE =>
					if(substate = MS_BEGIN)then
						cle_data_in		<= x"0060";
						substate			<= MS_SUBMIT_COMMAND;
						state				<= M_WAIT;
						n_state			<= M_NAND_BLOCK_ERASE;
						byte_count		<= 3;							-- number of address bytes to submit
						
					elsif(substate = MS_SUBMIT_COMMAND)then
						byte_count		<= byte_count - 1;
						ale_data_in(15 downto 8) <= x"00";
						ale_data_in(7 downto 0)	<= current_address(5 - byte_count);
						substate			<= MS_SUBMIT_ADDRESS;
						state				<= M_WAIT;
						n_state			<= M_NAND_BLOCK_ERASE;
						
					elsif(substate = MS_SUBMIT_ADDRESS)then
						if(0 < byte_count)then
							substate		<= MS_SUBMIT_COMMAND;
						else
							substate		<= MS_SUBMIT_COMMAND1;
						end if;
						
					elsif(substate = MS_SUBMIT_COMMAND1)then
						cle_data_in		<= x"00d0";
						substate			<= MS_END;
						state				<= M_WAIT;
						n_state			<= M_NAND_BLOCK_ERASE;
						
					elsif(substate = MS_END)then
						n_state			<= M_IDLE;
						delay 			<= t_wb + t_bers;
						state				<= M_DELAY;
						substate			<= MS_BEGIN;
						byte_count		<= 0;
					end if;
					
				-- Read NAND chip JEDEC ID
				when M_NAND_READ_ID =>
					if(substate = MS_BEGIN)then
						cle_data_in		<= x"0090";
						substate			<= MS_SUBMIT_COMMAND;
						state				<= M_WAIT;
						n_state 			<= M_NAND_READ_ID;
					
					elsif(substate = MS_SUBMIT_COMMAND)then
						ale_data_in		<= X"0000";
						substate			<= MS_SUBMIT_ADDRESS;
						state 			<= M_WAIT;
						n_state			<= M_NAND_READ_ID;
						
					elsif(substate = MS_SUBMIT_ADDRESS)then
						delay				<= t_wb;
						state				<= M_DELAY;
						n_state			<= M_NAND_READ_ID;
						substate			<= MS_READ_DATA0;
						byte_count		<= 5;
						page_idx			<= 0;
						
					elsif(substate = MS_READ_DATA0)then
						byte_count		<= byte_count - 1;
						state				<= M_WAIT;
						n_state			<= M_NAND_READ_ID;
						substate			<= MS_READ_DATA1;
						
					elsif(substate = MS_READ_DATA1)then
						chip_id(page_idx)	<= io_rd_data_out(7 downto 0);
						if(0 < byte_count)then
							page_idx					<= page_idx + 1;
							substate					<= MS_READ_DATA0;
						else
							substate					<= MS_END;
						end if;
						
					elsif(substate = MS_END)then
						byte_count		<= 0;
						page_idx			<= 0;
						substate			<= MS_BEGIN;
						state				<= M_IDLE;
					end if;
					
				-- *data_in is assigned one clock cycle after *_activate is triggered!!!!
				-- According to ONFI's timing diagrams this should be normal, but who knows...
				when M_NAND_READ_PARAM_PAGE =>						
					if(substate = MS_BEGIN)then
						cle_data_in		<= x"00ec";
						substate			<= MS_SUBMIT_COMMAND;
						state				<= M_WAIT;
						n_state 			<= M_NAND_READ_PARAM_PAGE;
					
					elsif(substate = MS_SUBMIT_COMMAND)then
						ale_data_in		<= X"0000";
						substate			<= MS_SUBMIT_ADDRESS;
						state 			<= M_WAIT;
						n_state			<= M_NAND_READ_PARAM_PAGE;
						
					elsif(substate = MS_SUBMIT_ADDRESS)then
						delay				<= t_wb + t_rr;
						state				<= M_WAIT;--M_DELAY;
						n_state			<= M_NAND_READ_PARAM_PAGE;
						substate			<= MS_READ_DATA0;
						byte_count		<= 256;
						page_idx			<= 0;
						
					elsif(substate = MS_READ_DATA0)then
						byte_count		<= byte_count - 1;
						state				<= M_WAIT;
						n_state			<= M_NAND_READ_PARAM_PAGE;
						substate			<= MS_READ_DATA1;
						
					elsif(substate = MS_READ_DATA1)then
						page_param(page_idx)	<= io_rd_data_out(7 downto 0);
						if(0 < byte_count)then
							page_idx					<= page_idx + 1;
							substate					<= MS_READ_DATA0;
						else
							substate					<= MS_END;
						end if;
						
					elsif(substate = MS_END)then
						byte_count		<= 0;
						page_idx			<= 0;
						substate			<= MS_BEGIN;
						state				<= M_IDLE;
						
						-- Check the chip for being ONFI compliant
						if(page_param(0) = x"4f" and page_param(1) = x"4e" and page_param(2) = x"46" and page_param(3) = x"49")then
							-- Set status bit 0
							status(0)					<= '1';
							
							-- Bus width
							status(1)					<= page_param(6)(0);
							
							-- Setup counters:
							-- Normal FLAsh
							if(page_param(63) = x"20")then
								-- Number of bytes per page
								tmp_int						:= page_param(83)&page_param(82)&page_param(81)&page_param(80);
								data_bytes_per_page 		<= to_integer(unsigned(tmp_int));
								
								-- Number of spare bytes per page (OOB)
								tmp_int						:= "0000000000000000" & page_param(85) & page_param(84);
								oob_bytes_per_page		<= to_integer(unsigned(tmp_int));
								
								-- Number of address cycles
								addr_cycles					<= to_integer(unsigned(page_param(101)(3 downto 0))) + to_integer(unsigned(page_param(101)(7 downto 4)));
							else
								-- Number of bytes per page
								tmp_int						:= page_param(82)&page_param(81)&page_param(80)&page_param(79);
								data_bytes_per_page 		<= to_integer(unsigned(tmp_int));
								
								-- Number of spare bytes per page (OOB)
								tmp_int						:= "0000000000000000" & page_param(84) & page_param(83);
								oob_bytes_per_page		<= to_integer(unsigned(tmp_int));
								
								-- Number of address cycles
								addr_cycles					<= to_integer(unsigned(page_param(100)(3 downto 0))) + to_integer(unsigned(page_param(100)(7 downto 4)));
							end if;
						end if;
					end if;
				
				-- Wait for latch and IO modules to become ready as well as for NAND's R/B# to be '1'
				when M_WAIT =>
					if(delay > 1)then
						delay				<= delay - 1;
					elsif('0' = (cle_busy or ale_busy or io_rd_busy or io_wr_busy or (not nand_rnb)))then
						state				<= n_state;
					end if;
					
				-- Simple delay mechanism
				when M_DELAY =>
					if(delay > 1)then
						delay 			<= delay - 1;
					else
						state				<= n_state;
					end if;
					
				when MI_BYPASS_ADDRESS =>
					if(substate = MS_BEGIN)then
						ale_data_in		<= x"00"&data_in(7 downto 0);
						substate			<= MS_SUBMIT_ADDRESS;
						state 			<= M_WAIT;
						n_state			<= MI_BYPASS_ADDRESS;
						
					elsif(substate = MS_SUBMIT_ADDRESS)then
						delay				<= t_wb + t_rr;
						state				<= M_WAIT;--M_DELAY;
						n_state			<= MI_BYPASS_ADDRESS;
						substate			<= MS_END;
						
					elsif(substate = MS_END)then
						substate 		<= MS_BEGIN;
						state 			<= M_IDLE;
					end if;
				
				when MI_BYPASS_COMMAND =>
					if(substate = MS_BEGIN)then
						cle_data_in		<= x"00"&data_in(7 downto 0);
						substate			<= MS_SUBMIT_COMMAND;
						state 			<= M_WAIT;
						n_state			<= MI_BYPASS_COMMAND;
						
					elsif(substate = MS_SUBMIT_COMMAND)then
						delay				<= t_wb + t_rr;
						state				<= M_WAIT;--M_DELAY;
						n_state			<= MI_BYPASS_COMMAND;
						substate			<= MS_END;
						
					elsif(substate = MS_END)then
						substate 		<= MS_BEGIN;
						state 			<= M_IDLE;
					end if;
				
				when MI_BYPASS_DATA_WR =>
					if(substate = MS_BEGIN)then
						io_wr_data_in(15 downto 0) <= x"00"&data_in(7 downto 0); --page_data(page_idx);
						substate 		<= MS_WRITE_DATA0;
						state 			<= M_WAIT;
						n_state			<= MI_BYPASS_DATA_WR;
						
					elsif(substate = MS_WRITE_DATA0)then
						state 			<= M_WAIT;
						n_state 			<= M_IDLE;
						substate			<= MS_BEGIN;
					end if;
				
				when MI_BYPASS_DATA_RD =>
					if(substate = MS_BEGIN)then
						substate			<= MS_READ_DATA0;
						
					elsif(substate = MS_READ_DATA0)then
						--page_data(page_idx) <= io_rd_data_out(7 downto 0);
						data_out(7 downto 0) <= io_rd_data_out(7 downto 0);
						substate			<= MS_BEGIN;
						state 			<= M_IDLE;
					end if;
				
				-- For just in case ("Shit happens..." (C) Forrest Gump)
				when others =>
					state 				<= M_RESET;
			end case;
		end if;
	end process;
end struct;


// Testbench
`timescale 1ns / 1ps

// Memory Model Specific Macros
`define x8
`define V33
//`define SHORT_RESET
`define CLASSB

// Nand Avalon Address Macros
`define DATA_REG 2'h0
`define CMD_REG  2'h1
`define STATUS_REG 2'h2

`define PRINT_CMDS 0
`define PRINT_PASSES 0

// Nand Avalon Command Macros
// Consider making this an enum
typedef enum {
    INTERNAL_RESET_CMD                = 00,
    NAND_RESET_CMD                    = 01,
    NAND_READ_PARAMETER_PAGE_CMD      = 02,
    NAND_READ_ID_CMD                  = 03,
    NAND_BLOCK_ERASE_CMD              = 04,
    NAND_READ_STATUS_CMD              = 05,
    NAND_READ_PAGE_CMD                = 06,
    NAND_PAGE_PROGRAM_CMD             = 07,
    CTRL_GET_STATUS_CMD               = 08,
    CTRL_CHIP_ENABLE_CMD              = 09,
    CTRL_CHIP_DISABLE_CMD             = 10,
    CTRL_WRITE_PROTECT_CMD            = 11,
    CTRL_WRITE_ENABLE_CMD             = 12,
    CTRL_RESET_INDEX_CMD              = 13,
    CTRL_GET_ID_BYTE_CMD              = 14,
    CTRL_GET_PARAMETER_PAGE_BYTE_CMD  = 15,
    CTRL_GET_DATA_PAGE_BYTE_CMD       = 16,
    CTRL_SET_DATA_PAGE_BYTE_CMD       = 17,
    CTRL_GET_CURRENT_ADDRESS_BYTE_CMD = 18,
    CTRL_SET_CURRENT_ADDRESS_BYTE_CMD = 19,
    NAND_BYPASS_ADDRESS               = 20,
    NAND_BYPASS_COMMAND               = 21,
    NAND_BYPASS_DATA_WR               = 22,
    NAND_BYPASS_DATA_RD               = 23
} e_cmd;

module tb;
  wire         CLOCK_50;
  wire         CLOCK2_50;
  wire         CLOCK3_50;
  wire         CLOCK4_50;
  wire         ADC_CS_N;
  wire         ADC_DIN;
  wire         ADC_DOUT;
  wire         ADC_SCLK;
  wire         AUD_ADCDAT;
  wire         AUD_ADCLRCK;
  wire         AUD_BCLK;
  wire         AUD_DACDAT;
  wire         AUD_DACLRCK;
  wire         AUD_XCK;
  wire [12: 0] DRAM_ADDR;
  wire [ 1: 0] DRAM_BA;
  wire         DRAM_CAS_N;
  wire         DRAM_CKE;
  wire         DRAM_CLK;
  wire         DRAM_CS_N;
  wire [15: 0] DRAM_DQ;
  wire         DRAM_LDQM;
  wire         DRAM_RAS_N;
  wire         DRAM_UDQM;
  wire         DRAM_WE_N;
  wire         FPGA_I2C_SCLK;
  wire         FPGA_I2C_SDAT;
  wire  [7: 0] NAND_DQ;
  wire         NAND_NWP;
  wire         NAND_NWE;
  wire         NAND_ALE;
  wire         NAND_CLE;
  wire         NAND_NCE;
  wire         NAND_NRE;
  wire         NAND_RNB;
  wire [35:15] GPIO_0;
  wire [35: 0] GPIO_1;
  wire [ 6: 0] HEX0;
  wire [ 6: 0] HEX1;
  wire [ 6: 0] HEX2;
  wire [ 6: 0] HEX3;
  wire [ 6: 0] HEX4;
  wire [ 6: 0] HEX5;
  wire         IRDA_RXD;
  wire         IRDA_TXD;
  wire [ 3: 0] KEY;
  wire [ 9: 0] LEDR;
  wire         PS2_CLK;
  wire         PS2_DAT;
  wire         PS2_CLK2;
  wire         PS2_DAT2;
  wire [ 9: 0] SW;
  wire         TD_CLK27;
  wire [ 7: 0] TD_DATA;
  wire         TD_HS;
  wire         TD_RESET_N;
  wire         TD_VS;
  wire [ 7: 0] VGA_B;
  wire         VGA_BLANK_N;
  wire         VGA_CLK;
  wire [ 7: 0] VGA_G;
  wire         VGA_HS;
  wire [ 7: 0] VGA_R;
  wire         VGA_SYNC_N;
  wire         VGA_VS;
  wire [14: 0] HPS_DDR3_ADDR;
  wire [ 2: 0] HPS_DDR3_BA;
  wire         HPS_DDR3_CAS_N;
  wire         HPS_DDR3_CKE;
  wire         HPS_DDR3_CK_N;
  wire         HPS_DDR3_CK_P;
  wire         HPS_DDR3_CS_N;
  wire [ 3: 0] HPS_DDR3_DM;
  wire [31: 0] HPS_DDR3_DQ;
  wire [ 3: 0] HPS_DDR3_DQS_N;
  wire [ 3: 0] HPS_DDR3_DQS_P;
  wire         HPS_DDR3_ODT;
  wire         HPS_DDR3_RAS_N;
  wire         HPS_DDR3_RESET_N;
  wire         HPS_DDR3_RZQ;
  wire         HPS_DDR3_WE_N;
  wire         HPS_ENET_GTX_CLK;
  wire         HPS_ENET_INT_N;
  wire         HPS_ENET_MDC;
  wire         HPS_ENET_MDIO;
  wire         HPS_ENET_RX_CLK;
  wire [ 3: 0] HPS_ENET_RX_DATA;
  wire         HPS_ENET_RX_DV;
  wire [ 3: 0] HPS_ENET_TX_DATA;
  wire         HPS_ENET_TX_EN;
  wire[ 3: 0]  HPS_FLASH_DATA;
  wire         HPS_FLASH_DCLK;
  wire         HPS_FLASH_NCSO;
  wire         HPS_GSENSOR_INT;
  wire [ 1: 0] HPS_GPIO;
  wire         HPS_I2C_CONTROL;
  wire         HPS_I2C1_SCLK;
  wire         HPS_I2C1_SDAT;
  wire         HPS_I2C2_SCLK;
  wire         HPS_I2C2_SDAT;
  wire         HPS_KEY;
  wire         HPS_LED;
  wire         HPS_SD_CLK;
  wire         HPS_SD_CMD;
  wire [ 3: 0] HPS_SD_DATA;
  wire         HPS_SPIM_CLK;
  wire         HPS_SPIM_MISO;
  wire         HPS_SPIM_MOSI;
  wire         HPS_SPIM_SS;
  wire         HPS_UART_RX;
  wire         HPS_UART_TX;
  wire         HPS_CONV_USB_N;
  wire         HPS_USB_CLKOUT;
  wire [ 7: 0] HPS_USB_DATA;
  wire         HPS_USB_DIR;
  wire         HPS_USB_NXT;
  wire         HPS_USB_STP;

  logic clk, rst, rd, wr, cs, doneInt;
  logic [1:0] addr;
  logic [3:0] be;
  logic [31:0] wrData, rdData;
  reg  [8*256:1]           msg;
  integer i;
  integer fails = 0;
  integer compares = 0;
  parameter N = 100;

  logic [7:0] chipID [0:tb.MLC_nand.uut_0.NUM_ID_BYTES-1] = {
    tb.MLC_nand.uut_0.READ_ID_BYTE0,   // Micron Manufacturer ID
    tb.MLC_nand.uut_0.READ_ID_BYTE1,
    tb.MLC_nand.uut_0.READ_ID_BYTE2,
    tb.MLC_nand.uut_0.READ_ID_BYTE3,
    tb.MLC_nand.uut_0.READ_ID_BYTE4,
    tb.MLC_nand.uut_0.READ_ID_BYTE5,
    tb.MLC_nand.uut_0.READ_ID_BYTE6,
    tb.MLC_nand.uut_0.READ_ID_BYTE7
  };

  /****************************************************************************/
  // INSTANTIATE DEVICES
  /****************************************************************************/
  // Instantiate design under test
  DE1_SoC_Computer dut (.*);

  // Instantiate MLC memory model
  // Supports MT29F256G08CBCBB family
  wire NAND_DQS_NO_CONNECT;
  nand_model MLC_nand (
    .Dq_Io    (NAND_DQ),
    .Cle      (NAND_CLE),
    .Ale      (NAND_ALE),
    .Ce_n     (NAND_NCE),
    .Clk_We_n (NAND_NWE),
    .Wr_Re_n  (NAND_NRE),
    .Wp_n     (NAND_NWP),
    .Rb_n     (NAND_RNB),
    .Dqs      (NAND_DQS_NO_CONNECT) // Should only be testing asynchronous mode
  );

  // Model for MT29F8G08ABACA family is available by request only.
  // Get it here if you'd like to go through the NDA process:
  // https://www.micron.com/products/nand-flash/slc-nand/part-catalog/mt29f8g08abacawp-it

  /****************************************************************************/
  // GENERATE CLOCK
  /****************************************************************************/
  initial begin
    clk = 0;
    #5
    forever #5 clk = ~clk;
  end

  // Assign clock
  assign CLOCK_50 = clk;
  // Assign reset
  assign tb.dut.sim_gen.rst = rst;

  /****************************************************************************/
  // TEST
  /****************************************************************************/
  initial begin
    // Initialize
    init_signals();
    reset_system(1'b0); // Assert our reset

    // Wait for NAND to power up
    wait_nand_powerup();

    // Enable NAND chip
    command_write(CTRL_CHIP_ENABLE_CMD);

    // Reset NAND chip
    command_write(NAND_RESET_CMD);

    // Read ID
    command_write(NAND_READ_ID_CMD);
    for (i = 0; i < 6; i = i + 1) begin
        command_read(CTRL_GET_ID_BYTE_CMD, rdData);
        assert_byte(rdData, chipID[i]);
    end

    // Read Parameter Page
    command_write(NAND_READ_PARAMETER_PAGE_CMD);
    for(i = 0; i < 4; i = i + 1) begin
        command_read(CTRL_GET_PARAMETER_PAGE_BYTE_CMD, rdData);
        assert_byte(rdData, tb.MLC_nand.uut_0.onfi_params_array[i]);
    end

    // Get controller status
    command_read(CTRL_GET_STATUS_CMD, rdData);
    assert_bit(rdData[0], 1);

    // Write Enable
    command_write(CTRL_WRITE_ENABLE_CMD);

    // Just doing first 100 addresses
    // Verify NAND's Initial State
    command_write(NAND_READ_PAGE_CMD);
    command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) begin
        command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        assert_byte(rdData, 8'hFF);
    end

    // Write controller pages with known sequence
    command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) begin
        command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, i);
    end
    // Write controller pages to NAND
    command_write(NAND_PAGE_PROGRAM_CMD);

    // Write controller pages with known different sequence
    command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) begin
        command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, 1'b1);
    end
    // Verify controller page is different from nand
    command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) begin
        command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        assert_byte(rdData, 1'b1);
    end

    // Read previously written page from NAND
    command_write(NAND_READ_PAGE_CMD);
    command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) begin
        command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        assert_byte(rdData, i);
    end

    // Erase chip
    command_write(NAND_BLOCK_ERASE_CMD);
    // Verify chip is erased
    command_write(NAND_READ_PAGE_CMD);
    command_write(CTRL_RESET_INDEX_CMD);
    for(i = 0; i < N; i = i + 1) begin
        command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        assert_byte(rdData, 8'hFF);
    end

    repeat (1000) @(posedge clk);
    $display("Test Compares:Failures: %0d:%0d", compares, fails);
    $stop;
  end

  /****************************************************************************/
  // TESTBENCH MISC
  /****************************************************************************/
  initial begin
    // Dump waves
    $timeformat (-9, 3, " ns", 1);
    $dumpfile("dump.vcd");
    $dumpvars();
  end

/******************************************************************************/
// TASKS
/******************************************************************************/
/******************************************************************************/
// CONTROLLER OPERATIONS
/******************************************************************************/
task poll_busy;
    logic [7:0] rddata;
    begin
        _read_status_reg(rddata);
        while(rddata[0] == 1 || rddata[1] == 0) _read_status_reg(rddata);
    end
endtask

task wait_nand_powerup;
    logic [7:0] rddata;
    begin
    // Let nand chip get powered up
    _read_status_reg(rddata);
    while(rddata[1] == 1) _read_status_reg(rddata);
    // Let nand chip get ready
    _read_status_reg(rddata);
    while(rddata[1] == 0) _read_status_reg(rddata);
    end
endtask

task command_write;
    input e_cmd cmd;
    begin
        if(`PRINT_CMDS) print_command(cmd);
        _write_command_reg(cmd);
        poll_busy();
    end
endtask

task command_write_data;
    input e_cmd cmd;
    input [7:0] data;
    begin
        if(`PRINT_CMDS) print_command(cmd);
        _write_data_reg(data);
        _write_command_reg(cmd);
        poll_busy();
    end
endtask

task command_read;
    input e_cmd cmd;
    output [7:0] rddata;
    begin
        if(`PRINT_CMDS) print_command(cmd);
        _write_command_reg(cmd);
        poll_busy();
        _read_data_reg(rddata);
    end
endtask

/******************************************************************************/
// REGISTER ABSTRACTIONS
/******************************************************************************/
task _write_command_reg;
    input [7:0] wrdata;
    begin
    _avalon_write(`CMD_REG, wrdata);
    end
endtask

task _read_command_reg;
    output [7:0] rddata;
    begin
    _avalon_read(`CMD_REG, rddata);
    end
endtask

task _write_data_reg;
    input [31:0] wrdata;
    begin
    _avalon_write(`DATA_REG, wrdata);
    end
endtask

task _read_data_reg;
    output [7:0] rddata;
    begin
    _avalon_read(`DATA_REG, rddata);
    end
endtask

task _read_status_reg;
    output [7:0] rddata;
    begin
    _avalon_read(`STATUS_REG, rddata);
    end
endtask

/******************************************************************************/
// PRIMITIVE AVALON OPERATIONS
// SETUP = 1
/******************************************************************************/
task _avalon_write;
    input [1:0] addr;
    input [7:0] wrdata;
    begin
    tb.dut.sim_gen.addr = addr;
    tb.dut.sim_gen.wr   = 1'b0;
    tb.dut.sim_gen.rd   = 1'b0;
    tb.dut.sim_gen.wrdata = wrdata;
    @(posedge clk)
    tb.dut.sim_gen.wr   = 1'b1;
    @(posedge clk)
    init_signals();
    end
endtask

task _avalon_read;
    input [1:0] addr;
    output [7:0] rddata;
    begin
    tb.dut.sim_gen.addr = addr;
    tb.dut.sim_gen.wr   = 1'b0;
    tb.dut.sim_gen.rd   = 1'b0;
    @(posedge clk)
    tb.dut.sim_gen.rd   = 1'b1;
    @(posedge clk)
    rddata = tb.dut.sim_gen.rddata[7:0];
    init_signals();
    end
endtask

/******************************************************************************/
// TESTBENCH MISC
/******************************************************************************/
task INFO;
   input [256*8:1] msg;
begin
  $display("%m at time %t: %0s", $time, msg);
end
endtask

task reset_system;
    input active_high;
    begin
        rst = active_high;
        repeat (2) @(posedge clk);
        rst = ~active_high;
        $sformat(msg, "Released device reset");
        INFO(msg);
        repeat (1) @(posedge clk);
    end
endtask

task init_signals;
    begin
    tb.dut.sim_gen.addr = 2'h0;
    tb.dut.sim_gen.wr   = 1'b0;
    tb.dut.sim_gen.rd   = 1'b0;
    tb.dut.sim_gen.wrdata = 31'h0;
    end
endtask

task assert_bit;
    input a;
    input b;
    begin
        compares = compares + 1;
        assert(a == b) begin
            if(`PRINT_PASSES) begin
                $sformat(msg, "[PASS] : %0h == %0h", a, b);
                INFO(msg);
            end
        end
        else begin
            $sformat(msg, "[FAIL] : %0h != %0h", a, b);
            INFO(msg);
            fails = fails + 1;
        end
    end
endtask

task assert_byte;
    input [7:0] a;
    input [7:0] b;
    begin
        compares = compares + 1;
        assert(a == b) begin
            if(`PRINT_PASSES) begin
                $sformat(msg, "[PASS] : %0h == %0h", a, b);
                INFO(msg);
            end
        end
        else begin
            $sformat(msg, "[FAIL] : %0h != %0h", a, b);
            INFO(msg);
            fails = fails + 1;
        end
    end
endtask

task print_command;
    input e_cmd cmd;
    begin
        $sformat(msg, "%s", cmd.name());
        INFO(msg);
    end
endtask

endmodule
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

// Nand Avalon Command Macros
`define INTERNAL_RESET_CMD                8'h00
`define NAND_RESET_CMD                    8'h01
`define NAND_READ_PARAMETER_PAGE_CMD      8'h02
`define NAND_READ_ID_CMD                  8'h03
`define NAND_BLOCK_ERASE_CMD              8'h04
`define NAND_READ_STATUS_CMD              8'h05
`define NAND_READ_PAGE_CMD                8'h06
`define NAND_PAGE_PROGRAM_CMD             8'h07
`define CTRL_GET_STATUS_CMD               8'h08
`define CTRL_CHIP_ENABLE_CMD              8'h09
`define CTRL_CHIP_DISABLE_CMD             8'h10
`define CTRL_WRITE_PROTECT_CMD            8'h11
`define CTRL_WRITE_ENABLE_CMD             8'h12
`define CTRL_RESET_INDEX_CMD              8'h13
`define CTRL_GET_ID_BYTE_CMD              8'h14
`define CTRL_GET_PARAMETER_PAGE_BYTE_CMD  8'h15
`define CTRL_GET_DATA_PAGE_BYTE_CMD       8'h16
`define CTRL_SET_DATA_PAGE_BYTE_CMD       8'h17
`define CTRL_GET_CURRENT_ADDRESS_BYTE_CMD 8'h18
`define CTRL_SET_CURRENT_ADDRESS_BYTE_CMD 8'h19
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

  // Instantiate design under test
  DE1_SoC_Computer dut (.*);

  // Instantiate MLC memory model
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

  // SLC Memory model is by request only. Get it here if you'd like to go through the NDA process:
  // https://www.micron.com/products/nand-flash/slc-nand/part-catalog/mt29f8g08abacawp-it

  assign CLOCK_50 = clk;
  assign tb.dut.sim_gen.rst = rst;

  initial begin
    clk = 0;
    #5
  	forever #5 clk = ~clk;
  end

  initial begin
    // Dump waves
    $timeformat (-9, 3, " ns", 1);
    $dumpfile("dump.vcd");
    $dumpvars();
    /******************************************************/
    // Test
    /******************************************************/
    // For nand_avalon
    // Activate signal requires
    //                 __    __    __
    // clk          __|  |__|  |__|
    //
    // addr         --< 01 >< XX >---
    //                       _____
    // pwrite       XX______|     |XX
    //
    // n_busy       XXXXXXXX______XXX
    //
    // prev_addr    --< XX >< 01 >---
    //
    // prev_pwrite  XXXXXXXX______XXX
    //                       _____
    // nactivet     ________|     |__
    //
    // X - Dont Care
    // prev_addr and prev_pwrite are
    // just registered versions of
    // their parents
    //
    // This means to activate the system and "lock in" a command
    // you must read from command register and then write to ANY register
    // Yes, this seems super weird.
    //
    // Not so weird. This seems to indicate the avalon interface must
    // have a SETUP time of 1


    // Initialize
    init_signals();
    reset_system(1'b0); // Assert our reset

    enable_chip();
    wait_nand_powerup();

    nand_reset();
    poll_busy();

    read_id();
    poll_busy();
    read_data();
    read_data();
    read_data();
    read_data();
    read_data();
    poll_busy();

    read_parameter_page();
    poll_busy();

    //$display("i:%0h", clk);
    repeat (1000) @(posedge clk);
    $finish;
  end

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

task poll_busy;
    begin
        read_status();
        while(rdData[0] == 1 || rdData[1] == 0) read_status();
    end
endtask

task wait_nand_powerup;
    begin
    // Let nand chip get powered up
    read_status();
    while(rdData[1] == 1) read_status();
    // Let nand chip get ready
    read_status();
    while(rdData[1] == 0) read_status();
    end
endtask

// Represents basic avalon interface
// operations
// SETUP = 1
task avalon_write;
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

// Represents basic avalon interface
// operations
// SETUP = 1
task avalon_read;
    input [1:0] addr;
    begin
    tb.dut.sim_gen.addr = addr;
    tb.dut.sim_gen.wr   = 1'b0;
    tb.dut.sim_gen.rd   = 1'b0;
    @(posedge clk)
    tb.dut.sim_gen.rd   = 1'b1;
    rdData = tb.dut.sim_gen.rddata;
    @(posedge clk)
    init_signals();
    end
endtask

task write_command;
    input [7:0] wrdata;
    begin
    avalon_write(`CMD_REG, wrdata);
    end
endtask

task read_command;
    begin
    avalon_read(`CMD_REG);
    end
endtask

task write_data;
    input [31:0] wrdata;
    begin
    avalon_write(`DATA_REG, wrdata);
    end
endtask

task read_data;
    begin
    avalon_read(`DATA_REG);
    end
endtask

task read_status;
    begin
    avalon_read(`STATUS_REG);
    end
endtask

task nand_reset;
    begin
        $sformat(msg, "NAND_RESET_CMD");
        INFO(msg);
        write_command(`NAND_RESET_CMD);
    end
endtask

task read_parameter_page;
    begin
        $sformat(msg, "NAND_READ_PARAMETER_PAGE_CMD");
        INFO(msg);
        write_command(`NAND_READ_PARAMETER_PAGE_CMD);
    end
endtask

task read_id;
    begin
        $sformat(msg, "NAND_READ_ID_CMD");
        INFO(msg);
        write_command(`NAND_READ_ID_CMD);
    end
endtask

task enable_chip;
    begin
        $sformat(msg, "CTRL_CHIP_ENABLE_CMD");
        INFO(msg);
        write_command(`CTRL_CHIP_ENABLE_CMD);
    end
endtask





endmodule
// Testbench
`timescale 1ns/1ps
`define x8
`define SHORT_RESET
`define CLASSB
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

  // Instantiate design under test
  DE1_SoC_Computer dut (.*);

  // Instantiate MLC memory model
  wire NAND_ENO;
  nand_model MLC_nand (
    .Dq_Io    (NAND_DQ),
    .Cle      (NAND_CLE),
    .Ale      (NAND_ALE),
    .Ce_n     (NAND_NCE),
    .Clk_We_n (NAND_NWE),
    .Wr_Re_n  (NAND_NRE),
    //.Re_c     (),
    .Wp_n     (NAND_NWP),
    .Rb_n     (NAND_RNB)
    //.Pre      (),
    //.Lock     (),
    //.Dqs      (),
    //.Dqs_c    (),
    //.ML_rdy   (),
    //.Rb_lun_n (),
    //.PID      (),
    //.ENi      (1'b0),    // NC
    //.ENo      (NAND_ENO) // NC
  );

  // https://www.micron.com/products/nand-flash/slc-nand/part-catalog/mt29f8g08abacawp-it
  // SLC Memory model is under NDA. Get it here if you'd like to go through the NDA process:

  assign CLOCK_50 = clk;
  assign tb.dut.sim_gen.rst = rst;
  assign rdData = tb.dut.sim_gen.rddata;

  initial begin
    clk = 0;
    #5
  	forever #5 clk = ~clk;
  end

  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars();

    // Initialize
    force tb.dut.sim_gen.addr = 2'h0;
    force tb.dut.sim_gen.wr   = 1'b0;
    force tb.dut.sim_gen.rd   = 1'b0;
    force tb.dut.sim_gen.wrdata = 31'h0;
    release_signals();
    reset_system(1'b0);

    // Test

    // For nand_avalon
    // Activate signal requires
    //                 __    __    __
    // clk          __|  |__|  |__|
    //                |     |     |
    // addr         --< 01 >< XX >---
    //                |     |     |
    // pwrite       XX______XXXXXXXXX
    //                |     |     |
    // prev_addr    --< XX >< 01 >---
    //                |     |     |
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
    // you must read from register 01 and then write to ANY register
    // Yes, this seems super weird.

    write_command(8'h2);
    //$display("i:%0h", clk);

    repeat (20) @(posedge clk);
    $finish;
  end

task reset_system;
    input active_high;
    begin
        rst = active_high;
        repeat (2) @(posedge clk);
        $display("Release reset.");
        rst = ~active_high;
        repeat (1) @(posedge clk);
    end
endtask

task write_command;
    input [7:0] wrdata;
    begin
    force tb.dut.sim_gen.addr = 2'h1;
    force tb.dut.sim_gen.wr   = 1'b1;
    force tb.dut.sim_gen.rd   = 1'b0;
    force tb.dut.sim_gen.wrdata = {{24{1'b0}},wrdata};
    @(posedge clk);
    force tb.dut.sim_gen.wr   = 1'b0;
    release_signals();
    end
endtask

task read_command;
    begin
    tb.dut.sim_gen.addr = 2'h1;
    tb.dut.sim_gen.wr   = 1'b0;
    tb.dut.sim_gen.rd   = 1'b1;
    @(posedge clk);
    end
endtask

task write_data;
    input [31:0] wrdata;
    begin
    tb.dut.sim_gen.addr = 2'h0;
    tb.dut.sim_gen.wr   = 1'b1;
    tb.dut.sim_gen.rd   = 1'b0;
    tb.dut.sim_gen.wrdata = wrdata;
    @(posedge clk);
    end
endtask

task read_data;
    begin
    tb.dut.sim_gen.addr = 2'h0;
    tb.dut.sim_gen.wr   = 1'b0;
    tb.dut.sim_gen.rd   = 1'b1;
    @(posedge clk);
    end
endtask

task read_status;
    begin
    tb.dut.sim_gen.addr = 2'h2;
    tb.dut.sim_gen.wr   = 1'b0;
    tb.dut.sim_gen.rd   = 1'b1;
    @(posedge clk);
    end
endtask

task release_signals;
    begin
    #1
    release tb.dut.sim_gen.addr;
    release tb.dut.sim_gen.wr;
    release tb.dut.sim_gen.rd;
    release tb.dut.sim_gen.wrdata;
    end
endtask

endmodule
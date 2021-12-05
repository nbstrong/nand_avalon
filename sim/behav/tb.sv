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

`define PRINT_CMDS 1
`define PRINT_PASSES 1

`define RESET_ACTIVE_HIGH 0

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
    reg [8*256:1]   msg;
    integer         i = 0, fails = 0, compares = 0, N = 100;

    logic           clk;
    logic           rst;
    logic           resetn;
    logic [31: 0]   readdata;
    logic [31: 0]   writedata;
    logic           pread;
    logic           pwrite;
    logic [ 1: 0]   address;
    logic           nand_cle;
    logic           nand_ale;
    logic           nand_nwe;
    logic           nand_nwp;
    logic           nand_nce;
    logic           nand_nre;
    logic           nand_rnb;
    wire  [15: 0]   nand_data;

    logic [7:0] chipID [0:nand_0.uut_0.NUM_ID_BYTES-1] = {
        nand_0.uut_0.READ_ID_BYTE0, // Micron Manufacturer ID
        nand_0.uut_0.READ_ID_BYTE1,
        nand_0.uut_0.READ_ID_BYTE2,
        nand_0.uut_0.READ_ID_BYTE3,
        nand_0.uut_0.READ_ID_BYTE4,
        nand_0.uut_0.READ_ID_BYTE5,
        nand_0.uut_0.READ_ID_BYTE6,
        nand_0.uut_0.READ_ID_BYTE7
    };

    logic [7:0] rdData;

    /****************************************************************************/
    // INSTANTIATE DEVICES
    /****************************************************************************/
    // Instantiate design under test
    nand_avalon dut (
        .clk      (clk      ),
        .resetn   (resetn   ),
        .readdata (readdata ),
        .writedata(writedata),
        .pread    (pread    ),
        .pwrite   (pwrite   ),
        .address  (address  ),
        .nand_cle (nand_cle ),
        .nand_ale (nand_ale ),
        .nand_nwe (nand_nwe ),
        .nand_nwp (nand_nwp ),
        .nand_nce (nand_nce ),
        .nand_nre (nand_nre ),
        .nand_rnb (nand_rnb ),
        .nand_data(nand_data));

    // Instantiate MLC memory model
    // Supports MT29F256G08CBCBB family
    wire NAND_DQS_NO_CONNECT;
    nand_model nand_0 (
        .Dq_Io    (nand_data[7:0]),
        .Cle      (nand_cle ),
        .Ale      (nand_ale ),
        .Ce_n     (nand_nce ),
        .Clk_We_n (nand_nwe ),
        .Wr_Re_n  (nand_nre ),
        .Wp_n     (nand_nwp ),
        .Rb_n     (nand_rnb ),
        .Dqs      (NAND_DQS_NO_CONNECT)); // Should only be testing asynchronous mode

    // Model for MT29F8G08ABACA family is available by request only.
    // Get it here if you'd like to go through the NDA process:
    // https://www.micron.com/products/nand-flash/slc-nand/part-catalog/mt29f8g08abacawp-it

    /****************************************************************************/
    // GENERATE CLOCK
    /****************************************************************************/
    initial begin
        clk = 0;
        #5ns
        forever #5ns clk = ~clk;
    end

    // Assign reset
    assign resetn = rst;

    /****************************************************************************/
    // TEST
    /****************************************************************************/
    initial begin
        // Initialize
        init_signals();
        reset_system(`RESET_ACTIVE_HIGH); // Assert our reset

        // Wait for NAND to power up
        _wait_nand_powerup();

        // Enable NAND chip
        _command_write(CTRL_CHIP_ENABLE_CMD);

        // Reset NAND chip
        _command_write(NAND_RESET_CMD);

        // Read ID
        _command_write(NAND_READ_ID_CMD);
        for (i = 0; i < 6; i = i + 1) begin
            _command_read(CTRL_GET_ID_BYTE_CMD, rdData);
            compare_byte(rdData, chipID[i]);
        end

        // Read Parameter Page
        _command_write(NAND_READ_PARAMETER_PAGE_CMD);
        for(i = 0; i < 4; i = i + 1) begin
            _command_read(CTRL_GET_PARAMETER_PAGE_BYTE_CMD, rdData);
            compare_byte(rdData, nand_0.uut_0.onfi_params_array[i]);
        end

        // Get controller status
        _command_read(CTRL_GET_STATUS_CMD, rdData);
        compare_bit(rdData[0], 1);

        // Write Enable
        _command_write(CTRL_WRITE_ENABLE_CMD);

        // Just doing first 100 addresses
        // Verify NAND's Initial State
        _command_write(NAND_READ_PAGE_CMD);
        _command_write(CTRL_RESET_INDEX_CMD);
        for(i = 0; i < N; i = i + 1) begin
            _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
            compare_byte(rdData, 8'hFF);
        end

        // Write controller pages with known sequence
        _command_write(CTRL_RESET_INDEX_CMD);
        for(i = 0; i < N; i = i + 1) begin
            _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, i);
        end
        // Write controller pages to NAND
        _command_write(NAND_PAGE_PROGRAM_CMD);

        // Write controller pages with known different sequence
        _command_write(CTRL_RESET_INDEX_CMD);
        for(i = 0; i < N; i = i + 1) begin
            _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, 1'b1);
        end
        // Verify controller page is different from nand
        _command_write(CTRL_RESET_INDEX_CMD);
        for(i = 0; i < N; i = i + 1) begin
            _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
            compare_byte(rdData, 1'b1);
        end

        // Read previously written page from NAND
        _command_write(NAND_READ_PAGE_CMD);
        _command_write(CTRL_RESET_INDEX_CMD);
        for(i = 0; i < N; i = i + 1) begin
            _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
            compare_byte(rdData, i);
        end

        // Erase chip
        _command_write(NAND_BLOCK_ERASE_CMD);
        // Verify chip is erased
        _command_write(NAND_READ_PAGE_CMD);
        _command_write(CTRL_RESET_INDEX_CMD);
        for(i = 0; i < N; i = i + 1) begin
            _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
            compare_byte(rdData, 8'hFF);
        end

        repeat (1000) @(posedge clk);
        $display("Test Compares:Failures: %0d:%0d", compares, fails);
        $finish;
    end

    /****************************************************************************/
    // TESTBENCH MISC
    /****************************************************************************/
    initial begin
        $timeformat (-9, 3, " ns", 1);
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

    task _wait_nand_powerup;
        logic [7:0] rddata;
        begin
        // Let nand chip get powered up
        _read_status_reg(rddata);
        while(rddata[1] == 1) _read_status_reg(rddata);
        poll_busy();
        end
    endtask

    task _command_write;
        input e_cmd cmd;
        begin
            if(`PRINT_CMDS) print_command(cmd);
            _write_command_reg(cmd);
            poll_busy();
        end
    endtask

    task _command_write_data;
        input e_cmd cmd;
        input [7:0] data;
        begin
            if(`PRINT_CMDS) print_command(cmd);
            _write_data_reg(data);
            _write_command_reg(cmd);
            poll_busy();
        end
    endtask

    task _command_read;
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
    // HOLD = 1
    /******************************************************************************/
    task _avalon_write;
        input [1:0] addr;
        input [7:0] wrdata;
        begin
        address   = addr;
        pwrite    = 1'b0;
        pread     = 1'b1;
        writedata = wrdata;
        @(posedge clk)
        pwrite    = 1'b1;
        @(posedge clk)
        init_signals();
        end
    endtask

    task _avalon_read;
        input [1:0] addr;
        output [7:0] rddata;
        begin
        address  = addr;
        pwrite   = 1'b1;
        pread    = 1'b0;
        @(posedge clk)
        rddata = readdata[7:0];
        init_signals();
        end
    endtask

    task init_signals;
        begin
        address   = 2'hX;
        pwrite    = 1'bX;
        pread     = 1'bX;
        writedata = 31'hX;
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

    task compare_bit;
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

    task compare_byte;
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
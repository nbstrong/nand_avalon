// Testbench
`timescale 1ns / 1ps

// Memory Model Specific Macros
`define x8
`define V33
//`define SHORT_RESET
`define CLASSB

// Nand Avalon Address Macros
`define DATA_REG 3'h0
`define CMD_REG  3'h1
`define STATUS_REG 3'h2
`define TIME_REG 3'h3
`define CNTRL_REG 3'h4
`define ESTATUS_REG 3'h5
`define DELAY_REG 3'h6

`define PRINT_CMDS 0
`define PRINT_PASSES 0

`define RESET_ACTIVE_HIGH 0

`define PAGELEN 4320 // Number of bytes per page
// `define BLOCKLEN 1024 // Number of pages per block
// `define DEVLEN 2192   // Number of blocks per device

`define NUM_COLS 10

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
    integer         i = 0, j = 0, fails = 0, compares = 0;

    typedef logic [7:0] page [0:18591];
    page            page_buf;

    logic           clk;
    logic           rst;
    logic           resetn;
    logic [31: 0]   readdata;
    logic [31: 0]   writedata;
    logic           pread;
    logic           pwrite;
    logic [ 2: 0]   address;
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

    logic [31:0] rdData;

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
        init_nand();
        $sformat(msg, "NAND Initialization Complete");
        INFO(msg);

        $sformat(msg, "First Page Test");
        INFO(msg);
        page_buf = memset(page_buf, 1, `NUM_COLS);
        simple_page_test(page_buf, gen_address(0, 0, 0), `NUM_COLS);

        $sformat(msg, "Interrupted Page Program Test");
        INFO(msg);
        _write_delay_reg(31'h10E13);
        _read_delay_reg(rdData);
        _write_control_reg(31'h1);
        _read_control_reg(rdData);
        page_buf = memset(page_buf, 1, `NUM_COLS);
        write_page(page_buf, gen_address(0, 1, 0));

        _command_write(NAND_READ_PARAMETER_PAGE_CMD);

        $sformat(msg, "Second Page Test");
        INFO(msg);
        page_buf = memset(page_buf, 4, `NUM_COLS);
        simple_page_test(page_buf, gen_address(0, 2, 0), `NUM_COLS);


        // page_buf = memset(page_buf, 0, `PAGELEN);

        // for (j = 0; j < 1; j = j + 1) begin
        //   for (i = 0; i < 1; i = i + 1) begin
        //     page_buf = memset(page_buf, i, `NUM_COLS);
        //     simple_page_test(page_buf, gen_address(j, i, 0), `NUM_COLS);
        //   end
        // end

        // for (j = 0; j < 10; j = j + 1) begin
        //   for (i = 0; i < 10; i = i + 1) begin
        //     read_page(page_buf, gen_address(j, i, 0));
        //   end
        // end

        // // Wait for NAND to power up
        // _wait_nand_powerup();

        // // Enable NAND chip
        // _command_write(CTRL_CHIP_ENABLE_CMD);

        // // Reset NAND chip
        // _command_write(NAND_RESET_CMD);

        // // Read ID
        // _command_write(NAND_READ_ID_CMD);
        // for (i = 0; i < 6; i = i + 1) begin
        //     _command_read(CTRL_GET_ID_BYTE_CMD, rdData);
        //     compare_byte(rdData, chipID[i]);
        // end

        // // Read Parameter Page
        // _command_write(NAND_READ_PARAMETER_PAGE_CMD);
        // for(i = 0; i < 4; i = i + 1) begin
        //     _command_read(CTRL_GET_PARAMETER_PAGE_BYTE_CMD, rdData);
        //     compare_byte(rdData, nand_0.uut_0.onfi_params_array[i]);
        // end

        // // Get controller status
        // _command_read(CTRL_GET_STATUS_CMD, rdData);
        // compare_bit(rdData[0], 1);

        // // Write Enable
        // _command_write(CTRL_WRITE_ENABLE_CMD);

        // Just doing first 100 addresses
        // Verify NAND's Initial State
        // _command_write(NAND_READ_PAGE_CMD);
        // _command_write(CTRL_RESET_INDEX_CMD);
        // for(i = 0; i < N; i = i + 1) begin
        //     _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        //     compare_byte(rdData, 8'hFF);
        // end

        // // Write controller pages with known sequence
        // _command_write(CTRL_RESET_INDEX_CMD);
        // for(i = 0; i < N; i = i + 1) begin
        //     _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, i);
        // end
        // // Write controller pages to NAND
        // _command_write(NAND_PAGE_PROGRAM_CMD);

        // // Write controller pages with known different sequence
        // _command_write(CTRL_RESET_INDEX_CMD);
        // for(i = 0; i < N; i = i + 1) begin
        //     _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, 1'b1);
        // end
        // // Verify controller page is different from nand
        // _command_write(CTRL_RESET_INDEX_CMD);
        // for(i = 0; i < N; i = i + 1) begin
        //     _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        //     compare_byte(rdData, 1'b1);
        // end

        // // Read previously written page from NAND
        // _command_write(NAND_READ_PAGE_CMD);
        // _command_write(CTRL_RESET_INDEX_CMD);
        // for(i = 0; i < N; i = i + 1) begin
        //     _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        //     compare_byte(rdData, i);
        // end

        // // Erase chip
        // _command_write(NAND_BLOCK_ERASE_CMD);
        // // Verify chip is erased
        // _command_write(NAND_READ_PAGE_CMD);
        // _command_write(CTRL_RESET_INDEX_CMD);
        // for(i = 0; i < N; i = i + 1) begin
        //     _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, rdData);
        //     compare_byte(rdData, 8'hFF);
        // end

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
    // TESTS
    /******************************************************************************/
    task simple_page_test;
        input page page_buf;
        input int address;
        input int num_cols;
        page exp_page;
        int i;
        int j;
        int col_addr;
        begin
            exp_page = page_buf;
            write_page(page_buf, address);
            page_buf = memset(page_buf, 0, `NUM_COLS);
            read_page(page_buf, address);

            for(col_addr = 0;col_addr < num_cols;col_addr++) begin
               compare_byte(exp_page[col_addr], page_buf[col_addr]);
            end
        end
    endtask

    /******************************************************************************/
    // CONTROLLER OPERATIONS
    /******************************************************************************/
    task init_nand;
        begin
            _command_write(INTERNAL_RESET_CMD);
            _command_write(CTRL_CHIP_ENABLE_CMD);
            _wait_nand_powerup();
            _command_write(NAND_RESET_CMD);
            _command_write(NAND_READ_ID_CMD);
            repeat (200) @(posedge clk); // 200 cycle delay to make up for hardware t_RHW violation
            _command_write(NAND_READ_PARAMETER_PAGE_CMD);
            _command_write(CTRL_RESET_INDEX_CMD);
            _command_write(CTRL_WRITE_ENABLE_CMD);
            _command_read(CTRL_GET_STATUS_CMD, rdData);
        end
    endtask

    task write_page;
        input page page_buf;
        input int address;
        begin
            _set_address(address);
            _write_page(page_buf);
        end
    endtask

    task _write_page;
        input page page_buf;
        int col_addr;
        begin
            _command_write(CTRL_RESET_INDEX_CMD);
            for(col_addr = 0;col_addr < `PAGELEN;col_addr++) begin
                _command_write_data(CTRL_SET_DATA_PAGE_BYTE_CMD, page_buf[col_addr]);
            end
            _command_write(NAND_PAGE_PROGRAM_CMD);
        end
    endtask

    task read_page;
        output page page_buf;
        input int address;
        begin
        _set_address(address);
        _read_page(page_buf);
        end
    endtask

    task _read_page;
        output page page_buf;
        int col_addr;
        page tmp_page;
        begin
            _command_write(NAND_READ_PAGE_CMD);
            _command_write(CTRL_RESET_INDEX_CMD);
            for(col_addr = 0;col_addr < `PAGELEN;col_addr++) begin
                _command_read(CTRL_GET_DATA_PAGE_BYTE_CMD, tmp_page[col_addr]);
            end
            page_buf = tmp_page;
        end
    endtask

    task _set_address;
        input logic [8*5:0] addr;
        int i;
        begin
            _command_write(CTRL_RESET_INDEX_CMD);
            for(i = 0;i < 5;i++) begin
                _command_write_data(CTRL_SET_CURRENT_ADDRESS_BYTE_CMD, ((addr >> (i*8)) & 8'hFF));
            end
        end
    endtask

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
        repeat (11100) @(posedge clk);
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
        input [31:0] wrdata;
        begin
        _avalon_write(`CMD_REG, wrdata);
        end
    endtask

    task _read_command_reg;
        output [31:0] rddata;
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
        output [31:0] rddata;
        begin
        _avalon_read(`DATA_REG, rddata);
        end
    endtask

    task _read_status_reg;
        output [31:0] rddata;
        begin
        _avalon_read(`STATUS_REG, rddata);
        end
    endtask

    task _read_time_reg;
        output [31:0] rddata;
        begin
        _avalon_read(`TIME_REG, rddata);
        end
    endtask

    task _write_control_reg;
        input [31:0] wrdata;
        begin
        _avalon_write(`CNTRL_REG, wrdata);
        end
    endtask

    task _read_control_reg;
        output [31:0] rddata;
        begin
        _avalon_read(`CNTRL_REG, rddata);
        end
    endtask

    task _read_exten_status_reg;
        output [31:0] rddata;
        begin
        _avalon_read(`ESTATUS_REG, rddata);
        end
    endtask

    task _write_delay_reg;
        input [31:0] wrdata;
        begin
        _avalon_write(`DELAY_REG, wrdata);
        end
    endtask

    task _read_delay_reg;
        output [31:0] rddata;
        begin
        _avalon_read(`DELAY_REG, rddata);
        end
    endtask

    /******************************************************************************/
    // PRIMITIVE AVALON OPERATIONS
    // HOLD = 1
    /******************************************************************************/
    task _avalon_write;
        input [2:0] addr;
        input [31:0] wrdata;
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
        input [2:0] addr;
        output [31:0] rddata;
        begin
        address  = addr;
        pwrite   = 1'b1;
        pread    = 1'b0;
        @(posedge clk)
        rddata = readdata[31:0];
        init_signals();
        end
    endtask

    task init_signals;
        begin
        address   = 3'hX;
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

    function int gen_address(int block_idx, int page_idx, int col_idx);
        return (block_idx << 24 | page_idx << 16 | col_idx);
    endfunction

    function page memset (page page_buf, int value, int length);
    // Returns a page with length entries set to value
        int col_addr;
        for(col_addr = 0;col_addr < length;col_addr++) begin
            page_buf[col_addr] = value;
        end
        return page_buf;
    endfunction

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

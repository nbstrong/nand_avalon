/*******************************************************************************/
// Design: GCD Calculator Avalon Slave
//  * Wraps NIOS2 GCD Custom Instruction hardware with an Avalon compliant
//    interface. Design supports auto-inferring of interface through
//    Quartus Component Designer.
// Author: Nicholas Strong
/*******************************************************************************/
module gcd_avalon (
        input  logic [1:0]  avs_s0_address,    //   avs_s0.address
        input  logic        avs_s0_read,       //         .read
        output logic [31:0] avs_s0_readdata,   //         .readdata
        input  logic        avs_s0_write,      //         .write
        input  logic [31:0] avs_s0_writedata,  //         .writedata
        output logic        ins_irq0_irq,      //  ins_irq.irq0
        input  logic        csi_clk,           //    clock.clk
        input  logic        rsi_reset          //    reset.reset
    );

    localparam   OP_A = 0;
    localparam   OP_B = 1;
    localparam RESULT = 2;
    localparam STATUS = 3;

    logic [31:0] from_reg [0:3];
    logic [31:0] to_reg [0:3]; // cant do from_reg, to_reg - simulation warnings
    logic [31:0] result, status;
    logic local_write [0:3];
    logic wrInt, done, doneSB, intClr;

    assign to_reg[  OP_A] = (avs_s0_address == OP_A) ? avs_s0_writedata : 32'h0;
    assign to_reg[  OP_B] = (avs_s0_address == OP_B) ? avs_s0_writedata : 32'h0;
    assign to_reg[RESULT] = result;
    assign to_reg[STATUS] = {{31{1'b0}},doneSB};

    assign local_write[  OP_A] = (avs_s0_address == OP_A) ? avs_s0_write : 1'b0;
    assign local_write[  OP_B] = (avs_s0_address == OP_B) ? avs_s0_write : 1'b0;
    assign local_write[RESULT] = done;
    assign local_write[STATUS] = 1'b1;

    // 32 Bit Registers
    // module FF (clk, reset, en, d, q);
    FF #(32) GCD_A (csi_clk, rsi_reset, local_write[  OP_A], to_reg[  OP_A], from_reg[  OP_A]);
    FF #(32) GCD_B (csi_clk, rsi_reset, local_write[  OP_B], to_reg[  OP_B], from_reg[  OP_B]);
    FF #(32) GCD_C (csi_clk, rsi_reset, local_write[RESULT], to_reg[RESULT], from_reg[RESULT]);
    FF #(32) GCD_S (csi_clk, rsi_reset, local_write[STATUS], to_reg[STATUS], from_reg[STATUS]);

    assign avs_s0_readdata = avs_s0_read ? from_reg[avs_s0_address] : 32'h0;

    // Set Reset FF
    // module set_reset(clk, clk_en, reset, en, clr, out);
    set_reset SR (csi_clk, 1'b1, rsi_reset, done, local_write[OP_B], doneSB);

    // Flip Flops
    // module FF (clk, reset, en, d, q);
    FF FF0 (csi_clk, rsi_reset, 1'b1, local_write[OP_B], wrInt);

    // GCD Custom Instruction
    // module gcd_ci(clk, reset, clk_en, start, dataa, datab, done, result);
    gcd_ci GCD (
        .clk   (csi_clk),
        .reset (rsi_reset),
        .clk_en(1'b1),
        .start (wrInt),
        .dataa (from_reg[OP_A]),
        .datab (from_reg[OP_B]),
        .done  (done),
        .result(result));

    // Done Interrupt
    // module set_reset(clk, clk_en, reset, en, clr, out);
    set_reset D_INT (csi_clk, 1'b1, rsi_reset, done, intClr, ins_irq0_irq);
    assign intClr = (avs_s0_read & ((avs_s0_address == STATUS))) ? 1'b1 : 1'b0;

endmodule
/**endmodule********************************************************************/


/*******************************************************************************/
// GCD Custom Instruction
// * Implements Euclid's algorithm via subtraction
/*******************************************************************************/
module gcd_ci(clk, reset, clk_en, start, dataa, datab, done, result);
    input logic clk;
    input logic reset;
    input logic clk_en;
    input logic start;
    input logic [31:0] dataa;
    input logic [31:0] datab;
    output logic done;
    output logic [31:0] result;

    logic unsigned [31:0] a;
    logic unsigned [31:0] b;

    // Done internal and edge detect is just done because
    // the custom instruction protocol wants a pulse.
    logic done_internal;
    edge_detect ED (clk, clk_en, reset, done_internal, done);

    always @(posedge clk)
    begin
        if (reset) begin
        done_internal <=  1'b1;
        a             <= 32'hDEADDEAD;
        b             <= 32'hDEADDEAD;
        result        <= 32'hDEADDEAD;
        end
        else begin
            if(clk_en) begin
                if (start) begin
                    done_internal <= 1'b0;
                    a             <= dataa;
                    b             <= datab;
                end
                else if (!done_internal) begin
                    if (b == 32'h0) begin
                        done_internal <= 1'b1;
                        result        <= a;
                    end
                    else if (a > b) begin
                        a <= a - b;
                    end
                    else begin
                        b <= b - a;
                    end
                end
            end
        end
    end
endmodule
/**endmodule********************************************************************/


/*******************************************************************************/
// Edge Detect
// * Supports rising and falling edges
// * May produce incorrect edges off reset.
// * TODO: Add parameterized initial value.
// * TODO: Add logic to prevent reset edges (hint: xor)
/*******************************************************************************/
module edge_detect #(parameter RISING=1)(clk, clk_en, reset, in, e);
    input  logic clk;
    input  logic clk_en;
    input  logic reset;
    input  logic in;
    output logic e;

    reg tmp;

    always @(posedge clk)
    begin
        if (reset) // Synchronous reset when reset goes high
            tmp <= in;
        else begin
            if (clk_en)
                tmp <= in;
        end
    end

    assign e = RISING ? (~tmp & in) : (tmp & ~in);
endmodule
/**endmodule********************************************************************/


/*******************************************************************************/
// Set Reset FF
// * Also called a sticky bit
// * Intended to be used for custom instruction, thus the clk_en. Was not.
/*******************************************************************************/
module set_reset(clk, clk_en, reset, en, clr, out);
    input  logic clk;
    input  logic clk_en;
    input  logic reset;
    input  logic en;
  	input  logic clr;
    output logic out;

    always @(posedge clk)
    begin
        if (reset) // Synchronous reset when reset goes high
            out <= 1'b0;
        else begin
            if (clk_en & en)
                out <= 1'b1;
            else if (clk_en & clr)
                out <= 1'b0;
        end
    end
endmodule
/**endmodule********************************************************************/


/*******************************************************************************/
 // Flip Flop
 // * Width customizable flip flop with en
 // * TODO: Add parameterized initial value.
 /*******************************************************************************/
module FF (clk, reset, en, d, q);
    parameter WIDTH = 1;
    input  logic clk;
    input  logic reset;
    input  logic en;
    input  logic [WIDTH-1:0] d;
    output logic [WIDTH-1:0] q;


    always @(posedge clk)
    begin
        if (reset)
            q <= 0;
        else if (en)
            q <= d;
        else
            q <= q;
    end
endmodule
/**endmodule********************************************************************/

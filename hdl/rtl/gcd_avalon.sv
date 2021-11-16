module gcd_avalon(clock, reset, address, readdata, writedata, read, write, byteenable, chipselect);
    input  logic clock, reset, read, write, chipselect;
    input  logic [ 1:0] address;
    input  logic [ 3:0] byteenable;
    input  logic [31:0] writedata;
    output logic [31:0] readdata;

    logic [31:0] rdData [0:3];
    logic [31:0] result;
    logic [31:0] status;
    logic [15:0] be;
    logic [3:0]  byteenable_internal;
    logic wrInt, wrIntR;
    logic done, doneR;
    logic doneSB;

    // 32 Bit Registers
    // module reg32 (clock, reset, D, byteenable, Q);
    reg32 GCD_A(clock, reset, writedata,                  be[3:0], rdData[0]); // OP_A
    reg32 GCD_B(clock, reset, writedata,                  be[7:4], rdData[1]); // OP_B
    reg32 GCD_C(clock, reset,    result,                {4{done}}, rdData[2]); // RESULT
    reg32 GCD_S(clock, reset,    status, ({4{doneR}}|{4{wrIntR}}), rdData[3]); // STATUS

    assign be       = (chipselect & write) ? (byteenable << address*4) : 16'h0;
    assign readdata = rdData[address];
    assign status   = {{31{1'b0}},doneSB};

    // Edge Detect
    // module edge_detect #(parameter RISING=1)(clk, clk_en, reset, in, e);
    edge_detect WR (clock, 1'b1, reset, |be[7:4], wrInt);

    // Set Reset FF
    // module set_reset(clk, clk_en, reset, en, clr, out);
    set_reset SR (clock, 1'b1, reset, done, wrInt, doneSB);

    // Flip Flops
    // module FF #(parameter WIDTH=1)(clk, reset, d, q);
    FF FF0 (clock, reset, wrInt, wrIntR);
    FF FF1 (clock, reset, done, doneR);

    // GCD Custom Instruction
    // module gcd_ci(clk, reset, clk_en, start, dataa, datab, done, result);
    gcd_ci GCD (
        .clk   (clock),
        .reset (reset),
        .clk_en(1'b1),
        .start (wrIntR),
        .dataa (rdData[0]),
        .datab (rdData[1]),
        .done  (done),
        .result(result));

endmodule

// GCD Custom Instruction
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
                    //$display("a:%0d, b:%0d result:%0h done:%0h",a, b, result, done);
                end
            end
        end
    end
endmodule

// 32 Bit Register
module reg32 (clock, reset, D, byteenable, Q);
    input  logic clock, reset;
    input  logic [3:0] byteenable;
    input  logic [31:0] D;
    output logic [31:0] Q;

    always@(posedge clock) begin
        if (reset)
            Q <= 32'b0;
        else begin
            // Enable writing to each byte separately
            if (byteenable[0]) Q[7:0]   <= D[7:0];
            if (byteenable[1]) Q[15:8]  <= D[15:8];
            if (byteenable[2]) Q[23:16] <= D[23:16];
            if (byteenable[3]) Q[31:24] <= D[31:24];
        end
    end
endmodule

// Edge Detect
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

// Set Clear FF
module set_reset(clk, clk_en, reset, en, clr, out);
    input  clk;
    input  clk_en;
    input  reset;
    input  en;
  	input  clr;
    output reg out;

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

 // Flip Flop
module FF #(parameter WIDTH=1)(clk, reset, d, q);
    input  logic clk;
    input  logic reset;
    input  logic [WIDTH-1:0] d;
    output logic [WIDTH-1:0] q;

    always @(posedge clk)
    begin
        if (reset)
            q <= 0;
        else
            q <= d;
    end
endmodule


package gcd_pack;


endpackage

// Edge Detect
module edge_detect #(parameter RISING=1)
    (clk, clk_en, reset, in, e);
    input  clk;
    input  clk_en;
    input  reset;
    input  in;
    output e;

    reg tmp;

    always @(posedge clk)
    begin
        if (reset) // Synchronous reset when reset goes high
            tmp <= 1'b0;
        else begin
            if (clk_en)
                tmp <= in;
        end
    end

    assign e = RISING ? (~tmp & in) : (tmp & ~in);
endmodule

// Set Clear FF
module set_reset
  (clk, clk_en, reset, en, clr, out);
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
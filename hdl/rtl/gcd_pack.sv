package gcd_pack;


endpackage

// Edge Detect
module edge_detect #(parameter RISING=1)
    (clk, rst, in, e);
    input  clk;
    input  rst;
    input  in;
    output e;

    reg tmp;

    always @(posedge clk or posedge rst)
    begin
        if (rst) begin
            // Asynchronous reset when reset goes high
            tmp <= 1'b0;
        end else begin
            tmp <= in;
        end
    end

    assign e = RISING ? (~tmp & in) : (tmp & ~in);
endmodule

// Set Clear FF
module set_reset
  (clk, rst, en, clr, out);
    input  clk;
    input  rst;
    input  en;
  	input  clr;
    output reg out;

    always @(posedge clk or posedge rst)
    begin
        if (rst) begin
            // Asynchronous reset when reset goes high
            out <= 1'b0;
        end else begin
            // Set has priority
            if (en) begin
                out <= 1'b1;
            end
            else if (clr) begin
                out <= 1'b0;
            end
        end
    end
endmodule
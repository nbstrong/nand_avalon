import gcd_pack::*;

module gcd_ci(
    input clk,
    input rst,
    input clk_en,
    input start,
    input [31:0] dataa,
    input [31:0] datab,
    output reg done,
    output reg [31:0] result);

    logic [31:0] tmp, b, a;
    logic gated_clk, start_int;

    assign gated_clk = clk & clk_en;

    edge_detect ED (gated_clk, rst, start, start_int);

    always @(posedge gated_clk or posedge rst)
    begin
        if(rst != 0) begin
            a      <=  1'b0;
            b      <=  1'b0;
            tmp    <=  1'b0;
            done   <=  1'b1;
            result <= 31'b0;
        end
        else begin
            if (start_int) begin
                a       <= dataa;
                b       <= datab;
                done    <= 1'b0;
            end
            else if (!done) begin
                if (a == 0) begin
                    done   <= 1'b1;
                    result <= b;
                end
                else if (b == 0) begin
                    done   <= 1'b1;
                    result <= a;
                end
                else begin
                    tmp = b;
                    b   = a % b;
                    a   = tmp;
                end
            end
        end
    end
endmodule
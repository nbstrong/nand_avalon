// Testbench
module tb;

  logic clk, rst, clk_en, start, done;
  logic [31:0] a, b, c;
  integer i;

  // Instantiate design under test
  gcd_ci
  GCD (.clk(clk), .rst(rst), .clk_en(clk_en), .start(start), .dataa(a), .datab(b), .done(done), .result(c));

  integer test_vec[][2] = '{
    '{2147483647,524287},
    '{1,1},
    '{1000000000,1},
    '{2,1023},
    '{91, 21}
  };

  initial begin // You can absolutely have multiple initial blocks
    clk = 0;
    #5
  	forever #5 clk = ~clk;
  end

  initial begin
    $display("Reset flop.");
  	rst = 1;

    repeat (2) @(posedge clk);
    $display("Release reset.");
    rst = 0;
  end

  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars();

    // Initialize
    start = 0;
    clk_en = 1;

    @(negedge rst)

    foreach(test_vec[i])
    begin
      a = test_vec[i][0];
      b = test_vec[i][1];
      @(posedge clk)
      start = 1;

      @(posedge done)
      start = 0;
    end

    repeat (10) @(posedge clk);
    $finish;
  end

endmodule
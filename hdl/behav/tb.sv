// Testbench
module tb;

  logic clk, rst, rd, wr, cs;
  logic [1:0] addr;
  logic [3:0] be;
  logic [31:0] wrData, rdData;

  // Instantiate design under test
  gcd_avalon DUT (
    .avs_s0_address(addr),
    .avs_s0_read(rd),
    .avs_s0_readdata(rdData),
    .avs_s0_write(wr),
    .avs_s0_writedata(wrData),
    .csi_clk(clk),
    .rsi_reset(rst)
  );

  integer test_vec[][2] = '{
    '{91, 21},
    '{1,1},
    '{2,1023}
    //'{2147483647,524287},
    //'{1000000000,1},
  };

  initial begin
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
    cs = 1;
    be = 4'hF;
    wrData = 0;
    addr = 0;
    wr = 0;
    rd = 0;

    // Take out of reset
    @(negedge rst);
    repeat (3) @(posedge clk);

    // Test
    foreach(test_vec[i])
    begin
      $display("i:%0h", i);
      addr = 0;
      wrData = test_vec[i][0];
      wr = 1;
      @(posedge clk);
      addr = 1;
      wrData = test_vec[i][1];
      @(posedge clk);
      addr = 3;
      wr = 0;
      rd = 1;
      @(posedge rdData[0]);
      repeat (2)@(posedge clk);
      rd = 0;
      @(posedge clk);
      rd = 1;
      addr = 2;
      @(posedge clk);
    end

    repeat (3) @(posedge clk);
    $finish;
  end

endmodule
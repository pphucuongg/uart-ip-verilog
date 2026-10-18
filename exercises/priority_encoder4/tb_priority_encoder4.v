`timescale 1ns/1ps
module tb_priority_encoder4;
  reg  [3:0] in;
  wire [1:0] pos;
  reg  [1:0] expected;
  integer i, k, errors = 0;

  priority_encoder4 dut(.in(in), .pos(pos));

    initial begin
    for (i = 0; i < 16; i = i + 1) begin
      in = i;
      expected = 2'd0;
      for (k = 3; k >= 0; k = k - 1) begin
        if (in[k] == 1) expected = k;
      end
      #1;
      if (pos !== expected) begin
        $display("FAIL: in=%b pos=%d expected=%d", in, pos, expected);
        errors = errors + 1;
      end
      #9;
    end
    if (errors == 0) $display("PASS: tat ca truong hop dung");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
`timescale 1ns/1ps
module tb_reverse8;
  reg  [7:0] in, expected;
  wire [7:0] out;
  integer i, k, errors = 0;

  reverse8 dut(.in(in), .out(out));

  initial begin
    for (i = 0; i < 256; i = i + 1) begin
      in = i;
      for (k = 0; k < 8; k = k + 1) begin
    expected[k] = in[7 - k];
  end
      #1;
      if (out !== expected) begin
      $display("FAIL: in=%b out=%b expected=%b", in, out, expected);
      errors=errors+1;
      end
      #9;
    end
    if (errors == 0) $display("PASS: tat ca 256 truong hop dung");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
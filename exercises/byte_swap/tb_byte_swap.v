`timescale 1ns/1ps
module tb_byte_swap;
  reg  [31:0] in;
  wire [31:0] out;
  reg  [31:0] expected;
  integer errors = 0;
  integer i;

  byte_swap dut(.in(in), .out(out));

  task check;
    begin
      expected = ((in & 32'h000000FF) << 24) |
                 ((in & 32'h0000FF00) << 8)  |
                 ((in & 32'h00FF0000) >> 8)  |
                 ((in & 32'hFF000000) >> 24);
      #1;
      if (out !== expected) begin
        $display("FAIL: in=%h out=%h expected=%h", in, out, expected);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_byte_swap);
    in = 32'h12345678; check; #9;
    in = 32'h00000000; check; #9;
    in = 32'hFFFFFFFF; check; #9;
    for (i = 0; i < 20; i = i + 1) begin
      in = $urandom;
      check;
      #9;
    end
    if (errors == 0) $display("PASS: tat ca truong hop dung");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
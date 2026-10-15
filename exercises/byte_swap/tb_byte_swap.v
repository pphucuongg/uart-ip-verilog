`timescale 1ns/1ps
module tb_byte_swap;
  reg  [31:0] in;
  wire [31:0] out;

  byte_swap dut(.in(in), .out(out));

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_byte_swap);
    in = 32'h12345678;
    #1;
    $display("in=%h out=%h", in, out);
    $finish;
  end
endmodule
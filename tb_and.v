`timescale 1ns/1ps
module tb_and;
  reg a, b;
  wire y;
  integer errors = 0;
  and_gate dut(.a(a), .b(b), .y(y));

  task check(input exp);
    begin
      #1;
      if (y !== exp) begin
        $display("FAIL: a=%b b=%b y=%b (mong doi %b)", a, b, y, exp);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_and);
    a=0; b=0; check(0); #9;
    a=0; b=1; check(1); #9;
    a=1; b=0; check(1); #9;
    a=1; b=1; check(0); #9;
    if (errors == 0) $display("PASS: tat ca truong hop dung");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
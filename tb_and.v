`timescale 1ns/1ps
module tb_and;
  reg a, b, c;
  wire y;
  integer errors = 0;
  integer i;
  and_gate dut(.a(a), .b(b), .c(c), .y(y));

  task check(input exp);
    begin
      #1;
      if (y !== exp) begin
        $display("FAIL: a=%b b=%b c=%b y=%b (mong doi %b)", a, b, c, y, exp);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_and);
    for (i = 0; i < 8; i = i + 1) begin
      {a, b, c} = i;
      check(i == 7);
      #9;
    end
    if (errors == 0) $display("PASS: tat ca truong hop dung");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
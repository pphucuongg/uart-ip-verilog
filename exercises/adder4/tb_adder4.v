`timescale 1ns/1ps
module tb_adder4;
  reg  [3:0] a, b;
  reg        cin;
  wire [3:0] sum;
  wire       cout;
  reg  [4:0] expected;
  integer i, errors = 0;

  adder4 dut(.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

  initial begin
    for (i = 0; i < 512; i = i + 1) begin
      {a, b, cin} = i;
      expected = a+b+cin ;        // (a)
      #1;
      if ( expected!== {cout,sum} ) begin        // (b)
        $display("FAIL: a=%d b=%d cin=%b sum=%d cout=%b expected=%d", a, b, cin, sum, cout, expected);
        errors = errors + 1;
      end
      #9;
    end
if (errors == 0)
        $display("ALL TESTS PASSED!");
    else
        $display("FAILED with %d errors.", errors);
    $finish;
  end
endmodule
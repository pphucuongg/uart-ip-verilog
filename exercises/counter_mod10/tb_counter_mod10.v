`timescale 1ns/1ps
module tb_counter_mod10;
  reg clk, rst, en;
  wire [3:0] count;
  integer exp_cnt, errors, i;

  counter_mod10 dut(.clk(clk), .rst(rst), .en(en), .count(count));
    initial clk = 0;
  always #5 clk = ~clk;
    initial begin
    errors = 0;
    exp_cnt = 0;
    rst = 1; en = 0;
    repeat (2) @(posedge clk);
    #1 rst = 0;
        for (i = 0; i < 30; i = i + 1) begin
      en = (i % 7 != 3);       // phần lớn en=1, thỉnh thoảng en=0
      if (en) exp_cnt = (exp_cnt + 1) % 10;
      @(posedge clk);
      #1;
      if (count !== exp_cnt) begin
        $display("FAIL: i=%0d en=%b count=%d expected=%d", i, en, count, exp_cnt);
        errors = errors + 1;
      end
    end
    if (errors == 0) $display("PASS: tat ca truong hop dung");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
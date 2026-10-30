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
  //TH1
    rst = 1; en = 0;
    repeat (2) @(posedge clk );
    #1 rst=0;
    en = 1;
exp_cnt = 1;
@(posedge clk);
#1;
if (count !== exp_cnt) begin
  $display("FAIL: count=%d expected=%d", count, exp_cnt);
  errors = errors + 1;
end
//TH2
for (i = 0; i < 11; i = i + 1) begin
  exp_cnt = (exp_cnt + 1) % 10;
  @(posedge clk);
  #1;
  if (count !== exp_cnt) begin
    $display("FAIL: i=%0d count=%d expected=%d", i, count, exp_cnt);
    errors = errors + 1;
  end
  end
  //TH3
 en = 0;
  @(posedge clk); 
  #1;             
  if (count !== exp_cnt) begin
    $display("FAIL TH3: count=%d expected=%d", count, exp_cnt);
    errors = errors + 1;
  end

  //TH4: 
  en = 1;
  rst = 1;
  exp_cnt = 0;       
  @(posedge clk);    
  #1;                
  if (count !== exp_cnt) begin
    $display("FAIL TH4: count=%d expected=%d", count, exp_cnt);
    errors = errors + 1;
  end
//FINAL
    if (errors == 0) $display("PASS");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
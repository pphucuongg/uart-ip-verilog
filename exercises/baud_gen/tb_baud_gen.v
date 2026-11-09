`timescale 1ns/1ps
module tb_baud_gen;
    reg  clk;
    reg  rst;
    wire tick; 
    integer exp_cnt, exp_tick, errors, i;
    parameter DIV =434;

    baud_gen dut(.clk(clk),.rst(rst),.tick(tick));
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        errors=0;
        exp_cnt=0;
        exp_tick=0;
    
    // TH1 : kiểm tra reset ban đầu 

    rst=1;
    repeat (2) @(posedge clk);
    #1;
    if (tick !== 0) begin
      $display("FAIL TH1 (Reset): tick=%d expected=0", tick);
      errors = errors + 1;
    end

    rst = 0;
    exp_cnt = 1;
    exp_tick = 0;
    @(posedge clk);
    #1;
    if (tick !== exp_tick) begin
      $display("FAIL TH1: tick=%d expected=%d", tick, exp_tick);
      errors = errors + 1;
    end

    // TH2: Chạy liên tiếp 2 chu kỳ (2 * DIV) + 4 nhịp (để dừng ở giữa chừng)
    for (i = 0; i < 2 * DIV + 4; i = i + 1) begin
      exp_cnt = (exp_cnt + 1) % DIV;
      if (exp_cnt == DIV - 1) exp_tick = 1;
      else exp_tick = 0;

      @(posedge clk);
      #1;
      if (tick !== exp_tick) begin
        $display("FAIL TH2: i=%0d tick=%d expected=%d (exp_cnt=%0d)", i, tick, exp_tick, exp_cnt);
        errors = errors + 1;
      end
    end

    //TH3: Reset giữa chừng
    rst=1;
    exp_cnt=0;
    exp_tick=0;
    @(posedge clk);
    #1;
    if (tick !== exp_tick) begin
      $display("FAIL TH3: tick=%d expected=%d", tick, exp_tick);
      errors = errors + 1;
    end

    //TH4 : Hạ reset, chạy tiếp DIV nhịp
    rst=0;
    for (i=0;i<DIV;i=i+1) begin 
    exp_cnt=(exp_cnt+1)%DIV;
    if (exp_cnt==DIV-1) exp_tick=1;
    else exp_tick=0;

    @(posedge clk);
    #1;
    if (tick !== exp_tick) begin
      $display("FAIL TH3: tick=%d expected=%d", tick, exp_tick);
      errors = errors + 1;
    end
    end
    
  // FINAL
    if (errors == 0) $display("PASS");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
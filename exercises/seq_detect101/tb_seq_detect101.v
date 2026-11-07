`timescale 1ns/1ps
module tb_seq_detect101;
  reg clk, reset, in;
  wire found;
  reg [2:0] hist;       
  reg expected;
  integer errors, i;

  seq_detect101 dut(.clk(clk), .reset(reset), .in(in), .found(found));

  initial clk = 0;
  always #5 clk = ~clk;

task apply(input b);
    begin
      in = b;
      hist = {hist[1:0], b};
      expected = (hist == 3'b101);
      @(posedge clk);
      #1;
      // Kiểm tra lần 1: Ngay sau sườn lên clock
      if (found !== expected) begin
        $display("FAIL: hist=%b found=%b expected=%b", hist, found, expected);
        errors = errors + 1;
      end

      // [ĐÃ THÊM]: Thử lật ngõ vào 'in' ngay trong chu kỳ hiện tại (trước clock tiếp theo)
      // Nếu là mạch Moore chuẩn, 'found' KHÔNG ĐƯỢC PHÉP thay đổi khi 'in' thay đổi!
      in = ~b; 
      #1;
      if (found !== expected) begin
        $display("FAIL (Glitch/Mealy bug): found bi phu thuoc vao in! hist=%b found=%b expected=%b", hist, found, expected);
        errors = errors + 1;
      end
      in = b; // Trả lại giá trị cũ cho in
    end
  endtask

  initial begin
    errors = 0;
    hist = 3'b000;
    reset = 1; in = 0;
    repeat (2) @(posedge clk);
    #1 reset = 0;

    // phần A: chuỗi cố định 1 0 1 0 1 (gọi apply 5 lần)
    apply(1'b1);
    apply(1'b0);
    apply(1'b1); 
    apply(1'b0);
    apply(1'b1); 

    // phần B: 200 bit ngẫu nhiên (vòng for, mỗi vòng apply một bit từ $urandom)
    for (i=0;i<200;i=i+1) begin 
        apply ($urandom);
        end

    // phần C: reset giữa chừng, nhớ hist cũng phải về 0
    // 1. lỗi bỏ qua reset (kiểm tra cả lỗi reset nhầm về DONE)
    apply(1'b1);
    apply(1'b0);
    in=1;
    reset=1;
    @(posedge clk);
    #1;
    hist= 3'b000; 
    expected=0;
    if (found !== expected) begin
        $display("FAIL: hist=%b found=%b expected=%b", hist, found, expected);
        errors = errors + 1;
      end
      reset = 0;

    // 2.  Kiểm tra reset đưa về đúng trạng thái đầu (WAIT) và chạy tiếp bình thường
    #1;
    apply(1'b1);
    apply(1'b0);
    reset =1;
    @(posedge clk); 
    #1;
    reset =0;
    hist = 3'b000;
    
    // Bơm chuỗi 0 -> 1 -> 0 -> 1 sau khi nhả reset để bắt trọn các lỗi còn lại:
    apply(1'b0); 
    apply(1'b1); // Tới đây (sau 2 bit 0->1): Bắt lỗi nếu reset nhảy nhầm về CHECK (mạch hỏng sẽ báo found=1)
    apply(1'b0);
    apply(1'b1); // Tới đây (sau chuỗi 0->1->0->1): Bắt lỗi nếu mạch bị đơ sau reset (mạch đúng phải báo found=1)

    if (errors == 0) $display("PASS");
    else $display("FAIL: %0d loi", errors);
    $finish;
  end
endmodule
`timescale 1ns/1ps

module tb_uart_tx;
    parameter N = 4;

    reg        clk = 0, rst = 0, tx_start = 0;
    reg  [7:0] tx_data = 0;
    wire       tick, tx, tx_busy;
    integer    k;
    integer    err_cnt = 0; // [SỬA 3]: Biến đếm tổng số lỗi toàn bài test
    reg        fail;

    // ---- clock 50 MHz ----
    always #10 clk = ~clk;

    // ---- tạo tick: 1 clk mỗi N clk ----
    reg [7:0] cnt = 0;
    always @(posedge clk) begin
        if (cnt == N-1) cnt <= 0;
        else            cnt <= cnt + 1;
    end
    assign tick = (cnt == N-1);

    // ---- DUT ----
    uart_tx dut (
        .clk(clk), .rst(rst), .tick(tick),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .tx_busy(tx_busy)
    );

    // ---- [SỬA 3]: Watchdog chống treo mô phỏng ----
    initial begin
        #50000; // Giới hạn tối đa 50 us (dư sức cho toàn bộ test case với N=4)
        $display("FAIL: WATCHDOG TIMEOUT - Mach bi treo!");
        $finish;
    end

    // ---- task 1: gửi 1 byte (tx_start đúng 1 clk) ----
    task send_byte(input [7:0] b);
    begin
        @(negedge clk);
        tx_data  = b;
        tx_start = 1;
        @(negedge clk);
        tx_start = 0;
        tx_data  = 8'hAF; // Đổi dữ liệu ngay để kiểm tra chốt data_reg
    end
    endtask

    // ---- task 2: kiểm tra bit START (đúng N clk: không ngắn, không dài) + 8 bit data + STOP ----
    task check_byte(input [7:0] expected);
        integer i, c;
        reg [7:0] got;
        reg start_short_err, start_long_err;
    begin
        @(negedge tx);
        start_short_err = 0;
        start_long_err  = 0;

        // 1. Kiểm tra N-1 chu kỳ bên trong bit START phải giữ mức 0 (không được ngắn hơn N)
        for (c = 0; c < N - 1; c = c + 1) begin
            @(posedge clk); #1;
            if (tx !== 0) start_short_err = 1;
        end
        if (start_short_err) begin
            $display("FAIL: start bit NGAN hon %0d clk", N);
            err_cnt = err_cnt + 1;
        end

        // 2. [SỬA 2]: Tại đúng sườn thứ N (ranh giới START -> D0), nếu D0 == 1 thì tx phải lên 1 (không được dài hơn N)
        @(posedge clk); #1;
        if (expected[0] === 1'b1 && tx !== 1'b1) begin
            start_long_err = 1;
            $display("FAIL: start bit DAI hon %0d clk", N);
            err_cnt = err_cnt + 1;
        end

        // 3. Đang ở đầu bit D0 (+1ns), nhảy thêm N/2 clk để vào giữa bit D0
        repeat (N/2) @(posedge clk);
        got[0] = tx;

        // 4. Đọc 7 bit tiếp theo (D1 -> D7)
        for (i = 1; i < 8; i = i + 1) begin
            repeat (N) @(posedge clk);
            got[i] = tx;
        end

        // 5. Kiểm tra bit STOP
        repeat (N) @(posedge clk);
        if (tx !== 1) begin
            $display("FAIL: stop bit != 1");
            err_cnt = err_cnt + 1;
        end

        // 6. Đánh giá byte nhận được
        if (!start_short_err && !start_long_err && got === expected) begin
            $display("PASS: byte %h", got);
        end else begin
            $display("FAIL: expected %h, got %h", expected, got);
            err_cnt = err_cnt + 1;
        end
    end
    endtask

    // ---- chương trình chính ----
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_uart_tx);

        // Reset đầu
        rst = 1; repeat (3) @(posedge clk);
        @(negedge clk) rst = 0; 

        // TH1: Truyền liên tiếp 2 byte khác nhau (chọn bit[0]=1 để check luôn độ rộng START)
        wait (tx_busy == 0);   
        fork
            send_byte(8'hA5);
            check_byte(8'hA5);
        join

        wait (tx_busy == 0);
        fork
            send_byte(8'h3D); 
            check_byte(8'h3D);
        join


        wait (tx_busy == 0);
        send_byte(8'h00);
        wait (tx == 0);             
        repeat (2*N) @(posedge clk); 
        if (tx !== 0) begin
            $display("FAIL: TH2 setup sai, tx khong bang 0 truoc khi rst");
            err_cnt = err_cnt + 1;
        end
        @(negedge clk) rst = 1;      // reset ngay khi tx đang bằng 0
        @(posedge clk); #1;
        if (tx !== 1 || tx_busy !== 0) begin
            $display("FAIL: rst giua chung khong dua tx=1, tx_busy=0");
            err_cnt = err_cnt + 1;
        end else begin
            $display("PASS: TH2 reset giua khung truyen (tx: 0 -> 1)");
        end

        // TH3: Nhả rst, gửi byte mới 8'h5B (bit[0]=1), check
        @(negedge clk) rst = 0;
        wait (tx_busy == 0);
        fork
            send_byte(8'h5B);
            check_byte(8'h5B);
        join

        // TH4: tx_start lúc đang bận phải bị bỏ qua
        wait (tx_busy == 0);
        fork
            check_byte(8'h2F);
            begin
                send_byte(8'h2F);
                repeat (3*N) @(posedge clk);
                send_byte(8'h2A); // Gửi đè lúc đang bận -> phải bị bỏ qua
            end
        join
        // TH2 - Chờ mạch rảnh hẳn, gửi 8'h00 và canh đúng lúc tx == 0 mới kích rst
        wait (tx_busy == 0);
        fail = 0;
        for (k = 0; k < 12*N; k = k + 1) begin
            @(posedge clk); #1;
            if (tx !== 1 || tx_busy !== 0) fail = 1;
        end
        if (fail) begin
            $display("FAIL: tx_start luc dang ban khong bi bo qua");
            err_cnt = err_cnt + 1;
        end else begin
            $display("PASS: TH4 tx_start luc ban bi bo qua");
        end

        // TH5: Quét mọi pha lệch của tx_start so với tick (0 -> N-1 clk)
        for (k = 0; k < N; k = k + 1) begin
            wait (tx_busy == 0);
            repeat (k) @(posedge clk);
            fork
                send_byte(8'h55); // bit[0]=1 -> kiểm tra cả ngắn hơn N lẫn dài hơn N ở mọi pha
                check_byte(8'h55);
            join
        end

        if (err_cnt == 0) $display("RESULT: PASS (0 errors)");
        else              $display("RESULT: FAIL (Tong so loi = %0d)", err_cnt);


        #100 $finish;
    end
endmodule
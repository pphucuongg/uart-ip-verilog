`timescale 1ns/1ps
module tb_uart_rx;
    parameter M = 4;            // M = 4: cứ 4 clk tạo 1 s_tick; 1 bit UART = 16*M = 64 clk

    // TODO 1: khai báo reg/wire
    reg        clk = 0;
    reg        rst = 1;
    reg        rx  = 1;
    wire       s_tick;
    wire [7:0] rx_data;
    wire       rx_done;
    wire       frame_err;
    integer    err_cnt = 0;

    // TODO 2: clock 50 MHz (chu kỳ 20 ns)
    always #10 clk = ~clk;

    // TODO 3: tạo s_tick, cứ M clock lên 1 xung
    reg [7:0] cnt = 0;
    always @(posedge clk) begin
        if (cnt == M-1) cnt <= 0;
        else            cnt <= cnt + 1;
    end
    assign s_tick = (cnt == M-1);

    // TODO 4: nối DUT
    uart_rx dut(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .s_tick(s_tick),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .frame_err(frame_err)
    );

    // TODO 5: watchdog 
    initial begin
        #160000;
        $display("FAIL: WATCHDOG TIMEOUT - Mach bi treo!");
        $display("RESULT: FAIL (WATCHDOG TIMEOUT)");
        $finish;
    end

    // TODO 6: bắt kết quả
    reg [7:0] got;
    integer   done_cnt = 0;
    integer   ferr_cnt = 0;

    always @(posedge clk) begin
        if (rx_done) begin
            got      <= rx_data;
            done_cnt <= done_cnt + 1;
        end
        if (frame_err) begin
            ferr_cnt <= ferr_cnt + 1;
        end
    end

    // TODO 7: task send_frame
    task send_frame(input [7:0] b, input stop_bit, input [15:0] delay);
        integer i;
        begin
            repeat (delay) @(posedge clk);
            #1;
            rx = 0;                          // bit start
            repeat (16*M) @(posedge clk);
            #1;
            for (i = 0; i < 8; i = i + 1) begin
                rx = b[i];                   
                repeat (16*M) @(posedge clk);
                #1;
            end
            rx = stop_bit;
            repeat (16*M) @(posedge clk);
            #1;
            rx = 1;                          
        end
    endtask

    initial begin
        // TODO 8: dumpfile/dumpvars, reset giữ qua 3 cạnh lên clk
        $dumpfile("wave_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        rst = 1;
        rx  = 1;
        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // TH1: GỬI 2 DATA BÌNH THƯỜNG (quét delay = 2 và delay = 0)

        send_frame(8'h4A, 1, 2);
        if (done_cnt == 1 && got === 8'h4A && ferr_cnt == 0)
            $display("PASS TH1a: Nhan dung 0x%h (delay=2)", got);
        else begin
            $display("FAIL TH1a: got=0x%h, done_cnt=%0d, ferr_cnt=%0d", got, done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end

        send_frame(8'h24, 1, 0);
        if (done_cnt == 2 && got === 8'h24 && ferr_cnt == 0)
            $display("PASS TH1b: Nhan dung 0x%h (delay=0)", got);
        else begin
            $display("FAIL TH1b: got=0x%h, done_cnt=%0d, ferr_cnt=%0d", got, done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end

// TH2: RESET NGẮN (3 clk) GIỮA CHỪNG
        fork
            send_frame(8'hFF, 1, 0);          // Dùng 8'hFF để phần còn lại của frame đều là 1
            begin
                repeat (36*M) @(posedge clk); // Đang nhận dở (ở giữa bit D1)
                @(negedge clk) rst = 1;       // Kích reset
                repeat (3) @(posedge clk);    // Giữ reset ngắn đúng 3 clk
                @(negedge clk) rst = 0;       // Nhả reset ngay trong khi frame vẫn đang chạy
            end
        join

        repeat (5) @(posedge clk);
        if (done_cnt == 2 && ferr_cnt == 0)
            $display("PASS TH2a: Reset ngan giua chung khong tao xung nham");
        else begin
            $display("FAIL TH2a: done_cnt=%0d, ferr_cnt=%0d", done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end

        // Gửi ngay 1 frame sau reset để chứng minh mạch nhận lại được (và nạp 0x5A vào rx_data)
        send_frame(8'h5A, 1, 1);
        if (done_cnt == 3 && got === 8'h5A && ferr_cnt == 0)
            $display("PASS TH2b: Nhan lai dung 0x%h sau reset (delay=1)", got);
        else begin
            $display("FAIL TH2b: got=0x%h, done_cnt=%0d, ferr_cnt=%0d", got, done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end

        // TH3: NHIỄU (GLITCH)

        #1; rx = 0;
        repeat (4 * M) @(posedge clk);
        #1; rx = 1;
        repeat (160 * M) @(posedge clk);
        if (done_cnt == 3 && ferr_cnt == 0)
            $display("PASS TH3: Loc nhieu glitch thanh cong");
        else begin
            $display("FAIL TH3: Bi nhieu danh lua (done=%0d, ferr=%0d)", done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end


        // TH4a: SAI BIT STOP (delay = 3) & KIỂM TRA rx_data GIỮ NGUYÊN 0x5A

        send_frame(8'h55, 0, 3);
        if (ferr_cnt == 1 && done_cnt == 3 && rx_data === 8'h5A)
            $display("PASS TH4a: Phat hien dung Framing Error & giu nguyen rx_data=0x%h (delay=3)", rx_data);
        else begin
            $display("FAIL TH4a: done=%0d, ferr=%0d, rx_data=0x%h", done_cnt, ferr_cnt, rx_data);
            err_cnt = err_cnt + 1;
        end

        // TH4b: ERR_WAIT VỀ IDLE

        send_frame(8'h96, 1, 2);
        if (done_cnt == 4 && got === 8'h96 && ferr_cnt == 1)
            $display("PASS TH4b: Phuc hoi sau loi khung thanh cong (got=0x%h)", got);
        else begin
            $display("FAIL TH4b: Mach bi ket o ERR_WAIT (got=0x%h, done=%0d)", got, done_cnt);
            err_cnt = err_cnt + 1;
        end

        // TODO 10: in RESULT, $finish
        repeat (5) @(posedge clk);
        if (err_cnt == 0)
            $display("RESULT: PASS (0 errors | done_cnt = %0d, ferr_cnt = %0d)", done_cnt, ferr_cnt);
        else
            $display("RESULT: FAIL (Tong so loi = %0d | done_cnt = %0d, ferr_cnt = %0d)", err_cnt, done_cnt, ferr_cnt);
        $finish;
    end
endmodule
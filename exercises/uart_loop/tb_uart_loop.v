`timescale 1ns/1ps
module tb_uart_loop;
    // TODO 1: khai báo reg/wire cho các cổng của uart_loop, thêm err_cnt
    reg        clk = 0;
    reg        rst = 1;
    reg        tx_start = 0;
    reg  [7:0] tx_data = 0;
    wire       tx_busy;
    wire [7:0] rx_data;
    wire       rx_done;
    wire       frame_err;
    wire       line;
    integer    err_cnt = 0;
    // TODO 2: clock, chu kỳ 20 ns
    always #10 clk=~clk;

    // TODO 3: nối DUT uart_loop (theo tên)
    uart_loop dut (
        .clk       (clk),
        .rst       (rst),
        .tx_start  (tx_start),
        .tx_data   (tx_data),
        .tx_busy   (tx_busy),
        .rx_data   (rx_data),
        .rx_done   (rx_done),
        .frame_err (frame_err),
        .line      (line)
    );
    // TODO 4: watchdog. Tự tính: 1 frame = 10 * 432 clk = ? ns. Cần dư cho nhiều frame
    initial begin
        #1000000; // 1 ms (dư cho >11 frame)
        $display("FAIL: WATCHDOG TIMEOUT - Mach bi treo!");
        $display("RESULT: FAIL (WATCHDOG TIMEOUT)");
        $finish;
    end
    // TODO 5: khối ghi sổ giống tb_uart_rx (got, done_cnt, ferr_cnt)
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
    // TODO 6: task send_byte(input [7:0] b), tx_start đúng 1 clk (giống tb_uart_tx)
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


    initial begin
        // TODO 7: dumpfile, reset giữ qua ít nhất 3 cạnh, nhả ở negedge
        $dumpfile("wave_loop.vcd");
        $dumpvars(0, tb_uart_loop);

        rst = 1;
        tx_start = 0;
        repeat (3) @(posedge clk);
        @(negedge clk) rst = 0;

        // Các ca test viết tiếp ở đây

        //TH1 : GỬI 2 BYTE CHUẨN
        send_byte(8'hA3);
        wait (!tx_busy);
        if (done_cnt == 1 && got === 8'hA3 && ferr_cnt == 0)
            $display("PASS CA 1a: Nhan dung 0x%h", got);
        else begin
            $display("FAIL CA 1a: got=0x%h, done=%0d, ferr=%0d", got, done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end

        send_byte(8'h37); 
        wait(tx_busy == 0);
        if (done_cnt == 2 && got === 8'h37 && ferr_cnt == 0)
            $display("PASS CA 1b: Nhan dung byte lien tiep 0x%h", got);
        else begin
            $display("FAIL CA 1b: got=0x%h, done=%0d, ferr=%0d", got, done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end
        //TH2 : RESET GIỮA CHỪNG 
        send_byte (8'hC5);
        repeat (2000) @(posedge clk);
        @(negedge clk) rst = 1;
        repeat (5) @(posedge clk);
        @(negedge clk) rst = 0;      
        repeat (5) @(posedge clk);
        if (done_cnt == 2 && ferr_cnt == 0 && tx_busy == 0)
            $display("PASS CA 2a: Reset giua chung huy frame thanh cong");
        else begin
            $display("FAIL CA 2a: done=%0d, ferr=%0d, tx_busy=%b", done_cnt, ferr_cnt, tx_busy);
            err_cnt = err_cnt + 1;
        end

        send_byte(8'h9E);             
        wait(tx_busy == 0);
        if (done_cnt == 3 && got === 8'h9E && ferr_cnt == 0)
            $display("PASS CA 2b: Phuc hoi sau reset thanh cong (got=0x%h)", got);
        else begin
            $display("FAIL CA 2b: got=0x%h, done=%0d, ferr=%0d", got, done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end

        //TH3 : GỬI ĐÈ 
        send_byte (8'hD1);
        repeat (2000) @(posedge clk);
        send_byte (8'hE2);
        wait(tx_busy == 0);
        repeat (5) @(posedge clk);

        if (done_cnt == 4 && got === 8'hD1 && ferr_cnt == 0)
            $display("PASS CA 3: Bo qua lenh gui de, nhan dung 0x%h", got);
        else begin
            $display("FAIL CA 3: got=0x%h, done=%0d, ferr=%0d", got, done_cnt, ferr_cnt);
            err_cnt = err_cnt + 1;
        end

        //FINAL
        repeat (10) @(posedge clk);
        if (err_cnt == 0)
            $display("RESULT: PASS (0 errors | done_cnt=%0d, ferr_cnt=%0d)", done_cnt, ferr_cnt);
        else
            $display("RESULT: FAIL (Tong so loi=%0d | done_cnt=%0d, ferr_cnt=%0d)", err_cnt, done_cnt, ferr_cnt);
        #100 $finish;
    end
endmodule
module uart_loop (
    input        clk,
    input        rst,
    input        tx_start,
    input [7:0]  tx_data,
    output       tx_busy,
    output [7:0] rx_data,
    output       rx_done,
    output       frame_err,
    output       line
);
    wire s_tick;
    wire tick;

    baud_gen #(.DIV(27)) u_baud_rx (
        .clk  (clk),
        .rst  (rst),
        .tick (s_tick)
    );

    baud_gen #(.DIV(432)) u_baud_tx (
        .clk  (clk),
        .rst  (rst),
        .tick (tick)
    );

    uart_tx u_tx (
        .clk      (clk),
        .rst      (rst),
        .tick     (tick),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (line),
        .tx_busy  (tx_busy)
    );

    uart_rx u_rx (
        .clk       (clk),
        .rst       (rst),
        .rx        (line),
        .s_tick    (s_tick),
        .rx_data   (rx_data),
        .rx_done   (rx_done),
        .frame_err (frame_err)
    );

endmodule
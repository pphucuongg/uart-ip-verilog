module top_module(
    input clk,
    input in,
    input reset,
    output done
);
    localparam IDLE=0, DATA=1, STOP=2, DONE=3, ERR=4;
    reg [2:0] state, next;
    reg [2:0] cnt;

    always @(*) begin
        case (state)
            IDLE: next = in ? IDLE : DATA;
            DATA: next = (cnt == 3'd7) ? STOP : DATA;
            STOP: next = in ? DONE : ERR;
            DONE: next = in ? IDLE : DATA;
            ERR:  next = in ? IDLE : ERR;
            default: next = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            cnt   <= 3'd0;
        end else begin
            state <= next;
            if (state == DATA) cnt <= cnt + 3'd1;
            else               cnt <= 3'd0;
        end
    end

    assign done = (state == DONE);
endmodule
module uart_rx (
    input            clk, 
    input            rst, 
    input            rx,
    input            s_tick,
    output reg [7:0] rx_data, 
    output reg       rx_done
);
    reg [2:0] state,next;
    reg [3:0] s_cnt;
    reg [2:0] bit_cnt; 
    parameter IDLE=0, START=1, DATA=2, STOP=3;
    
    always @(*) begin 
        next = state;
        case (state)
        IDLE: begin
                if (rx == 0) next = START; 
            end

            START: begin
                if (s_tick && (s_cnt == 7)) begin
                    next = rx ? IDLE : DATA;
                end
            end

            DATA: begin
                if (s_tick && (s_cnt == 15)) begin
                    next = (bit_cnt == 7) ? STOP : DATA;
            end
            end

            STOP: begin
                   if (s_tick && (s_cnt == 15) && (rx == 1)) begin
                    next = IDLE;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin 
            state   <= IDLE;
            s_cnt   <= 0;
            bit_cnt <= 0;
            rx_data <= 0;
            rx_done <= 0;
        end
        else begin 
            state <= next;
            rx_done <=0;
            case (state) 
                IDLE : begin 
                    s_cnt <=0;
                    bit_cnt<=0;
                end
                START : begin 
                    if (s_tick) begin 
                        if (s_cnt==7) s_cnt<=0;
                        else s_cnt <= s_cnt+1;
                    end
                end
                DATA : begin 
                    if (s_tick) begin
                        if (s_cnt==15) begin 
                            s_cnt<=0;
                            rx_data<={rx,rx_data[7:1]};
                            bit_cnt<=bit_cnt+1;
                        end
                        else s_cnt<=s_cnt+1;
                    end
                end
                STOP: begin
                    if (s_tick) begin
                        if (s_cnt == 15) begin
                            if (rx == 1) begin
                                s_cnt   <= 0;
                                rx_done <= 1; 
                            end
                        end else begin
                            s_cnt <= s_cnt + 1;
                        end
                    end
                end
            
            endcase
        end 
    end
endmodule   
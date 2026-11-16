module uart_tx ( 
    input clk, input rst, input tick, input tx_start, input [7:0] tx_data,
    output reg tx, output reg tx_busy 
);
    reg [2:0] state, next_state; 
    reg [2:0] bit_cnt;
    reg [7:0] data_reg;
    
  
    parameter IDLE = 0, WAIT_TICK = 1, START = 2, DATA = 3, STOP = 4;
    
    always @(*) begin 
        case (state) 
            IDLE      : next_state = tx_start ? WAIT_TICK : IDLE;
            WAIT_TICK : next_state = tick ? START : WAIT_TICK; // Chờ nhịp tick đầu tiên
            START     : next_state = tick ? DATA  : START;     // Bắt đầu đếm trọn 1 chu kỳ tick
            DATA      : next_state = (bit_cnt == 7 && tick) ? STOP : DATA; 
            STOP      : next_state = tick ? IDLE  : STOP;
            default   : next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin 
        if (rst) begin 
            state   <= IDLE;
            tx      <= 1;
            tx_busy <= 0;
            bit_cnt <= 0;
        end
        else begin 
            state <= next_state;
            case (state) 
                IDLE : begin
                    bit_cnt <= 0;
                    tx      <= 1;
                    if (tx_start) begin 
                        data_reg <= tx_data;
                        tx_busy  <= 1;
                    end
                end
                
                WAIT_TICK : tx <= 1; 
                
                START     : tx <= 0; 
                
                DATA : begin 
                    tx <= data_reg[bit_cnt];
                    if (tick) bit_cnt <= bit_cnt + 1;
                end
                
                STOP : begin 
                    tx <= 1;
                    if (tick) tx_busy <= 0;
                end
            endcase
        end
    end
endmodule
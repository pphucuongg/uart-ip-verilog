module uart_tx ( 
    input clk, input rst, input tick, input tx_start, input [7:0] tx_data,
    output reg tx, output reg tx_busy );
    reg [1:0] state, next_state;
    reg [2:0] bit_cnt;
    reg [7:0] data_reg;
    parameter IDLE=0, START=1,DATA=2, STOP=3;
    
    always @(*) begin 
    case(state) 
        IDLE: next_state= tx_start ? START : IDLE;
        START : next_state = tick? DATA : START;
        DATA : next_state = (bit_cnt==7 && tick==1)? STOP : DATA; 
        STOP : next_state= (tick)? IDLE :STOP;
        endcase
        end

    always @(posedge clk) begin 
        if (rst) begin 
            state<= IDLE;
            tx<=1;
            tx_busy<=0;
        end
        else begin 
        state<= next_state;
        
        case (state) 
            IDLE : begin
                bit_cnt<=0;
                tx<=1;
                if ( tx_start ) begin 
                data_reg <= tx_data;
                tx_busy<=1;
                end
            end
            
            START : tx<=0;
            
            DATA : begin 
                tx<=data_reg[bit_cnt];
                if (tick) begin 
                    bit_cnt<=bit_cnt+1;
                end
            end
            
            STOP : begin 
                tx<=1;
                if (tick) tx_busy <= 0;
            end
        endcase
    end
    end
endmodule





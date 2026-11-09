module baud_gen ( input clk,input rst, output reg tick );
    
    parameter DIV =434;
    reg [8:0] baud_div;
    
    always @(posedge clk) begin 
        if (rst) begin
            baud_div<=0;
            tick<=0;
        end
        else begin
            if (baud_div==DIV-1) begin 
                baud_div<=0;
            end
            else baud_div<= baud_div+1; 
            if (baud_div == DIV - 2)
                tick <= 1;
            else
                tick <= 0;
        end
    end
endmodule
    
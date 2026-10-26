module counter_mod10 ( input clk, input rst, input en, output reg [3:0] count);
    always @(posedge clk ) begin
        if (rst) count<=4'd0;
        else if (en) begin 
        if (count==9) count <=0;
        else count<=(count+1);
        end
        end
    endmodule
module top_module(
    input clk,
    input areset,  // async active-high reset to zero
    input load,
    input ena,
    input [3:0] data,
    output reg [3:0] q); 
    always @(posedge clk, posedge areset ) begin 
        if (areset) q<=4'b0;
        else begin 
            if (ena) q>>=1;
            if (load) q<=data;

        end
    end
            
        
endmodule
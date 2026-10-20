module top_module (
    input [3:0] x,
    input [3:0] y, 
    output [4:0] sum);
    wire [3:0] cout;
    wire [3:0] c={cout[2],cout[1],cout[0],1'b0};
    assign sum={cout[3],x^y^c};
    assign cout={(x & y) | (x & c) | (y & c)};    
endmodule
module top_module( 
    input [2:0] a, b,
    input cin,
    output [2:0] cout,
    output [2:0] sum );
    wire [2:0] c={cout[1],cout[0],cin};
    assign sum=a^b^c;
    assign cout=(a & b) | (a & c) | (b & c);

endmodule
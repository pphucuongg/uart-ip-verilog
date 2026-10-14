module top_module( 
    input [31:0] in,
    output [31:0] out );//
    wire [7:0] a,b,c,d;
    assign a[7:0]=in[7:0];
    assign b[7:0]=in[15:8];
    assign c[7:0]=in[23:16];
    assign d[7:0]=in[31:24];
    assign out={a,b,c,d};
endmodule

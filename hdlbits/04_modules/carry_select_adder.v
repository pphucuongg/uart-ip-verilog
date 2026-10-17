//add16 is given 
module top_module(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);

    wire [15:0] out1, sum1, sum0; 
    wire w;
    

    add16 box1 (.cin(0), .a(a[15:0]),  .b(b[15:0]),  .cout(w), .sum(out1));
    add16 box2 (.cin(1), .a(a[31:16]), .b(b[31:16]), .sum(sum1)); 
    add16 box3 (.cin(0), .a(a[31:16]), .b(b[31:16]), .sum(sum0)); 
    
    wire [15:0] mux_out;
    assign mux_out = (w == 1'b1) ? sum1 : sum0; 
    assign sum = {mux_out, out1};
    
endmodule
//The provided module has the following declaration: add16
module top_module(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);
	wire w;
    wire [15:0] sum1,sum2;
    add16 box1 (.cout(w),.a(a[15:0]),.b(b[15:0]),.sum(sum1));
    add16 box2 (.cin(w),.a(a[31:16]),.b(b[31:16]),.sum(sum2));
    assign sum={sum2,sum1};
    
    

endmodule
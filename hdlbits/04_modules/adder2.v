// add16 is given
module top_module (
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);


wire[15:0] w1,w2;
wire cout;

    add16 box1 (.a(a[15:0]),.b(b[15:0]),.cin(0),.cout(cout),.sum(w1));
    add16 box2 (.a(a[31:16]),.b(b[31:16]),.cin(cout),.sum(w2)); 
    assign sum = {w2,w1};
	
endmodule 

module add1 ( input a, input b, input cin,   output sum, output cout );
    assign {cout, sum} = a + b + cin; 
endmodule

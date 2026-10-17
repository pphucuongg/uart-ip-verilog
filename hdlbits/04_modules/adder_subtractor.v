//add16 is given
module top_module(
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum
);
    wire [15:0] out1,out2;
    wire [31:0] in;
    wire cout;
    assign in=b^{32{sub}};
    add16 box1 (.cin(sub),.a(a[15:0]),.b(in[15:0]),.cout(cout),.sum(out1));
    add16 box2 (.a(a[31:16]),.b(in[31:16]),.cin(cout),.sum(out2));
    assign sum={out2,out1};
    

endmodule
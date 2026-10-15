module top_module(
    input [3:0] in,
    output out_and,
    output out_or,
    output out_xor
);
    assign out_and = &in;   // AND của mọi bit của in
    assign out_or  = |in;   // OR của mọi bit
    assign out_xor = ^in;   // XOR của mọi bit
endmodule
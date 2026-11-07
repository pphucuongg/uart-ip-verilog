module seq_detect101 (
    input reset,
    input in,
    input clk,
    output found
);

parameter WAIT=0, CHECK=1, END=2, DONE=3;
reg [1:0] state, next;

always @(*) begin 
    case (state) 
        WAIT: next=in? CHECK : WAIT;
        CHECK: next= in? CHECK : END;
        END : next= in? DONE :  WAIT;
        DONE : next= in ? CHECK : END;
    endcase 
end

always@(posedge clk) begin 
    if (reset) state<=WAIT;
    else state<=next;
end
assign found = ( state==DONE );
endmodule
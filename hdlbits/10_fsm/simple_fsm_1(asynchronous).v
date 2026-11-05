module top_module(clk, reset, in, out);
    input clk;
    input reset;    // Synchronous reset to state B
    input in;
    output out;

    parameter A=0, B=1;
    reg present_state, next_state;

    // 1. Mạch tổ hợp tính next_state
    always @(*) begin
        case (present_state)
            A: next_state = in ? A : B;
            B: next_state = in ? B : A;
        endcase
    end

    // 2. Mạch tuần tự cập nhật present_state (Reset đồng bộ: chỉ có posedge clk)
    always @(posedge clk) begin
        if (reset) 
            present_state <= B;
        else 
            present_state <= next_state;
    end

    // 3. Logic đầu ra Moore
    assign out = (present_state == B);

endmodule
module max3 (
    input wire clk,
    input wire [7:0] in1,
    input wire [7:0] in2,
    input wire [7:0] in3,
    output reg [7:0] max_out
);
    reg [7:0] max_1_2;
    reg [7:0] in3_delay;

    always @(posedge clk) begin
        // Stage 1: Compare in1 and in2
        if (in1 > in2)
            max_1_2 <= in1;
        else
            max_1_2 <= in2;
            
        in3_delay <= in3; // Keep in3 aligned with the pipeline

        // Stage 2: Compare winner with in3
        if (max_1_2 > in3_delay)
            max_out <= max_1_2;
        else
            max_out <= in3_delay;
    end
endmodule
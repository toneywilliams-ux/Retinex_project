    module col_max_11 (
    input  wire clk,
    // The 11 pixels from the current column (from line buffers)
    input  wire [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,
    output reg  [7:0] col_max_out
);
    // Level 1 Outputs
    wire [7:0] max_012, max_345, max_678, max_910x;
    
    // Level 2 Outputs
    wire [7:0] max_L1_A, max_L1_B;
    
    // We pad the missing 12th input with 8'b0
    max3 L1_inst0 (.clk(clk), .in1(p0), .in2(p1),  .in3(p2),   .max_out(max_012));
    max3 L1_inst1 (.clk(clk), .in1(p3), .in2(p4),  .in3(p5),   .max_out(max_345));
    max3 L1_inst2 (.clk(clk), .in1(p6), .in2(p7),  .in3(p8),   .max_out(max_678));
    max3 L1_inst3 (.clk(clk), .in1(p9), .in2(p10), .in3(8'b0), .max_out(max_910x));

    // Level 2
    max3 L2_inst0 (.clk(clk), .in1(max_012), .in2(max_345),  .in3(max_678), .max_out(max_L1_A));
    // Pad the remaining inputs with 0
    max3 L2_inst1 (.clk(clk), .in1(max_910x),.in2(8'b0),     .in3(8'b0),    .max_out(max_L1_B));

    // Level 3 (Final Column Max)
    wire [7:0] final_max_wire;
    max3 L3_inst0 (.clk(clk), .in1(max_L1_A), .in2(max_L1_B), .in3(8'b0), .max_out(final_max_wire));

    // Output Register
    always @(posedge clk) begin
        col_max_out <= final_max_wire;
    end
endmodule
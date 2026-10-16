`timescale 1ns / 1ps

module min3 (
    input wire clk,
    input wire [7:0] in1,
    input wire [7:0] in2,
    input wire [7:0] in3,
    output reg [7:0] min_out
);
    reg [7:0] min_1_2;
    reg [7:0] in3_delay;

    always @(posedge clk) begin
        // Stage 1
        if (in1 < in2) min_1_2 <= in1;
        else           min_1_2 <= in2;
            
        in3_delay <= in3; 

        // Stage 2
        if (min_1_2 < in3_delay) min_out <= min_1_2;
        else                     min_out <= in3_delay;
    end
endmodule

module col_min_11 (
    input  wire clk,
    input  wire [7:0] p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,
    output reg  [7:0] col_min_out
);
    wire [7:0] min_012, min_345, min_678, min_910x;
    wire [7:0] min_L1_A, min_L1_B;
    
    // We pad the missing inputs with 8'hFF (255) so they never become the minimum
    min3 L1_inst0 (.clk(clk), .in1(p0), .in2(p1),  .in3(p2),    .min_out(min_012));
    min3 L1_inst1 (.clk(clk), .in1(p3), .in2(p4),  .in3(p5),    .min_out(min_345));
    min3 L1_inst2 (.clk(clk), .in1(p6), .in2(p7),  .in3(p8),    .min_out(min_678));
    min3 L1_inst3 (.clk(clk), .in1(p9), .in2(p10), .in3(8'hFF), .min_out(min_910x));

    min3 L2_inst0 (.clk(clk), .in1(min_012),  .in2(min_345), .in3(min_678), .min_out(min_L1_A));
    min3 L2_inst1 (.clk(clk), .in1(min_910x), .in2(8'hFF),   .in3(8'hFF),   .min_out(min_L1_B));

    wire [7:0] final_min_wire;
    min3 L3_inst0 (.clk(clk), .in1(min_L1_A), .in2(min_L1_B), .in3(8'hFF), .min_out(final_min_wire));

    always @(posedge clk) begin
        col_min_out <= final_min_wire;
    end
endmodule
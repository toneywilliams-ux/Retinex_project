`timescale 1ns / 1ps

module edge_preserving_filter (
    input  wire clk,
    // The 11 column minimums from the current window
    input  wire [7:0] p_ci_min_0, p_ci_min_1, p_ci_min_2, p_ci_min_3,
    input  wire [7:0] p_ci_min_4, p_ci_min_5, p_ci_min_6, p_ci_min_7,
    input  wire [7:0] p_ci_min_8, p_ci_min_9, p_ci_min_10,
    // The Guidance Image pixel (Maximum Channel)
    input  wire [7:0] g_i,
    
    // The final Refined Illumination pixel
    output reg  [7:0] f_m_out 
);

    // Wires to hold the N and D terms from the 11 filter nodes
    wire [14:0] n_terms [0:10];
    wire [14:0] d_terms [0:10];

    // 1. Instantiate the 11 Filter Nodes (Parallel Processing!)
    filter_node fn0  (.clk(clk), .p_ci_min(p_ci_min_0),  .g_i(g_i), .n_term(n_terms[0]),  .d_term(d_terms[0]));
    filter_node fn1  (.clk(clk), .p_ci_min(p_ci_min_1),  .g_i(g_i), .n_term(n_terms[1]),  .d_term(d_terms[1]));
    filter_node fn2  (.clk(clk), .p_ci_min(p_ci_min_2),  .g_i(g_i), .n_term(n_terms[2]),  .d_term(d_terms[2]));
    filter_node fn3  (.clk(clk), .p_ci_min(p_ci_min_3),  .g_i(g_i), .n_term(n_terms[3]),  .d_term(d_terms[3]));
    filter_node fn4  (.clk(clk), .p_ci_min(p_ci_min_4),  .g_i(g_i), .n_term(n_terms[4]),  .d_term(d_terms[4]));
    filter_node fn5  (.clk(clk), .p_ci_min(p_ci_min_5),  .g_i(g_i), .n_term(n_terms[5]),  .d_term(d_terms[5]));
    filter_node fn6  (.clk(clk), .p_ci_min(p_ci_min_6),  .g_i(g_i), .n_term(n_terms[6]),  .d_term(d_terms[6]));
    filter_node fn7  (.clk(clk), .p_ci_min(p_ci_min_7),  .g_i(g_i), .n_term(n_terms[7]),  .d_term(d_terms[7]));
    filter_node fn8  (.clk(clk), .p_ci_min(p_ci_min_8),  .g_i(g_i), .n_term(n_terms[8]),  .d_term(d_terms[8]));
    filter_node fn9  (.clk(clk), .p_ci_min(p_ci_min_9),  .g_i(g_i), .n_term(n_terms[9]),  .d_term(d_terms[9]));
    filter_node fn10 (.clk(clk), .p_ci_min(p_ci_min_10), .g_i(g_i), .n_term(n_terms[10]), .d_term(d_terms[10]));

    // 2. The Pipelined Adder Trees
    // We add these up in stages to maintain our 148.5 MHz timing
    
    // Stage 1 Registers
    reg [15:0] n_s1_0, n_s1_1, n_s1_2, n_s1_3, n_s1_4, n_s1_5;
    reg [15:0] d_s1_0, d_s1_1, d_s1_2, d_s1_3, d_s1_4, d_s1_5;
    
    always @(posedge clk) begin
        n_s1_0 <= n_terms[0] + n_terms[1]; d_s1_0 <= d_terms[0] + d_terms[1];
        n_s1_1 <= n_terms[2] + n_terms[3]; d_s1_1 <= d_terms[2] + d_terms[3];
        n_s1_2 <= n_terms[4] + n_terms[5]; d_s1_2 <= d_terms[4] + d_terms[5];
        n_s1_3 <= n_terms[6] + n_terms[7]; d_s1_3 <= d_terms[6] + d_terms[7];
        n_s1_4 <= n_terms[8] + n_terms[9]; d_s1_4 <= d_terms[8] + d_terms[9];
        n_s1_5 <= n_terms[10];             d_s1_5 <= d_terms[10];
    end

    // Stage 2 Registers
    reg [16:0] n_s2_0, n_s2_1, n_s2_2;
    reg [16:0] d_s2_0, d_s2_1, d_s2_2;
    
    always @(posedge clk) begin
        n_s2_0 <= n_s1_0 + n_s1_1; d_s2_0 <= d_s1_0 + d_s1_1;
        n_s2_1 <= n_s1_2 + n_s1_3; d_s2_1 <= d_s1_2 + d_s1_3;
        n_s2_2 <= n_s1_4 + n_s1_5; d_s2_2 <= d_s1_4 + d_s1_5;
    end

    // Stage 3 (Final Sum)
    reg [17:0] total_n;
    reg [17:0] total_d;
    
    always @(posedge clk) begin
        total_n <= n_s2_0 + n_s2_1 + n_s2_2;
        total_d <= d_s2_0 + d_s2_1 + d_s2_2;
    end

    // 3. The Division LUT (Lookup Table)
    // To calculate (Total N) / (Total D), we multiply Total N by (1 / Total D).
    // We store the pre-calculated values of (1 / Total D) inside FPGA Block RAM.
    
    reg [15:0] inverse_d_lut [0:65535]; // A Block RAM to hold inverse values
    
    // We load the pre-calculated math from a text file during synthesis
    initial begin
        $readmemh("inverse_lut.mem", inverse_d_lut);
    end
    
    // Read the inverse value from the LUT memory
    // We use the upper 16 bits of total_d as the memory address to save size
    wire [15:0] inverse_d_val = inverse_d_lut[total_d[17:2]]; 

    // 4. Final Multiplication to get F_m
    // F_m = N * (1/D)
    wire [33:0] f_m_calc = total_n * inverse_d_val;
    
    always @(posedge clk) begin
        // CORRECT bit extraction:
        // f_m_calc = total_n × LUT_val, where LUT_val = 2^16 / (total_d/4) = 2^18/total_d
        // total_n = (gamma × P_ci_min) >> 8
        // So f_m_calc = F_m_true * 2^10
        // The weighted average of P_ci_min lives in f_m_calc[17:10].
        // Extracting [25:18] divides by another 256, crushing F_m to 0!
        f_m_out <= f_m_calc[17:10]; 
    end

endmodule
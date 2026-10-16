`timescale 1ns / 1ps

module linear_approx_gamma (
    input  wire clk,
    input  wire [7:0] d,         // The distance 'd' = |P_ci_min - G_i|
    output reg  [14:0] gamma_out // Scaled by 2^14 as per the paper
);

    // We expand 'd' to 16 bits for the shift arithmetic to prevent overflow
    wire [15:0] d_ext = {8'b0, d};

    // Calculate all 8 equations in parallel (Combinational Logic)
    // Using the exact intercept and shift values from Fig. 4(a) of the paper
    wire [15:0] eq0 = 16'd16384 - ((d_ext << 8) + (d_ext << 7) + (d_ext << 5));
    wire [15:0] eq1 = 16'd13631 - ((d_ext << 7) + (d_ext << 6) + (d_ext << 3));
    wire [15:0] eq2 = 16'd10747 - ((d_ext << 7) + (d_ext << 4) + (d_ext << 2));
    wire [15:0] eq3 = 16'd7966  - ((d_ext << 6) + (d_ext << 4) + (d_ext << 3));
    wire [15:0] eq4 = 16'd5017  - ((d_ext << 5) + (d_ext << 3) + (d_ext << 2));
    wire [15:0] eq5 = 16'd2364  - (d_ext << 5);
    wire [15:0] eq6 = 16'd1053  - ((d_ext << 2) + (d_ext << 1));
    wire [15:0] eq7 = 16'd416;

    // Pipeline Register and Multiplexer (Fig. 4a output selector)
    always @(posedge clk) begin
        // We use the top 3 bits of 'd' (d[7:5]) to elegantly divide the 0-255 range 
        // into 8 equal segments of 32 values each. This creates a tiny, fast multiplexer.
        case (d[7:5])
            3'b000: gamma_out <= (eq0[15] == 1) ? 15'd0 : eq0[14:0]; // d: 0-31
            3'b001: gamma_out <= (eq1[15] == 1) ? 15'd0 : eq1[14:0]; // d: 32-63
            3'b010: gamma_out <= (eq2[15] == 1) ? 15'd0 : eq2[14:0]; // d: 64-95
            3'b011: gamma_out <= (eq3[15] == 1) ? 15'd0 : eq3[14:0]; // d: 96-127
            3'b100: gamma_out <= (eq4[15] == 1) ? 15'd0 : eq4[14:0]; // d: 128-159
            3'b101: gamma_out <= (eq5[15] == 1) ? 15'd0 : eq5[14:0]; // d: 160-191
            3'b110: gamma_out <= (eq6[15] == 1) ? 15'd0 : eq6[14:0]; // d: 192-223
            3'b111: gamma_out <= eq7[14:0];                          // d: 224-255
        endcase
    end

endmodule
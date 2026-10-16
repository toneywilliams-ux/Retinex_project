`timescale 1ns / 1ps

module illumination_modifier (
    input  wire clk,
    
    // The Reflectance channels from the previous module (CHANGE TO 16-BIT FIXED POINT!)
    input  wire [23:0] r_r,
    input  wire [23:0] r_g,
    input  wire [23:0] r_b,
    
    
    // The Refined Illumination from the Edge-Preserving Filter (Still 8-bit)
    input  wire [7:0] f_m,
    
    // The final enhanced RGB pixel output!
    output reg  [7:0] p_e_r,
    output reg  [7:0] p_e_g,
    output reg  [7:0] p_e_b
);

    // 1. The Contrast Stretch LUT (Still 8-bit)
    reg [7:0] e_mod_lut [0:255]; 
    
    initial begin
        $readmemh("e_mod_lut.mem", e_mod_lut);
    end

    // Fetch the modified illumination value based on F_m
    wire [7:0] e_mod_val = e_mod_lut[f_m];

    // 2. The Final Remapping (Multiplication)
    // P_E = E_mod (8 bits) * R (16 bits) = 24-bit product!
    wire [31:0] final_r = e_mod_val * r_r;
    wire [31:0] final_g = e_mod_val * r_g;
    wire [31:0] final_b = e_mod_val * r_b;


    // 3. Output Formatting
    always @(posedge clk) begin
        // Check the FULL 16-bit integer portion [31:16] for overflow!
        // If the true math result is > 255, we clamp it to 255 (Bright White).
        // Otherwise, we safely output the bottom 8 bits of the integer [23:16].
        p_e_r <= (final_r[31:16] > 255) ? 8'd255 : final_r[23:16];
        p_e_g <= (final_g[31:16] > 255) ? 8'd255 : final_g[23:16];
        p_e_b <= (final_b[31:16] > 255) ? 8'd255 : final_b[23:16];
    end
endmodule
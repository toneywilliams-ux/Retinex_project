`timescale 1ns / 1ps

module reflectance_calc (
    input  wire clk,
    // The original RGB pixels
    input  wire [7:0] p_r,
    input  wire [7:0] p_g,
    input  wire [7:0] p_b,
    
    // The Refined Illumination from the Edge-Preserving Filter
    input  wire [7:0] f_m,
    
    // ... other inputs ...
    // The output Reflectance channels (CHANGE FROM 8-BIT TO 16-BIT FIXED POINT!)
    // Change these to 24 bits!
    output reg  [23:0] r_r,
    output reg  [23:0] r_g,
    output reg  [23:0] r_b
       
);

    // 1. The Inverse F_m Lookup Table (LUT)
    reg [15:0] inverse_fm_lut [0:255]; 
    
    initial begin
        $readmemh("inverse_fm_lut.mem", inverse_fm_lut);
    end

    // Fetch the 1/F_m value. 
    wire [15:0] inv_fm_val = inverse_fm_lut[f_m];

    // 2. The Multipliers 
    // 8-bit pixel * 16-bit LUT value = 24-bit result.
    wire [23:0] calc_r = p_r * inv_fm_val;
    wire [23:0] calc_g = p_g * inv_fm_val;
    wire [23:0] calc_b = p_b * inv_fm_val;

    // 3. Output Formatting
    always @(posedge clk) begin
        r_r <= calc_r; 
        r_g <= calc_g; 
        r_b <= calc_b; 
    end
endmodule
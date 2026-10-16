`timescale 1ns / 1ps

module line_buffer_10x #(
    // Set this to your exact image width.
    // For simulation with a 100x100 image, this MUST be 100.
    // For real-time HD video, change to 1920.
    parameter LINE_LENGTH = 100 
)(
    input  wire clk,
    input  wire valid_in,
    input  wire [7:0] pixel_in,
    
    // 11 simultaneous outputs representing the same vertical column
    output wire [7:0] p_out_0,  // Current row (row 0, zero delay)
    output wire [7:0] p_out_1,  // Row -1
    output wire [7:0] p_out_2,  // Row -2
    output wire [7:0] p_out_3,  // Row -3
    output wire [7:0] p_out_4,  // Row -4
    output wire [7:0] p_out_5,  // Row -5
    output wire [7:0] p_out_6,  // Row -6
    output wire [7:0] p_out_7,  // Row -7
    output wire [7:0] p_out_8,  // Row -8
    output wire [7:0] p_out_9,  // Row -9
    output wire [7:0] p_out_10  // Row -10
);

    // Memory blocks for the 10 delay lines
    // Vivado will map these to Block RAM automatically
    reg [7:0] line_buf_1 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_2 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_3 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_4 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_5 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_6 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_7 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_8 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_9 [0:LINE_LENGTH-1];
    reg [7:0] line_buf_10[0:LINE_LENGTH-1];

    // Read/Write pointer
    reg [11:0] ptr = 0; // 12 bits accommodates up to 4095 pixels

    // Output registers
    reg [7:0] out_1, out_2, out_3, out_4, out_5, out_6, out_7, out_8, out_9, out_10;

    always @(posedge clk) begin
        if (valid_in) begin
            // 1. Read the old data from the current pointer location
            out_1  <= line_buf_1[ptr];
            out_2  <= line_buf_2[ptr];
            out_3  <= line_buf_3[ptr];
            out_4  <= line_buf_4[ptr];
            out_5  <= line_buf_5[ptr];
            out_6  <= line_buf_6[ptr];
            out_7  <= line_buf_7[ptr];
            out_8  <= line_buf_8[ptr];
            out_9  <= line_buf_9[ptr];
            out_10 <= line_buf_10[ptr];

            // 2. Write the new data into the current pointer location
            // The data cascades down the lines
            line_buf_1[ptr]  <= pixel_in;
            line_buf_2[ptr]  <= out_1;
            line_buf_3[ptr]  <= out_2;
            line_buf_4[ptr]  <= out_3;
            line_buf_5[ptr]  <= out_4;
            line_buf_6[ptr]  <= out_5;
            line_buf_7[ptr]  <= out_6;
            line_buf_8[ptr]  <= out_7;
            line_buf_9[ptr]  <= out_8;
            line_buf_10[ptr] <= out_9;

            // 3. Increment pointer, wrap around at end of line
            if (ptr == LINE_LENGTH - 1)
                ptr <= 0;
            else
                ptr <= ptr + 1;
        end
    end

    // Assign to continuous outputs
    assign p_out_0  = pixel_in; 
    assign p_out_1  = out_1;
    assign p_out_2  = out_2;
    assign p_out_3  = out_3;
    assign p_out_4  = out_4;
    assign p_out_5  = out_5;
    assign p_out_6  = out_6;
    assign p_out_7  = out_7;
    assign p_out_8  = out_8;
    assign p_out_9  = out_9;
    assign p_out_10 = out_10;

endmodule
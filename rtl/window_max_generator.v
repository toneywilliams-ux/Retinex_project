module window_max_generator (
    input  wire clk,
    input  wire valid_in,         // High when line buffers are outputting valid data
    input  wire [7:0] new_col_max, // From the col_max_11 module
    
    output wire [7:0] p_ci_out,   // The Coarse Illumination pixel!
    output reg        valid_out
);
    // The Register Set (C1 to C11 from the paper)
    reg [7:0] col_regs [0:10];
    integer i;

    // Shift Register Logic
    always @(posedge clk) begin
        if (valid_in) begin
            col_regs[0] <= new_col_max; // Newest column enters
            for (i = 0; i < 10; i = i + 1) begin
                col_regs[i+1] <= col_regs[i]; // Shift older columns right
            end
        end
    end

    // Use the exact same 11-input max tree logic to find the window max
    // Note: We instantiate col_max_11, but here it acts as our "window_max_11"
    col_max_11 find_window_max (
        .clk(clk),
        .p0 (col_regs[0]), .p1 (col_regs[1]), .p2 (col_regs[2]),  .p3 (col_regs[3]),
        .p4 (col_regs[4]), .p5 (col_regs[5]), .p6 (col_regs[6]),  .p7 (col_regs[7]),
        .p8 (col_regs[8]), .p9 (col_regs[9]), .p10(col_regs[10]),
        .col_max_out(p_ci_out)
    );

    // Delay the valid signal to match the pipeline latency of the max tree (7 clock cycles)
    reg [6:0] valid_delay;
    always @(posedge clk) begin
        valid_delay <= {valid_delay[5:0], valid_in};
        valid_out   <= valid_delay[6];
    end
endmodule

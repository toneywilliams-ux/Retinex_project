module rgb_to_gi (
    input wire clk,
    input wire [7:0] r_in,
    input wire [7:0] g_in,
    input wire [7:0] b_in,
    output reg [7:0] gi_out
);
    // Pipeline registers for the first stage of comparison
    reg [7:0] max_rg;
    reg [7:0] b_delay;

    always @(posedge clk) begin
        // Stage 1: Compare R and G, delay B to keep it in sync
        if (r_in > g_in)
            max_rg <= r_in;
        else
            max_rg <= g_in;
            
        b_delay <= b_in;

        // Stage 2: Compare the winner of (R,G) with B
        if (max_rg > b_delay)
            gi_out <= max_rg;
        else
            gi_out <= b_delay;
    end
endmodule
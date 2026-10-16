`timescale 1ns / 1ps

module filter_node (
    input  wire clk,
    input  wire [7:0] p_ci_min, // Minimum value of this specific column
    input  wire [7:0] g_i,      // Guidance image pixel (Maximum channel)
    
    output reg  [14:0] d_term,  // Output to the Denominator Adder Tree
    output reg  [14:0] n_term   // Output to the Numerator Adder Tree
);

    // 1. Calculate absolute difference 'd' and the condition beta_m
    reg [7:0] d;
    reg beta_m;
    
    always @(posedge clk) begin
        if (p_ci_min >= g_i) begin
            d <= p_ci_min - g_i;
            beta_m <= 1'b1;
        end else begin
            d <= g_i - p_ci_min;
            beta_m <= 1'b0;
        end
    end

    // 2. Instantiate the Linear Approximation Module
    wire [14:0] gamma_wire;
    linear_approx_gamma gamma_inst (
        .clk(clk),
        .d(d),
        .gamma_out(gamma_wire)
    );

    // We need to delay p_ci_min by TWO clock cycles to keep it in sync with
    // the gamma calculation pipeline:
    //   gamma_wire = f(d) where d was registered 1 cycle ago → gamma is 2 cycles from input
    //   beta_m_delay = beta_m registered again → also 2 cycles from input
    //   p_ci_min must also be 2 cycles from input for the multiplication to be correct
    reg [7:0] p_ci_min_d1;
    reg [7:0] p_ci_min_d2;
    reg beta_m_delay;
    always @(posedge clk) begin
        p_ci_min_d1    <= p_ci_min;       // 1-cycle delay
        p_ci_min_d2    <= p_ci_min_d1;    // 2-cycle delay — aligned with gamma_wire
        beta_m_delay   <= beta_m;
    end

    // 3. Calculate N and D terms (with the Multiplier shown in Fig 5)
    wire [14:0] selected_gamma = (beta_m_delay) ? gamma_wire : 15'd0;
    
    // The Numerator requires multiplying gamma by P_ci_min. 
    // gamma is 15 bits, p_ci_min_d2 is 8 bits. Result is 23 bits.
    wire [22:0] mult_result = selected_gamma * p_ci_min_d2;  // use 2-cycle delayed value

    always @(posedge clk) begin
        // Denominator path: Just pass the selected gamma
        d_term <= selected_gamma;
        
        // Numerator path: Shift right by 8 (as shown in Fig 5) to scale it down
        // We drop the bottom 8 bits, keeping the upper 15 bits.
        n_term <= mult_result[22:8]; 
    end

endmodule
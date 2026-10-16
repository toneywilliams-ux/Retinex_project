`timescale 1ns / 1ps

module retinex_top_level (
    input  wire clk,
    input  wire valid_in,
    input  wire [7:0] p_in_r,
    input  wire [7:0] p_in_g,
    input  wire [7:0] p_in_b,
    
    // Outputs
    output wire [7:0] p_out_r,
    output wire [7:0] p_out_g,
    output wire [7:0] p_out_b,
    output wire valid_out
);

    // Image width — change this when switching to a different resolution.
    // For 100x100 simulation: 100. For HD real-time: 1920.
    localparam IMG_W = 100;

    // --------------------------------------------------------
    // Internal Wires
    // --------------------------------------------------------
    wire [7:0] g_i;
    wire [7:0] p_ci;
    wire p_ci_valid;
    wire [7:0] f_m;
    wire [23:0] r_r, r_g, r_b; // 24-bit wires for high precision reflectance

    // Delayed g_i to align with the pci_min pipeline in edge_preserving_filter.
    // Path from g_i → pci_min_regs[0]:
    //   lb_gi read     : 1
    //   col_max_11     : 7
    //   wmg col_max_11 : 7
    //   wmg valid_delay: 3
    //   lb_pci read    : 1
    //   col_min_11     : 7
    //   pci_min_regs   : 1
    //   TOTAL          = 28 cycles
    localparam GI_DELAY = 28;
    reg [7:0] gi_pipe [0:GI_DELAY-1];
    integer gi_d;
    always @(posedge clk) begin
        gi_pipe[0] <= g_i;
        for (gi_d = 1; gi_d < GI_DELAY; gi_d = gi_d + 1)
            gi_pipe[gi_d] <= gi_pipe[gi_d-1];
    end

    // --------------------------------------------------------
    // 1. Maximum Channel Extraction (G_i)
    // --------------------------------------------------------
    rgb_to_gi max_extractor (
        .clk(clk),
        .r_in(p_in_r), .g_in(p_in_g), .b_in(p_in_b),
        .gi_out(g_i)
    );

    // --------------------------------------------------------
    // 2. Coarse Illumination (P_ci) - Window 1
    // --------------------------------------------------------
    wire [7:0] gi_col [0:10]; // Holds the 11 vertical pixels of G_i
    wire [7:0] gi_col_max;    // The maximum of those 11 pixels

    // Line buffer to hold 10 rows of G_i
    // LINE_LENGTH must equal the image width (100 for simulation, 1920 for HD video)
    line_buffer_10x #(.LINE_LENGTH(IMG_W)) lb_gi (
        .clk(clk), .valid_in(valid_in), .pixel_in(g_i),
        .p_out_0(gi_col[0]), .p_out_1(gi_col[1]), .p_out_2(gi_col[2]), .p_out_3(gi_col[3]),
        .p_out_4(gi_col[4]), .p_out_5(gi_col[5]), .p_out_6(gi_col[6]), .p_out_7(gi_col[7]),
        .p_out_8(gi_col[8]), .p_out_9(gi_col[9]), .p_out_10(gi_col[10])
    );

    // Find the max of the current column
    col_max_11 gi_max_tree (
        .clk(clk),
        .p0(gi_col[0]), .p1(gi_col[1]), .p2(gi_col[2]), .p3(gi_col[3]),
        .p4(gi_col[4]), .p5(gi_col[5]), .p6(gi_col[6]), .p7(gi_col[7]),
        .p8(gi_col[8]), .p9(gi_col[9]), .p10(gi_col[10]),
        .col_max_out(gi_col_max)
    );

    window_max_generator coarse_gen (
        .clk(clk),
        .valid_in(valid_in),
        .new_col_max(gi_col_max), // Feed the true column max here!
        .p_ci_out(p_ci),
        .valid_out(p_ci_valid)
    );

    // --------------------------------------------------------
    // 3. Edge-Preserving Filter (F_m) - Window 2
    // --------------------------------------------------------
    wire [7:0] pci_col [0:10]; // Holds the 11 vertical pixels of P_ci
    wire [7:0] pci_col_min;    // The minimum of those 11 pixels
    reg  [7:0] pci_min_regs [0:10]; // The 11 column minimums forming the window

    // Line buffer to hold 10 rows of P_ci
    line_buffer_10x #(.LINE_LENGTH(IMG_W)) lb_pci (
        .clk(clk), .valid_in(p_ci_valid), .pixel_in(p_ci),
        .p_out_0(pci_col[0]), .p_out_1(pci_col[1]), .p_out_2(pci_col[2]), .p_out_3(pci_col[3]),
        .p_out_4(pci_col[4]), .p_out_5(pci_col[5]), .p_out_6(pci_col[6]), .p_out_7(pci_col[7]),
        .p_out_8(pci_col[8]), .p_out_9(pci_col[9]), .p_out_10(pci_col[10])
    );

    // Find the min of the current column
    col_min_11 pci_min_tree (
        .clk(clk),
        .p0(pci_col[0]), .p1(pci_col[1]), .p2(pci_col[2]), .p3(pci_col[3]),
        .p4(pci_col[4]), .p5(pci_col[5]), .p6(pci_col[6]), .p7(pci_col[7]),
        .p8(pci_col[8]), .p9(pci_col[9]), .p10(pci_col[10]),
        .col_min_out(pci_col_min)
    );

    // Shift register to hold the 11 most recent column minimums
    integer i;
    always @(posedge clk) begin
        if (p_ci_valid) begin // Shift only on valid data
            pci_min_regs[0] <= pci_col_min;
            for (i = 0; i < 10; i = i + 1) begin
                pci_min_regs[i+1] <= pci_min_regs[i];
            end
        end
    end

    // Finally, feed the true spatial array into the filter!
    edge_preserving_filter ep_filter (
        .clk(clk),
        .p_ci_min_0(pci_min_regs[0]), .p_ci_min_1(pci_min_regs[1]), .p_ci_min_2(pci_min_regs[2]), 
        .p_ci_min_3(pci_min_regs[3]), .p_ci_min_4(pci_min_regs[4]), .p_ci_min_5(pci_min_regs[5]), 
        .p_ci_min_6(pci_min_regs[6]), .p_ci_min_7(pci_min_regs[7]), .p_ci_min_8(pci_min_regs[8]), 
        .p_ci_min_9(pci_min_regs[9]), .p_ci_min_10(pci_min_regs[10]),
        .g_i(gi_pipe[GI_DELAY-1]), // 27-cycle delayed g_i — aligned with pci_min window
        .f_m_out(f_m)
    );
    // --------------------------------------------------------
    // 4. Synchronization Delay Line
    //    The pipeline from raw pixel → f_m output spans 37 cycles:
    //      rgb_to_gi        : 2
    //      lb_gi read       : 1
    //      col_max_11       : 7  (3 levels of max3 × 2 stages + 1 out-reg)
    //      wmg col_max_11   : 7
    //      wmg valid_delay  : 3
    //      lb_pci read      : 1
    //      col_min_11       : 7
    //      pci_min_regs[0]  : 1
    //      filter_node      : 5  (d+β, gamma, p_ci_d2, selected_gamma, n/d-reg)
    //      EPF adder tree   : 3
    //      EPF LUT+mult+reg : 1
    //                TOTAL  = 38  cycles
    //
    //    We delay the raw RGB by 38 cycles so that when reflectance_calc
    //    multiplies (pixel × inv_fm), both values belong to the SAME
    //    spatial location.
    // --------------------------------------------------------
    localparam PIXEL_DELAY = 38;

    reg [7:0] r_delay [0:PIXEL_DELAY-1];
    reg [7:0] g_delay [0:PIXEL_DELAY-1];
    reg [7:0] b_delay [0:PIXEL_DELAY-1];

    integer d;
    always @(posedge clk) begin
        r_delay[0] <= p_in_r;
        g_delay[0] <= p_in_g;
        b_delay[0] <= p_in_b;
        for (d = 1; d < PIXEL_DELAY; d = d + 1) begin
            r_delay[d] <= r_delay[d-1];
            g_delay[d] <= g_delay[d-1];
            b_delay[d] <= b_delay[d-1];
        end
    end

    // --------------------------------------------------------
    // 5. Reflectance Calculation (Using properly delayed pixels)
    // --------------------------------------------------------
    reflectance_calc ref_calc (
        .clk(clk),
        .p_r(r_delay[PIXEL_DELAY-1]),  // 37-cycle delayed pixel — aligned with f_m
        .p_g(g_delay[PIXEL_DELAY-1]),
        .p_b(b_delay[PIXEL_DELAY-1]),
        .f_m(f_m),
        .r_r(r_r),
        .r_g(r_g),
        .r_b(r_b)
    );

    // --------------------------------------------------------
    // 6. Illumination Modifier (Final Output)
    // --------------------------------------------------------
    illumination_modifier final_mod (
        .clk(clk),
        .r_r(r_r), .r_g(r_g), .r_b(r_b),
        .f_m(f_m),
        .p_e_r(p_out_r), .p_e_g(p_out_g), .p_e_b(p_out_b)
    );
    
    // Output valid signal delayed by the entire pipeline length
    reg [PIXEL_DELAY+1:0] valid_pipe;
    always @(posedge clk) begin
        valid_pipe <= {valid_pipe[PIXEL_DELAY:0], valid_in};
    end
    assign valid_out = valid_pipe[PIXEL_DELAY+1];

endmodule
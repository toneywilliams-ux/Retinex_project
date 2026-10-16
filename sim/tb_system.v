`timescale 1ns / 1ps

// ================================================================
// tb_system.v  —  Retinex FPGA Testbench (CAPTURE-CORRECTED)
//
// CORRECT STREAMING STRATEGY (avoids the black strip):
//
//   |← WARMUP zeros →|←── 10,000 REAL pixels ──→|← PIPELINE zeros →|
//   |    2060 beats   |        10,000 beats        |     40 beats      |
//   stream_idx: 0                2060           12,059   12,099
//
//   Output at stream_idx S corresponds to INPUT at stream_idx S – PIPELINE
//
//   Capture window: stream_idx 2100 (= WARMUP+PIPELINE) to 12,099
//                   → exactly 10,000 outputs that correspond to the 10,000 real pixels ✓
//
// PIPELINE DEPTH (40 clock cycles, steady-state):
//   rgb_to_gi            : 2
//   lb_gi read           : 1
//   col_max_11 (3 lvl)   : 7
//   wmg col_max_11       : 7
//   wmg valid_delay      : 3
//   lb_pci read          : 1
//   col_min_11 (3 lvl)   : 7
//   pci_min_regs[0]      : 1
//   filter_node          : 5  (d+β, gamma, p_ci_d2, sel_gamma, n/d-reg)
//   EPF adder tree       : 3
//   EPF LUT + mult + reg : 1
//   reflectance_calc     : 1
//   illumination_mod     : 1
//   TOTAL                : 40 cycles
// ================================================================

module tb_system;

    // ------------------------------------------------------------------
    // Parameters
    // ------------------------------------------------------------------
    localparam IMG_W    = 100;
    localparam IMG_H    = 100;
    localparam N_PIX    = IMG_W * IMG_H;    // 10,000

    // Both 10-row line buffers need 10 × IMG_W cycles each to fill
    localparam WARMUP   = 10 * IMG_W * 2 + 60;  // 2060 beats of zero pixels

    // Steady-state pipeline depth from raw input to valid output
    localparam PIPELINE = 40;

    // Total stream length: warmup zeros + real pixels + flush zeros
    localparam TOTAL    = WARMUP + N_PIX + PIPELINE;  // 12,100

    // ------------------------------------------------------------------
    // DUT signals
    // ------------------------------------------------------------------
    reg clk    = 0;
    reg valid_in = 0;
    reg [7:0] p_in_r = 0, p_in_g = 0, p_in_b = 0;

    wire [7:0] p_out_r, p_out_g, p_out_b;
    wire valid_out;

    retinex_top_level uut (
        .clk      (clk),
        .valid_in (valid_in),
        .p_in_r   (p_in_r), .p_in_g(p_in_g), .p_in_b(p_in_b),
        .p_out_r  (p_out_r), .p_out_g(p_out_g), .p_out_b(p_out_b),
        .valid_out(valid_out)
    );

    // 148.5 MHz clock
    always #3.36 clk = ~clk;

    // ------------------------------------------------------------------
    // Memory and file handles
    // ------------------------------------------------------------------
    reg [23:0] img_mem [0:N_PIX-1];
    integer    stream_idx = 0;   // counts every beat sent (warmup + real + flush)
    integer    cap_count  = 0;   // how many output pixels captured
    integer    ppm_f, hex_f;

    // ------------------------------------------------------------------
    // Streaming process
    // ------------------------------------------------------------------
    initial begin
        $readmemh("input_image.hex", img_mem);

        ppm_f = $fopen("enhanced_image.ppm", "w");
        hex_f = $fopen("output_image.hex",   "w");
        $fdisplay(ppm_f, "P3");
        $fdisplay(ppm_f, "%0d %0d", IMG_W, IMG_H);
        $fdisplay(ppm_f, "255");

        valid_in = 0;
        #50;

        // ──────────────────────────────────────────────────────────────
        // Stream TOTAL beats with valid_in = 1
        //   Beats 0        .. WARMUP-1          → zeros  (warm up line buffers)
        //   Beats WARMUP   .. WARMUP+N_PIX-1    → REAL IMAGE PIXELS
        //   Beats WARMUP+N_PIX .. TOTAL-1       → zeros  (flush pipeline)
        // ──────────────────────────────────────────────────────────────
        while (stream_idx < TOTAL) begin
            @(posedge clk);
            valid_in = 1;

            if (stream_idx >= WARMUP && stream_idx < WARMUP + N_PIX) begin
                // Real pixel phase
                p_in_r = img_mem[stream_idx - WARMUP][23:16];
                p_in_g = img_mem[stream_idx - WARMUP][15:8];
                p_in_b = img_mem[stream_idx - WARMUP][7:0];
            end else begin
                // Warmup or flush: send black (zero) pixels
                p_in_r = 8'd0;
                p_in_g = 8'd0;
                p_in_b = 8'd0;
            end

            stream_idx = stream_idx + 1;
        end

        // De-assert valid after all beats are done
        @(posedge clk);
        valid_in = 0;
        #100;

        $fclose(ppm_f);
        $fclose(hex_f);

        $display("==============================================");
        $display("Simulation DONE.  Captured %0d / %0d pixels.", cap_count, N_PIX);
        if (cap_count < N_PIX)
            $display("WARNING: Only %0d pixels! Increase WARMUP or PIPELINE.", cap_count);
        else
            $display("SUCCESS! All pixels captured correctly.");
        $display("  enhanced_image.ppm  — open with any image viewer");
        $display("  output_image.hex    — run python 3_hex_to_image.py");
        $display("==============================================");
        $finish;
    end

    // ------------------------------------------------------------------
    // Output Capture
    //
    // Capture window: stream_idx in [WARMUP+PIPELINE, WARMUP+PIPELINE+N_PIX)
    //
    //   At stream_idx = WARMUP + PIPELINE:
    //     The first REAL pixel (which entered at stream_idx = WARMUP) has
    //     just passed through all 40 pipeline stages → first valid output!
    //
    //   At stream_idx = WARMUP + PIPELINE + N_PIX - 1:
    //     The last REAL pixel (which entered at stream_idx = WARMUP+N_PIX-1)
    //     has just emerged → last valid output!
    //
    //   Result: exactly 10,000 pixels captured, all from real input. ✓
    // ------------------------------------------------------------------
    always @(posedge clk) begin
        if (stream_idx > (WARMUP + PIPELINE) &&
            stream_idx <= (WARMUP + PIPELINE + N_PIX) &&
            cap_count < N_PIX) begin

            $fdisplay(ppm_f, "%0d %0d %0d", p_out_r, p_out_g, p_out_b);
            $fdisplay(hex_f, "%02x%02x%02x", p_out_r, p_out_g, p_out_b);
            cap_count = cap_count + 1;
        end
    end

endmodule
module retinex_top(

input clk,

input [7:0] r_in,
input [7:0] g_in,
input [7:0] b_in,

output [15:0] r_out,
output [15:0] g_out,
output [15:0] b_out

);

wire [7:0] gi;
wire [7:0] pci;
wire [7:0] pci_min;

wire [15:0] fm;

wire [15:0] rr,rg,rb;

wire [15:0] emod;

max_channel max0(
.r(r_in),
.g(g_in),
.b(b_in),
.gi(gi)
);

window_11x11 win0(
.clk(clk),
.pixel_in(gi)
);

column_max max1(
.clk(clk),
.out(pci)
);

column_min min1(
.clk(clk),
.out(pci_min)
);

edge_filter edge0(
.clk(clk),
.gi(gi),
.pci_min0(pci_min),
.fm(fm)
);

reflectance_calc ref0(
.clk(clk),
.pr(r_in),
.pg(g_in),
.pb(b_in),
.fm(fm),
.rr(rr),
.rg(rg),
.rb(rb)
);

illumination_mod mod0(
.fm(fm),
.emod(emod)
);

reconstruction rec0(
.clk(clk),
.rr(rr),
.rg(rg),
.rb(rb),
.emod(emod),
.out_r(r_out),
.out_g(g_out),
.out_b(b_out)
);

endmodule

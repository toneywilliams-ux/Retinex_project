module tb_retinex;

reg clk;

reg [7:0] r;
reg [7:0] g;
reg [7:0] b;

wire [15:0] r_out;
wire [15:0] g_out;
wire [15:0] b_out;

retinex_top DUT(

.clk(clk),

.r_in(r),
.g_in(g),
.b_in(b),

.r_out(r_out),
.g_out(g_out),
.b_out(b_out)

);

always #5 clk = ~clk;

initial
begin

clk = 0;

r = 8'd40;
g = 8'd30;
b = 8'd20;

#100;

r = 8'd60;
g = 8'd50;
b = 8'd40;

#100;

$finish;

end

endmodule

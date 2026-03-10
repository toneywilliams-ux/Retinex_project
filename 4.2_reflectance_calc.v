module reflectance_calc(

input clk,

input [7:0] pr,
input [7:0] pg,
input [7:0] pb,

input [7:0] fm,

output reg [15:0] rr,
output reg [15:0] rg,
output reg [15:0] rb

);

wire [15:0] inv_fm;

reciprocal_lut lut0(fm,inv_fm);

always @(posedge clk)
begin

rr <= pr * inv_fm;
rg <= pg * inv_fm;
rb <= pb * inv_fm;

end

endmodule

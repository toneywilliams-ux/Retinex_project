module reconstruction(

input clk,

input [15:0] rr,
input [15:0] rg,
input [15:0] rb,

input [15:0] emod,

output reg [15:0] out_r,
output reg [15:0] out_g,
output reg [15:0] out_b

);

always @(posedge clk)
begin

out_r <= rr * emod;
out_g <= rg * emod;
out_b <= rb * emod;

end

endmodule

module weight_calc
(
input clk,
input [7:0] pci,
input [7:0] gi,
output reg [15:0] weight
);

wire beta;
wire [7:0] diff;
wire [15:0] gamma;

assign beta = (pci >= gi);
assign diff = (pci > gi) ? (pci-gi):(gi-pci);

exp_approx exp0(diff,gamma);

always @(posedge clk)
begin
if(beta)
weight <= gamma;
else
weight <= 0;
end

endmodule

module edge_filter
(
input clk,

input [7:0] gi,

input [7:0] pci_min0,
input [7:0] pci_min1,
input [7:0] pci_min2,
input [7:0] pci_min3,
input [7:0] pci_min4,
input [7:0] pci_min5,
input [7:0] pci_min6,
input [7:0] pci_min7,
input [7:0] pci_min8,
input [7:0] pci_min9,
input [7:0] pci_min10,

output reg [15:0] fm
);

reg [15:0] numerator;
reg [15:0] denominator;

wire [15:0] w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10;

weight_calc W0(clk,pci_min0,gi,w0);
weight_calc W1(clk,pci_min1,gi,w1);
weight_calc W2(clk,pci_min2,gi,w2);
weight_calc W3(clk,pci_min3,gi,w3);
weight_calc W4(clk,pci_min4,gi,w4);
weight_calc W5(clk,pci_min5,gi,w5);
weight_calc W6(clk,pci_min6,gi,w6);
weight_calc W7(clk,pci_min7,gi,w7);
weight_calc W8(clk,pci_min8,gi,w8);
weight_calc W9(clk,pci_min9,gi,w9);
weight_calc W10(clk,pci_min10,gi,w10);

always @(posedge clk)
begin

numerator <=
w0*pci_min0 +
w1*pci_min1 +
w2*pci_min2 +
w3*pci_min3 +
w4*pci_min4 +
w5*pci_min5 +
w6*pci_min6 +
w7*pci_min7 +
w8*pci_min8 +
w9*pci_min9 +
w10*pci_min10;

denominator <=
w0+w1+w2+w3+w4+w5+w6+w7+w8+w9+w10;

fm <= numerator / denominator;

end

endmodule

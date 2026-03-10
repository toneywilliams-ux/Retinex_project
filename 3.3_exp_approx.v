module exp_approx
(
input [7:0] x,
output reg [15:0] y
);

always @(*)
begin

if(x<32)
y = 65535 - (x<<8);

else if(x<64)
y = 45000 - (x<<7);

else if(x<96)
y = 30000 - (x<<6);

else
y = 0;

end

endmodule

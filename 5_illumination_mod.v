module illumination_mod(

input [7:0] fm,
output reg [15:0] emod

);

always @(*) begin

case(fm)

8'd0: emod = 0;
8'd10: emod = 16'd5120;
8'd20: emod = 16'd8192;
8'd40: emod = 16'd12000;

default: emod = fm << 8;

endcase

end

endmodule

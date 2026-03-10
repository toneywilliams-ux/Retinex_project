module reciprocal_lut(
input [7:0] fm,
output reg [15:0] inv_fm
);

always @(*) begin

case(fm)

8'd1:  inv_fm = 16'd65535;
8'd2:  inv_fm = 16'd32768;
8'd3:  inv_fm = 16'd21845;
8'd4:  inv_fm = 16'd16384;

default: inv_fm = 16'd1;

endcase

end

endmodule

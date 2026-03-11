module column_max_11(

input  [7:0] w0,
input  [7:0] w1,
input  [7:0] w2,
input  [7:0] w3,
input  [7:0] w4,
input  [7:0] w5,
input  [7:0] w6,
input  [7:0] w7,
input  [7:0] w8,
input  [7:0] w9,
input  [7:0] w10,

output [7:0] col_max

);

wire [7:0] m1,m2,m3,m4,m5;
wire [7:0] m6,m7,m8;

assign m1 = (w0>w1)?w0:w1;
assign m2 = (w2>w3)?w2:w3;
assign m3 = (w4>w5)?w4:w5;
assign m4 = (w6>w7)?w6:w7;
assign m5 = (w8>w9)?w8:w9;

assign m6 = (m1>m2)?m1:m2;
assign m7 = (m3>m4)?m3:m4;

assign m8 = (m6>m7)?m6:m7;

assign col_max = (m8>w10)?m8:w10;

endmodule

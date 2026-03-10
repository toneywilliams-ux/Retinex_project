module window_11x11 #
(
parameter IMG_WIDTH = 1920
)
(
input clk,
input [7:0] pixel_in,

output reg [7:0] w00,w01,w02,w03,w04,w05,w06,w07,w08,w09,w10,
output reg [7:0] w10,w11,w12,w13,w14,w15,w16,w17,w18,w19,w110,
output reg [7:0] w20,w21,w22,w23,w24,w25,w26,w27,w28,w29,w210,
output reg [7:0] w30,w31,w32,w33,w34,w35,w36,w37,w38,w39,w310,
output reg [7:0] w40,w41,w42,w43,w44,w45,w46,w47,w48,w49,w410,
output reg [7:0] w50,w51,w52,w53,w54,w55,w56,w57,w58,w59,w510,
output reg [7:0] w60,w61,w62,w63,w64,w65,w66,w67,w68,w69,w610,
output reg [7:0] w70,w71,w72,w73,w74,w75,w76,w77,w78,w79,w710,
output reg [7:0] w80,w81,w82,w83,w84,w85,w86,w87,w88,w89,w810,
output reg [7:0] w90,w91,w92,w93,w94,w95,w96,w97,w98,w99,w910,
output reg [7:0] w100,w101,w102,w103,w104,w105,w106,w107,w108,w109,w1010
);

wire [7:0] lb1,lb2,lb3,lb4,lb5,lb6,lb7,lb8,lb9,lb10;

line_buffer #(IMG_WIDTH) L1(clk,pixel_in,lb1);
line_buffer #(IMG_WIDTH) L2(clk,lb1,lb2);
line_buffer #(IMG_WIDTH) L3(clk,lb2,lb3);
line_buffer #(IMG_WIDTH) L4(clk,lb3,lb4);
line_buffer #(IMG_WIDTH) L5(clk,lb4,lb5);
line_buffer #(IMG_WIDTH) L6(clk,lb5,lb6);
line_buffer #(IMG_WIDTH) L7(clk,lb6,lb7);
line_buffer #(IMG_WIDTH) L8(clk,lb7,lb8);
line_buffer #(IMG_WIDTH) L9(clk,lb8,lb9);
line_buffer #(IMG_WIDTH) L10(clk,lb9,lb10);

always @(posedge clk)
begin

// shift registers for window

w00 <= pixel_in;
w10 <= lb1;
w20 <= lb2;
w30 <= lb3;
w40 <= lb4;
w50 <= lb5;
w60 <= lb6;
w70 <= lb7;
w80 <= lb8;
w90 <= lb9;
w100 <= lb10;

// horizontal shifting

w01 <= w00;
w02 <= w01;
w03 <= w02;
w04 <= w03;
w05 <= w04;
w06 <= w05;
w07 <= w06;
w08 <= w07;
w09 <= w08;
w10 <= w09;

end

endmodule

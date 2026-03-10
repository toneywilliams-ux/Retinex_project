module max_channel(
    input  [7:0] r,
    input  [7:0] g,
    input  [7:0] b,
    output [7:0] gi
);

assign gi = (r>g) ? ((r>b)? r:b) : ((g>b)? g:b);

endmodule

module line_buffer #
(
    parameter WIDTH = 1920
)
(
    input clk,
    input [7:0] din,
    output [7:0] dout
);

reg [7:0] mem [0:WIDTH-1];
reg [11:0] ptr;

always @(posedge clk)
begin
    mem[ptr] <= din;
    ptr <= ptr + 1;
end

assign dout = mem[ptr];

endmodule

`ifndef REGFILE
`define REGFILE

module regfile(
    input           clk,
    input           rst,
    input           we,
    input[31:0]     write,
    input[4:0]      ra1,
    input[4:0]      ra2,
    input[4:0]      wa,

    output[31:0]    read1,
    output[31:0]    read2
);

// test
initial begin
    x[1] = 32'd3;
    x[2] = 32'd2;
end

reg[31:0]  x[31:0];
initial x[0] = 32'd0;

always @(posedge clk) begin
end

assign read1 = x[ra1];
assign read2 = x[ra2];

endmodule

`endif
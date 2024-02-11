`ifndef ALU
`define ALU

module alu32(
    input[9:0]      ctrl,
    input[31:0]     a,
    input[31:0]     b,

    output[31:0]    r,
    output          ze,
    output          c,
    output          branch
);

parameter[9:0]   add     = 10'h000;
parameter[9:0]   sub     = 10'h100;

assign r =  (ctrl == add)?a+b:
            (ctrl == sub)?a-b:
            0;

// test
always @(*) begin
    $display("---");
    $display("ALu");
    $display(a);
    $display(b);
    $display(ctrl);
    $display(r);
    $display("---");
end

endmodule

`endif
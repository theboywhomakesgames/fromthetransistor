`timescale 1ns/1ps

`include "riscv.v"

module riscv_testbench;

    parameter CLK_FREQ = 27000000;

    reg clk, rst;

    riscv cpu(
        .clk(clk)
    );

    always #(1) clk = ~clk;

    initial begin
        clk <= 1'b0;

        $dumpfile("waveform.vcd");
        $dumpvars(0, cpu);

        #10
        $finish;
    end

endmodule
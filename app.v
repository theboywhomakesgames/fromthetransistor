`ifndef TOP
`define TOP

`include "uart.v"

module top
(
    input clk,
    input rst_n,
    input rx_pin,
    output tx_pin,
    output [5:0] led
);

localparam WAIT_TIME = 13500000;
reg [23:0] clockCounter = 0;

wire[7:0] uart_data;
wire data_valid;
wire[5:0] led_debugger;

assign led = led_debugger;

uart debugger(
    clk,
    rst_n,
    rx_pin,
    tx_pin,
    uart_data,
    data_valid,
    led_debugger
);

endmodule

`endif
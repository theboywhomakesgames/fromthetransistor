`ifndef TOP
`define TOP

`include "uart.v"
`include "bus.v"

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

wire[13:0]      bus_address;
wire[31:0]      bus_datai;
wire[31:0]      bus_datao;
wire[7:0]       bus_control;
wire[31:0]      bus_req;
wire[31:0]      bus_usearr;

wire[31:0]      bus_available;

wire idle;
wire fulfilled;

wire[1:0]       mem_state;

// assign led[0] = ~idle;
// assign led[1] = ~bus_req[0];
// assign led[2] = ~bus_usearr[0];
// assign led[3] = ~bus_available[0];
// // assign led[4] = ~fulfilled;
// assign led[5:4] = ~mem_state;

// assign led = ~reqidx;

// assign led[5:0] = ~bus_datao[5:0];

BUS mem_bus(
    clk,
    rst_n,

    bus_address,
    bus_datai,
    bus_datao,
    bus_control,

    bus_req,
    bus_usearr,

    bus_available,
    idle,
    fulfilled,
    mem_state
);

uart debugger(
    clk,
    rst_n,
    rx_pin,
    tx_pin,
    uart_data,
    data_valid,

    bus_address,
    bus_datai,
    bus_datao,
    bus_control,

    bus_req[0],
    bus_usearr[0],
    bus_available[0],
    fulfilled
);

endmodule

`endif
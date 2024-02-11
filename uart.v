`ifndef UART_MODULE
`define UART_MODULE

`include "uart_rx.v"
`include "uart_tx.v"

module uart(
    input                   clk,
    input                   rst_n,
    input                   rx_pin,
    output                  tx_pin,
    output reg[7:0]         data,
    output wire             rx_data_valid,
    output [5:0]            led
);

parameter CLK_FREQ=         27000000;
parameter BAUD_RATE=        4800;
parameter CLKS_PER_BIT=     5625;

wire[7:0]   rx_data;
reg         rx_data_ready;

wire        tx_ready;

reg         tx_valid;
reg         ready;
reg[7:0]    tx_data;

// uart test
reg [7:0] buffer[0:64];
reg [7:0] bufferidx;

wire[7:0] idx;
assign idx = bufferidx;

uart_rx#(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) rx(
    .clk(clk),
    .rst_n(rst_n),
    .rx_data(rx_data),
    .rx_data_valid(rx_data_valid),
    .rx_data_ready(rx_data_ready),
    .rx_pin(rx_pin)
);

uart_tx#(
    .CLK_FRE(27),
    .BAUD_RATE(BAUD_RATE)
) tx(clk, rst_n, tx_data, tx_valid, tx_ready, tx_pin, led[5:0]);

// clock counter
reg[31:0] cc;

// tx_valid set
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        buffer[0] <= 8'h48; // 'H'
        buffer[1] <= 8'h65; // 'e'
        buffer[2] <= 8'h6C; // 'l'
        buffer[3] <= 8'h6C; // 'l'
        buffer[4] <= 8'h6F; // 'o'
        buffer[5] <= 8'h6F; // 'o'
        buffer[6] <= 8'h00; // NULL
        $display("set");

        ready <= 1'b0;
        tx_valid <= 1'b0;
        rx_data_ready <= 1'b1;
        cc <= 32'd0;
    end

    // keep tx_valid on for one uart cycle
    else if (cc == CLKS_PER_BIT - 1)
    begin
        if(tx_valid == 1'b1)    tx_valid <= 1'b0;
        else if(put == 1'b1)    tx_valid <= 1'b1;
        else                    tx_valid <= tx_valid;

        cc <= 32'd0;
    end

    else 
    begin
        tx_valid <= tx_valid;
        cc <= cc + 32'd1;
    end
end

// put char
reg put;
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        bufferidx <= 8'd0;
        put = 1'b0;
    end
    else if(tx_ready == 1'b1 && tx_valid == 1'b0)
    begin
        tx_data <= buffer[idx];
        bufferidx <= bufferidx + 8'd1;
        put <= 1'b1;
    end
    else
    begin
        put = 1'b0;
        tx_data <= tx_data;
        bufferidx <= bufferidx;
    end
end

endmodule

`endif

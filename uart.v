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

    inout wire[13:0]        bus_address,
    output wire[31:0]       bus_datai,
    input wire[31:0]        bus_datao,
    inout wire[7:0]         bus_control,

    output reg              bus_req,
    output reg              bus_use,
    input                   bus_available,
    input                   fulfilled
);

parameter CLK_FREQ=         27000000;
parameter BAUD_RATE=        115200;
parameter CLKS_PER_BIT=     234;

wire[7:0]   rx_data;
reg         rx_data_ready;

wire        tx_ready;

reg         tx_valid;
reg         ready;
reg[7:0]    tx_data;

reg[7:0] buffer[3:0];
// uart test
reg [2:0] bufferidx;

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
) tx(clk, rst_n, tx_data, tx_valid, tx_ready, tx_pin);

// clock counter
reg[31:0] cc;
reg[31:0] cc1;

assign bus_control = 8'd0;
assign bus_address = 32'h00000041;

// initialize
always @(negedge rst_n)
begin
    rx_data_ready <= 1'b1;
end

// make ready
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        ready <= 1'b0;
        cc1 <= 32'd0;
    end
    else if(cc1 == CLK_FREQ)
    begin
        ready <= 1'b1;
        cc1 <= 32'd0;
    end
    else
    begin
        ready <= ready;
        cc1 <= cc1 + 32'd1;
    end
end

// tx_valid set
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        tx_valid <= 1'b0;
        cc <= 32'd0;
    end

    // keep tx_valid on for one uart cycle
    else if (cc == CLKS_PER_BIT - 1)
    begin
        if(tx_valid == 1'b1) tx_valid <= 1'b0;
        else if(put == 1'b1) tx_valid <= 1'b1;
        else            tx_valid <= tx_valid;

        cc <= 32'd0;
    end

    else 
    begin
        tx_valid <= tx_valid;
        cc <= cc + 32'd1;
    end
end

// buffer data
reg buffered;
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        // TODO: change to 0 after test
        buffered <= 1'b0;
        bus_use <= 1'b0;
        bus_req <= 1'b0;
    end

    else if(ready == 1'b1)
    begin
        if(bus_available == 1'b0 && buffered == 1'b0)
        begin
            buffered <= 1'b0;
            bus_use <= 1'b0;
            bus_req <= 1'b1;
        end

        // req approved but not using
        // start using
        else if(bus_req == 1'b1 && bus_available == 1'b1 && bus_use == 1'b0)
        begin
            buffered <= 1'b0;
            bus_use <= 1'b1;
            bus_req <= 1'b0;
        end

        // using
        else if(bus_use == 1'b1)
        begin
            // not fulfilled
            // keep using
            if(fulfilled == 1'b0)
            begin
                buffered <= 1'b0;
                bus_use <= 1'b1;
            end

            // fulfilled
            // buffer up - stop using
            else
            begin
                buffer[0] <= bus_datao[31:24];
                buffer[1] <= bus_datao[23:16];
                buffer[2] <= bus_datao[15: 8];
                buffer[3] <= bus_datao[ 7: 0];

                buffered <= 1'b1;
                bus_use <= 1'b0;
            end

            // no req while using
            bus_req <= 1'b0;
        end

        // waiting for availability
        else
        begin
            buffered <= buffered;
            bus_use <= bus_use;
            bus_req <= bus_req;
        end
    end

    // in initial wait phase
    else
    begin
        buffered <= buffered;
        bus_use <= bus_use;
        bus_req <= bus_req;
    end
end

// put char
reg put;
reg [1:0]   idx_latch;

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        put <= 1'b0;
        bufferidx <= 3'd0;
    end

    // TODO: execution not in sync with buffering
    // TODO: Buffer idx condition not working
    // TODO: it's printing more than buffer size?!?!?
    else if(
        tx_ready == 1'b1 &&
        tx_valid == 1'b0 &&
        put == 1'b0 &&
        ready == 1'b1 &&
        bufferidx < 4 &&
        buffered == 1'b1
    )
    begin
        idx_latch <= bufferidx;
        tx_data <= buffer[idx_latch];

        put <= 1'b1;
        bufferidx <= bufferidx + 3'd1;
    end

    else if(cc == CLKS_PER_BIT - 1 && put == 1'b1 && tx_valid == 1'b0)
    begin
        put <= 1'b0;
        bufferidx <= bufferidx;
    end

    else if(bufferidx == 4 && put == 1'b0)
    begin
        put <= 1'b0;
        bufferidx <= bufferidx;
    end

    else
    begin
        put <= put;
        bufferidx <= bufferidx;
    end
end

endmodule

`endif

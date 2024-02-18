`ifndef MEM
`define MEM

module ram(
    input                   clk,        // clock
    input                   rst_n,

    input[13:0]             address,    // read/write address
    input[31:0]             write,      // data to be written
    input                   we,         // write enabled
    input                   available,  // write enabled

    output wire[31:0]       read,       // output of memory
    output reg              ready,
    output reg              output_available,
    output reg[1:0]         state
);

localparam IDLE     = 0;
localparam IO       = 1;
localparam CLEAN    = 2;

// BSRAM =========================================
wire[31:0]  dout_o;

reg         oce_i; // useless in bypass mode
reg         ce_i;
reg         wre_i;
reg[13:0]   ad_i;
reg[31:0]   din_i;

Gowin_SP mem(
    .dout(dout_o), //output [31:0] dout
    .clk(clk), //input clk
    .oce(oce_i), //input oce
    .ce(ce_i), //input ce
    .reset(rst_n), //input reset
    .wre(wre_i), //input wre
    .ad(ad_i), //input [13:0] ad
    .din(din_i) //input [31:0] din
);
// ===============================================

reg[13:0] address_latch;
reg[31:0] data_latch;

// reg[1:0] state;
reg[1:0] next_state = 0; // default idle

assign read = data_latch;

// state machine
always @(negedge clk)
begin
    case(state)
    // IDLE - 1 clock
    IDLE:
        // if available goto next
        if(available == 1'b1)
            next_state <= IO;
        // else no change
        else
            next_state <= next_state;

    // IO
    IO:
        next_state <= CLEAN;

    // CLEAN
    CLEAN:
        // clean
        next_state <= IDLE;

    default:
        next_state <= IDLE;

    endcase
end

// next state put
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        state <= IDLE;
    end
    else
    begin
        state <= next_state;
    end
end

// enable/disable clk/chip, latching
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        ready <= 1'b1;
        oce_i <= 1'b0;
        ce_i <= 1'b0;
        output_available <= 1'b0;
    end
    else if(state == IDLE && available == 1'b1)
    begin
        ready <= 1'b0;
        output_available <= 1'b0;

        oce_i <= 1'b0;
        oce_i <= 1'b1;
        ce_i <= 1'b1;

        // latch address
        address_latch <= address;

        // latch data if write
        if(we == 1'b1)
            data_latch <= write;
    end
    else if(state == CLEAN)
    begin
        // latch output
        if(we == 1'b0)
            data_latch <= address_latch;

        oce_i <= 1'b0;
        ce_i <= 0'b0;
        output_available <= 1'b1;
        ready <= ready;
    end
    else
    begin
        output_available <= output_available;
        ready <= ready;
        oce_i <= oce_i;
        ce_i <= ce_i;
    end
end

// address/ wrtie/ din
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        ad_i <= 14'd0;
        wre_i <= 1'b0;
        din_i <= 32'd0;
    end
    else if(state == IO)
    begin
        // if WE write
        if(we == 1'b1)
        begin
            ad_i <= address_latch;
            wre_i <= 1'b1;
            din_i <= data_latch;
        end
        // else read => put address and read in clean
        else
        begin
            ad_i <= address_latch;
            wre_i <= 1'b0;
            din_i <= din_i;
        end
    end
    else
    begin
        ad_i <= ad_i;
        wre_i <= wre_i;
        din_i <= din_i;
    end
end

endmodule

`endif

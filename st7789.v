`ifndef ST7789
`define ST7789

`define NOP       h00
`define SWRESET   h01

`define RDDID     h04
`define RDDST     h09
`define RDDPM     h0a
`define RDDMADCTL h0b
`define RDDCOLMOD h0c
`define RDDIM     h0d
`define RDDSM     h0e
`define RDDSDR    h0f

`define SLPIN     h10 // sleep in
`define SLPOUT    h11 // sleep out

`define PTLON     h12 // partial on
`define NORON     h13 // partial off

`define INVOFF    h20
`define INVON     h21
`define GAMSET    h26

`define DISPOFF   h28
`define DISPON    h29

`define CASET     h2a // column set
`define RASET     h2b // row set
`define RAMWR     h2c // ram write
`define RAMRD     h2e // ram read

`define COLMOD    h3a // color mode
`define MADCTL    h36 // memory access control

`define S_INIT    0
`define S_IDLE    1
`define S_CMND    2
`define S_DATA    3

module st7789_spi(
  input wire clk,
  input wire rst_n,

  output reg scl,
  output reg sda,
  output reg dc,
  output reg rst
);

assign scl <= ~clk;

reg[1:0] state;

localparam T_IDLE =     0;
localparam T_FIRST =    1;
localparam T_DATA =     2;

reg [7:0] byte_buffer;
reg [1:0] t_state;
reg available_byte;
reg [2:0] bit_cnt;

// transmitter
always @(posedge clk or negedge rst_n)
begin
  if(rst_n == 1'b0)
  begin
    t_state = T_IDLE;
    sda <= 1'b0;
    transmitter_ready <= 1'b1;
    bit_cnt <= 3'd0;
  end
  else if(available_byte == 1'b1)
  begin
    case(t_state)
      // we don't really need an idle state
      T_IDLE:
      begin
        if(available_byte == 1'b1)
        begin
          transmitter_ready <= 1'b0;
          t_state <= T_FIRST;
        end
        else
        begin
          transmitter_ready <= 1'b1;
          t_state <= T_IDLE;
        end

        sda <= 1'b0;
        bit_cnt <= 3'd0;
      end
      T_FIRST:
      begin
        transmitter_ready <= 1'b0;
        t_state <= T_DATA;
        sda <= byte_buffer[bit_cnt];
        bit_cnt <= 3'd1;
      end
      T_DATA:
      begin
        transmitter_ready <= 1'b0;
        sda <= byte_buffer[bit_cnt];

        if(bit_cnt == 3'd7)
        begin
          // end of transmition
          t_state <= T_IDLE;
        end
        else
        begin

        end
      end
    endcase
  end
  else
  begin
    sda <= sda;
    transmitter_ready <= transmitter_ready;
  end
end

// state manager
always @(*)
begin
  case(state):
    S_INIT:
    S_IDLE:
    S_CMND:
    S_DATA:
end

always @(posedge clk or negedge rst_n)
begin
  if(rst_n == 1'b0)
  begin
  end
end

`endif

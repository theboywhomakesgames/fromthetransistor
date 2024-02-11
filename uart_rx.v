`ifndef UART_RX
`define UART_RX

module uart_rx
#(
    parameter CLKS_PER_BIT = 240
)
(
    input                       clk,
    input                       rst_n,
    output      reg[7:0]        rx_data,
    output      reg             rx_data_valid,
    input                       rx_data_ready,
    input                       rx_pin
);

// state machine codes
parameter   S_IDLE=         0;  // idle
parameter   S_START=        1;  // start bit
parameter   S_REC_BYTE=     2;  // data bits
parameter   S_STOP=         3;  // stop bits
parameter   S_CLEAN=        4;  // clean up

localparam CYCLE_CLOCK =        CLKS_PER_BIT - 1;
localparam CYCLE_CLOCK_HALF =   CLKS_PER_BIT/2 - 1;

reg[2:0]                        state;
reg[2:0]                        next_state;
reg[2:0]                        bit_cnt;
reg[23:0]                       clk_count;
reg[7:0]                        data_latch;

reg                             rx_d_old;
reg                             rx_d_cur;

wire                            data_negedge;

assign data_negedge = rx_d_old && ~rx_d_cur;

// State Machine
always @(*)
begin
    case(state)
        // Idle
        S_IDLE:
            // Go next if start bit seen
            if(data_negedge)
                next_state <= S_START;
            else
                next_state <= S_IDLE;

        // Start-Bit
        S_START:
            // wait 1 cycle and go next
            if(clk_count == CYCLE_CLOCK)
                next_state <= S_REC_BYTE;
            else
                next_state <= S_START;

        // Data-Bits
        S_REC_BYTE:
            // Capture 8 bits of Data
            if(clk_count == CYCLE_CLOCK && bit_cnt == 3'd7)
                next_state <= S_STOP;
            else
                next_state <= S_REC_BYTE;

        // Stop-Bit
        S_STOP:
            // Goto clean up before next cycle
            // Otherwise you'll miss the next byte
            // because the data is still coming
            // but you are spending a cycle putting bits
            // into output of the module

            if(clk_count == CYCLE_CLOCK_HALF)
                next_state <= S_CLEAN;
            else
                next_state <= S_STOP;

        S_CLEAN:
        // Clean-Up
            // if module is on goto next (no waiting for clock)
            if(rx_data_ready)
                next_state <= S_IDLE;
            else
                next_state <= S_CLEAN;
        
        default:
            next_state <= S_IDLE;
    endcase
end

// bit holder (for neg edge)
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        rx_d_old <= 0;
        rx_d_cur <= 0;        
    end
    else
    begin
        rx_d_old <= rx_d_cur;
        rx_d_cur <= rx_pin;
    end
end

// state shifter
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        state <= S_IDLE;
    end
    else
    begin
        state <= next_state;
    end
end

// data bit counter
always @(posedge clk or negedge rst_n)
begin
    // if reset hit -> reset
    if(rst_n == 1'b0)
    begin
        bit_cnt <= 3'd0;
    end
    // ++ on cycle
    else if(state == S_REC_BYTE)
        if(clk_count == CYCLE_CLOCK)
            bit_cnt <= bit_cnt + 3'd1;
        else
            bit_cnt <= bit_cnt;
    else
        bit_cnt <= 3'd0;
end

// data receiver
always @(posedge clk or negedge rst_n)
begin
    // if reset hit -> reset
    if(rst_n == 1'b0)
    begin
        data_latch <= 0;
    end
    else if (state == S_REC_BYTE && clk_count == CYCLE_CLOCK_HALF)
        data_latch[bit_cnt] <= rx_pin;
    else
        data_latch <= data_latch;
end

// data put (put in output reg)
always @(posedge clk or negedge rst_n)
begin
    // if reset hit -> reset
    if(rst_n == 1'b0)
    begin
        rx_data <= 0;
    end
    else if (state == S_STOP && next_state != state)
        rx_data <= data_latch; // latch received data
end

// data validator
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        rx_data_valid <= 1'b0;
    end
    else if(state == S_STOP && next_state != state)
        rx_data_valid <= 1'b1;
    else if(state == S_CLEAN && rx_data_ready)
        rx_data_valid <= 1'b0;
end

// count clocks
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        clk_count <= 24'b0;
    end

    else if((state == S_REC_BYTE && clk_count == CYCLE_CLOCK) || next_state != state)
    begin
        clk_count <= 24'b0;
    end

    else
    begin
        clk_count <= clk_count + 1'b1;
    end
end
endmodule

`endif 
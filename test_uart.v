`timescale 10ns / 1ps

module uart_testbench;

    // Parameters for the UART module
    parameter CLK_FREQ = 27000000;  // 50 MHz clock frequency
    parameter BAUD_RATE = 4800;     // UART baud rate
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE; // Clock cycles per bit

    // Testbench signals
    reg clk;
    reg rst_n;
    reg rx_pin;
    wire tx_pin;
    wire[7:0] data;
    wire rx_data_valid;
    wire[5:0] led;

    // Instantiate the UART module
    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .rx_pin(rx_pin),
        .tx_pin(tx_pin),
        .data(data),
        .rx_data_valid(rx_data_valid),
        .led(led)
    );

    // Generate clock signal
    always #(1) clk = ~clk; // 50 MHz clock, period = 20 ns, half-period = 10 ns

    // Function to transmit a single UART bit
    task send_uart_bit;
        input bit_value;
        begin
            rx_pin = bit_value;
            #(5625); // 4800 hz 
        end
    endtask

    // UART transmission of ASCII character '1' (0x31)
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, dut);

        // Initialize signals
        clk = 0;
        rst_n = 0;
        rx_pin = 1; // UART idle state is high

        // Reset sequence
        #10 rst_n = 1;
        #200;

        // Start bit (low)
        send_uart_bit(0);
        // ASCII '1' : 0x31 -> 0011 0001
        // LSB first: send 1 0001 1000
        send_uart_bit(1); // LSB
        send_uart_bit(0);
        send_uart_bit(0);
        send_uart_bit(0);
        send_uart_bit(1);
        send_uart_bit(1);
        send_uart_bit(0);
        send_uart_bit(0); // MSB
        // Stop bit (high)
        send_uart_bit(1);

        // Start bit (low)
        send_uart_bit(0);
        // ASCII '1' : 0x31 -> 0011 0001
        // LSB first: send 1 0001 1000
        send_uart_bit(1); // LSB
        send_uart_bit(1);
        send_uart_bit(0);
        send_uart_bit(0);
        send_uart_bit(1);
        send_uart_bit(1);
        send_uart_bit(0);
        send_uart_bit(0); // MSB
        // Stop bit (high)
        send_uart_bit(1);

        // Start bit (low)
        send_uart_bit(0);
        // ASCII '1' : 0x31 -> 0011 0001
        // LSB first: send 1 0001 1000
        send_uart_bit(1); // LSB
        send_uart_bit(0);
        send_uart_bit(0);
        send_uart_bit(0);
        send_uart_bit(1);
        send_uart_bit(1);
        send_uart_bit(0);
        send_uart_bit(0); // MSB
        // Stop bit (high)
        send_uart_bit(1);

        // End of transmission
        #270416;
        $finish;
    end

endmodule

// $dumpfile("waveform.vcd");
// $dumpvars(0, dut);
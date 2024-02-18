`ifndef BUS
`define BUS

`include "memory.v"

// priority chain bus
module BUS(
    input                   clk,
    input                   rst_n,

    input [13:0]            address,
    input [31:0]            data_i,
    output [31:0]           data_o,
    input [7:0]             control,

    input [31:0]            req,
    input [31:0]            usearr,

    output reg[31:0]        available,
    output reg              idle,
    output reg              fulfilled,
    output [1:0]            state
);

reg[13:0]   mem_address;
reg         mem_we;
reg[31:0]   mem_write;

wire[31:0]  mem_read;
wire        mem_ready;
wire        mem_out_available;

reg         mem_available;

// TODO: fix size to not go over 31
reg [4:0]   req_idx;
// reg         idle;

reg [31:0]  data_latch;

// if reading put data in bus
// else put nothing
// TODO: Faulty! Not dynamic
assign data_o = data_latch;
// assign data = 32'h48474645;

ram mem(
    clk,
    rst_n,

    mem_address,
    mem_write,
    mem_we,
    mem_available,

    mem_read,
    mem_ready,
    mem_out_available,
    state
);

// always @(posedge clk or negedge rst_n)
// begin
//     if(rst_n == 1'b0)
//     begin
//     end
//     else
//     begin
//     end
// end

// check reqs
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        available <= 32'd0;
        req_idx <= 6'd0;
        idle <= 1'b1;
    end

    else if(idle == 1'b1)
    begin
        // req
        if(req[req_idx] == 1'b1)
        begin
            idle <= 1'b0;
            req_idx <= req_idx;
        end

        // ++
        else
        begin
            idle <= 1'b1;
            req_idx <= req_idx + 4'd1;
        end

        available <= available;
    end

    // reset after fulfilled and not in use
    else if(fulfilled == 1'b1 && usearr[req_idx] == 1'b0)
    begin
        idle <= 1'b1;
        req_idx <= 6'd0;
        available <= 32'd0;
        // available <= available;
    end

    // fulfilling req
    else
    begin
        idle <= idle;

        available <= 32'd0;
        available[req_idx] <= 1'b1;

        req_idx <= req_idx;
    end
end

// set fulfilled
// work with mem
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 1'b0)
    begin
        fulfilled <= 1'b0;
        mem_available <= 1'b0;
    end

    // work with mem
    else if(idle == 1'b0)
    begin
        // if mem ready put address/data in
        if(mem_ready == 1'b1)
        begin
            // latch all
            if(control == 8'h00)
            begin
                // read
                mem_we <= 1'b0;
            end
            else
            begin
                // write
                mem_we <= 1'b1;
            end

            mem_address <= address;
            mem_write <= data_i;

            mem_available <= 1'b1;

            fulfilled <= 1'b0;
        end

        // get results if read and out available and already requested from mem
        // TODO: issues with mem available -> Not working as intended
        else if(mem_available == 1'b1 && mem_out_available == 1'b1)
        begin
            // TODO: after working read from actual memory
            data_latch <= mem_read;
            fulfilled <= 1'b1;
            mem_available <= 1'b0;
        end

        // ...
        else
        begin
            fulfilled <= fulfilled;
            mem_available <= mem_available;
        end
    end

    else
    begin
        fulfilled <= fulfilled;
        mem_available <= 1'b0;
    end
end

endmodule;

`endif 
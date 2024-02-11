`ifndef PROCESSOR
`define PROCESSOR

`include "regfile.v"
`include "alu.v"

module riscv(
    input clk
);

parameter ROP = 7'b0110011;
parameter IOP = 7'b0010011;
parameter SOP = 7'b0100011;
parameter BOP = 7'b1100011;
parameter UOP = 7'b0110111;
parameter JOP = 7'b1101111;

parameter ALU_ADD   = 0;
parameter ALU_SUB   = 1;
parameter ALU_XOR   = 2;
parameter ALU_OR    = 3;
parameter ALU_AND   = 4;

// ir
reg[31:0] ir;

// reg definition
reg             we;
reg[31:0]       write;
reg[4:0]        ra1;
reg[4:0]        ra2;
reg[4:0]        wa;

wire[31:0]      read1;
wire[31:0]      read2;

regfile registry(
    .clk(clk),
    .rst(rst),
    .we(we),
    .write(write),
    .ra1(ra1),
    .ra2(ra2),
    .wa(wa),

    .read1(read1),
    .read2(read2)
);

reg     [31:0] a,b;
wire    [31:0] r;
wire    [ 9:0] ctrl;

wire    ze, c, branch;

alu32 alu(
    .ctrl(ctrl),
    .a(a),
    .b(b),

    .r(r),
    .ze(ze),
    .c(c),
    .branch(branch)
);

// instruction wires for decoding
wire[6:0] opcode_;
wire[4:0] rd_, rs1_, rs2_;
wire[2:0] funct3_;
wire[6:0] funct7_;

assign opcode_  = ir[6 :0 ];
assign rd_      = ir[11:7 ];
assign rs1_     = ir[19:15];
assign rs2_     = ir[24:20];
assign funct3_  = ir[14:12];
assign funct7_  = ir[31:25];

assign ctrl = {funct7_, funct3_};

// test
initial begin
    //        f7     rs2  rs1  f3 rd   op
    //        '     ''   ''   '' ''   ''     '
    ir <= 32'b00000000001000001000000000110011;

    #1 $display("ir: ");
    $display(ir);
end

// csr definition
reg[31:0]   misa,
            mvendorid,
            marchid,
            mimpid,
            mstatus,
            mcause,
            mtvec,
            mhartid,
            mepc,
            mie,
            mip,
            mtval,
            mscratch;


// handle 5 stages
always @(posedge clk)
    // 1. Fetch
    // 2. Decode/ReadReg

    // check opcode
    case(opcode_)
        ROP:
            begin
                $display("======clk");
                $display("rs1");
                $display(rs1_);

                $display("rs2");
                $display(rs2_);

                ra1 <= rs1_;
                ra2 <= rs2_;

                #1 $display(read1);
                $display(read2);

                a <= read1;
                b <= read2;

                $display("r");
                #1 $display(r);
            end
        IOP:
            begin

            end
        SOP:
            begin

            end
        BOP:
            begin

            end
        UOP:
            begin

            end
        JOP:
            begin

            end
    endcase

    // 3. Exec
    // 4. Mem
    // 5. RegWrite
endmodule

`endif
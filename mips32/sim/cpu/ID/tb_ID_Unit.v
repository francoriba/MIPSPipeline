`timescale 1ns / 1ps

module tb_id;

    localparam REGISTER_BANK_SIZE = 32;
    localparam PC_SIZE = 32;
    localparam BUS_SIZE = 32;
    localparam ADDR_WIDTH = $clog2(REGISTER_BANK_SIZE);

    reg i_clk;
    reg i_reset;
    reg i_flush;
    reg i_write_enable;
    reg i_ctrl_reg_source;
    reg [ADDR_WIDTH-1:0] i_reg_write_addr;
    reg [BUS_SIZE-1:0] i_reg_write_bus;
    reg [BUS_SIZE-1:0] i_instruction;
    reg [BUS_SIZE-1:0] i_ex_data_A;
    reg [BUS_SIZE-1:0] i_ex_data_B;
    reg [PC_SIZE-1:0] i_next_seq_pc;

    wire o_next_pc_source;
    wire [2:0] o_mem_read_source;
    wire [1:0] o_mem_write_source;
    wire o_mem_write;
    wire o_wb;
    wire o_mem_to_reg;
    wire [1:0] o_reg_dst;
    wire o_alu_source_A;
    wire [2:0] o_alu_source_B;
    wire [2:0] o_alu_opp;
    wire [BUS_SIZE-1:0] o_bus_A;
    wire [BUS_SIZE-1:0] o_bus_B;
    wire [PC_SIZE-1:0] o_next_not_seq_pc;
    wire [4:0] o_rs;
    wire [4:0] o_rt;
    wire [4:0] o_rd;
    wire [5:0] o_funct;
    wire [5:0] o_opp;
    wire [BUS_SIZE-1:0] o_shamt_ext_unsigned;
    wire [BUS_SIZE-1:0] o_inm_ext_signed;
    wire [BUS_SIZE-1:0] o_inm_upp;
    wire [BUS_SIZE-1:0] o_inm_ext_unsigned;
    wire [REGISTER_BANK_SIZE * BUS_SIZE-1:0] o_bus_debug;

    // id module
    id #(
        .REGISTER_BANK_SIZE(REGISTER_BANK_SIZE),
        .PC_SIZE(PC_SIZE),
        .BUS_SIZE(BUS_SIZE)
    ) uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_flush(i_flush),
        .i_write_enable(i_write_enable),
        .i_ctrl_reg_source(i_ctrl_reg_source),
        .i_reg_write_addr(i_reg_write_addr),
        .i_reg_write_bus(i_reg_write_bus),
        .i_instruction(i_instruction),
        .i_ex_data_A(i_ex_data_A),
        .i_ex_data_B(i_ex_data_B),
        .i_next_seq_pc(i_next_seq_pc),
        .o_next_pc_source(o_next_pc_source),
        .o_mem_read_source(o_mem_read_source),
        .o_mem_write_source(o_mem_write_source),
        .o_mem_write(o_mem_write),
        .o_wb(o_wb),
        .o_mem_to_reg(o_mem_to_reg),
        .o_reg_dst(o_reg_dst),
        .o_alu_source_A(o_alu_source_A),
        .o_alu_source_B(o_alu_source_B),
        .o_alu_opp(o_alu_opp),
        .o_bus_A(o_bus_A),
        .o_bus_B(o_bus_B),
        .o_next_not_seq_pc(o_next_not_seq_pc),
        .o_rs(o_rs),
        .o_rt(o_rt),
        .o_rd(o_rd),
        .o_funct(o_funct),
        .o_opp(o_opp),
        .o_shamt_ext_unsigned(o_shamt_ext_unsigned),
        .o_inm_ext_signed(o_inm_ext_signed),
        .o_inm_upp(o_inm_upp),
        .o_inm_ext_unsigned(o_inm_ext_unsigned),
        .o_bus_debug(o_bus_debug)
    );

    // Clock generation
    always #5 i_clk = ~i_clk;

    initial begin
        // Initialize Inputs
        i_clk = 0;
        i_reset = 0;
        i_flush = 0;
        i_write_enable = 0;
        i_ctrl_reg_source = 0;
        i_reg_write_addr = 0;
        i_reg_write_bus = 0;
        i_instruction = 0;
        i_ex_data_A = 0;
        i_ex_data_B = 0;
        i_next_seq_pc = 0;

        // Reset the module
        i_reset = 1;
        #10;
        i_reset = 0;
        #10;

        // Test 1: Simple ADD instruction
        i_instruction = 32'b000000_00001_00010_00011_00000_100000; // ADD $3, $1, $2
        i_ex_data_A = 32'h00000001;
        i_ex_data_B = 32'h00000002;
        i_next_seq_pc = 32'h00000004;
        #10;

        // Display important values
        $display("TEST 1 - ADD Instruction");
        $display("o_opp: %b, o_rs: %b, o_rt: %b, o_rd: %b, o_funct: %b", o_opp, o_rs, o_rt, o_rd, o_funct);

        if (o_opp === 6'b000000 && o_rs === 5'b00001 && o_rt === 5'b00010 && o_rd === 5'b00011 && o_funct === 6'b100000) begin
            $display("TEST 1 OK");
        end else begin
            $display("TEST 1 FAILED");
        end

        // Test 2: BEQ instruction
        i_instruction = 32'b000100_00001_00010_0000000000000100; // BEQ $1, $2, offset=4
        #10;

        // Display important values
        $display("TEST 2 - BEQ Instruction");
        $display("o_opp: %b, o_rs: %b, o_rt: %b, o_inm_ext_signed: %b", o_opp, o_rs, o_rt, o_inm_ext_signed);

        if (o_opp === 6'b000100 && o_rs === 5'b00001 && o_rt === 5'b00010 && o_inm_ext_signed === 32'h00000004) begin
            $display("TEST 2 OK");
        end else begin
            $display("TEST 2 FAILED");
        end

        // Test 3: J instruction
        i_instruction = 32'b000010_00000000000000000000000001; // J address=1
        #10;

        // Display important values
        $display("TEST 3 - J Instruction");
        $display("o_opp: %b, o_next_not_seq_pc: %b", o_opp, o_next_not_seq_pc);

        if (o_opp === 6'b000010 && o_next_not_seq_pc === 32'h00000004) begin
            $display("TEST 3 OK");
        end else begin
            $display("TEST 3 FAILED");
        end

        $finish;
    end

endmodule

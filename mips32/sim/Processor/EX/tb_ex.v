`timescale 1ns / 1ps

module tb_ex;

    parameter BUS_SIZE = 32;
    parameter ALU_CTRL_BUS_WIDTH = 6;

    // test signals
    reg i_alu_src_A;
    reg [2:0] i_alu_src_B;
    reg [1:0] i_reg_dst;
    reg [2:0] i_alu_opp;
    reg [1:0] i_src_A_select;
    reg [1:0] i_src_B_select;
    reg [4:0] i_rt;
    reg [4:0] i_rd;
    reg [5:0] i_funct;
    reg [BUS_SIZE - 1:0] i_forwarded_alu_result;
    reg [BUS_SIZE - 1:0] i_forwarded_wb_result;
    reg [BUS_SIZE - 1:0] i_bus_A;
    reg [BUS_SIZE - 1:0] i_bus_B;
    reg [BUS_SIZE - 1:0] i_shamt_ext_unsigned;
    reg [BUS_SIZE - 1:0] i_inm_ext_signed;
    reg [BUS_SIZE - 1:0] i_inm_upp;
    reg [BUS_SIZE - 1:0] i_inm_ext_unsigned;
    reg [BUS_SIZE - 1:0] i_next_seq_pc;

    wire [4:0] o_wb_addr;
    wire [BUS_SIZE - 1:0] o_alu_result;
    wire [BUS_SIZE - 1:0] o_forwarded_data_A;
    wire [BUS_SIZE - 1:0] o_forwarded_data_B;

    // Expected outputs
    reg [4:0] expected_wb_addr;
    reg [BUS_SIZE - 1:0] expected_alu_result;
    reg [BUS_SIZE - 1:0] expected_forwarded_data_A;
    reg [BUS_SIZE - 1:0] expected_forwarded_data_B;

    // Instantiate the ex module
    ex #(
        .BUS_SIZE(BUS_SIZE),
        .ALU_CTRL_BUS_WIDTH(ALU_CTRL_BUS_WIDTH)
    ) uut (
        .i_alu_src_A(i_alu_src_A),
        .i_alu_src_B(i_alu_src_B),
        .i_reg_dst(i_reg_dst),
        .i_alu_opp(i_alu_opp),
        .i_src_A_select(i_src_A_select),
        .i_src_B_select(i_src_B_select),
        .i_rt(i_rt),
        .i_rd(i_rd),
        .i_funct(i_funct),
        .i_forwarded_alu_result(i_forwarded_alu_result),
        .i_forwarded_wb_result(i_forwarded_wb_result),
        .i_bus_A(i_bus_A),
        .i_bus_B(i_bus_B),
        .i_shamt_ext_unsigned(i_shamt_ext_unsigned),
        .i_inm_ext_signed(i_inm_ext_signed),
        .i_inm_upp(i_inm_upp),
        .i_inm_ext_unsigned(i_inm_ext_unsigned),
        .i_next_seq_pc(i_next_seq_pc),
        .o_wb_addr(o_wb_addr),
        .o_alu_result(o_alu_result),
        .o_forwarded_data_A(o_forwarded_data_A),
        .o_forwarded_data_B(o_forwarded_data_B)
    );

    initial begin
        // Test case 1: ALU operation with forwarded ALU result and rt as destination
        i_alu_src_A = 0;
        i_alu_src_B = 3'b000;
        i_reg_dst = 2'b10;
        i_alu_opp = 3'b110; // R-Type
        i_src_A_select = 2'b00;
        i_src_B_select = 2'b00;
        i_rt = 5'd10;
        i_rd = 5'd15;
        i_funct = 6'b100000; // ADD function
        i_forwarded_alu_result = 32'hA5A5A5A5;
        i_forwarded_wb_result = 32'h5A5A5A5A;
        i_bus_A = 32'h12345678;
        i_bus_B = 32'h87654321;
        i_shamt_ext_unsigned = 32'h00000002;
        i_inm_ext_signed = 32'h0000FFFF;
        i_inm_upp = 32'hFFFF0000;
        i_inm_ext_unsigned = 32'h0000AAAA;
        i_next_seq_pc = 32'h00000004;
        
        // Expected outputs
        expected_wb_addr = i_rt;
        expected_alu_result = i_bus_A + i_bus_B;
        expected_forwarded_data_A = i_forwarded_alu_result;
        expected_forwarded_data_B = i_forwarded_alu_result;
        
        #10;
        $display("wb address: %b, alu result: %b", o_wb_addr, o_alu_result);

        // Test case 2: ALU operation with immediate signed extension and rd as destination
        i_alu_src_A = 1;
        i_alu_src_B = 3'b010;
        i_reg_dst = 2'b01;
        i_alu_opp = 3'b000; // ADDI
        i_src_A_select = 2'b01;
        i_src_B_select = 2'b01;
        i_rt = 5'd10;
        i_rd = 5'd15;
        i_funct = 6'bxxxxxx;
        i_forwarded_alu_result = 32'hB5B5B5B5;
        i_forwarded_wb_result = 32'h5B5B5B5B;
        i_bus_A = 32'h11111111;
        i_bus_B = 32'h22222222;
        i_shamt_ext_unsigned = 32'h00000003;
        i_inm_ext_signed = 32'h0000ABCD;
        i_inm_upp = 32'hABCD0000;
        i_inm_ext_unsigned = 32'h0000BBBB;
        i_next_seq_pc = 32'h00000008;
        
        // Expected outputs
        expected_wb_addr = i_rd;
        expected_alu_result = i_shamt_ext_unsigned + i_inm_ext_signed;
        expected_forwarded_data_A = i_forwarded_wb_result;
        expected_forwarded_data_B = i_forwarded_wb_result;

        #10;
        $display("wb address: %b, alu result: %b", o_wb_addr, o_alu_result);

        $stop;
    end
endmodule

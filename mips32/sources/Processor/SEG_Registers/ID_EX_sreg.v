`timescale 1ns / 1ps

module id_ex
    #(
        parameter BUS_WIDTH = 32
    )
    (
        input  wire i_clk,
        input  wire i_reset,
        input  wire i_enable,
        input  wire i_flush,

        // data
        input  wire [BUS_WIDTH - 1 : 0] i_bus_A,
        input  wire [BUS_WIDTH - 1 : 0] i_bus_B,
        input  wire [4 : 0] i_rs,
        input  wire [4 : 0] i_rt,
        input  wire [4 : 0] i_rd,
        input  wire [5 : 0] i_funct,
        input  wire [5 : 0] i_opp,
        input  wire [BUS_WIDTH - 1 : 0] i_shamt_ext_unsigned,
        input  wire [BUS_WIDTH - 1 : 0] i_inm_ext_signed,
        input  wire [BUS_WIDTH - 1 : 0] i_inm_upp,
        input  wire [BUS_WIDTH - 1 : 0] i_inm_ext_unsigned,
        input  wire [BUS_WIDTH - 1 : 0] i_next_seq_pc,
        // ctrl
        input  wire i_stop_jump,
        input  wire [2 : 0] i_mem_read_source,
        input  wire [1 : 0] i_mem_write_source,
        input  wire i_mem_write,
        input  wire i_wb,
        input  wire i_mem_to_reg,
        input  wire [1 : 0] i_reg_dst,
        input  wire i_alu_source_A,
        input  wire [2 : 0] i_alu_source_B,
        input  wire [2 : 0] i_alu_opp,
        input  wire i_halt,

        // data
        output wire [BUS_WIDTH - 1 : 0] o_bus_A,
        output wire [BUS_WIDTH - 1 : 0] o_bus_B,
        output wire [4 : 0] o_rs,
        output wire [4 : 0] o_rt,
        output wire [4 : 0] o_rd,
        output wire [5 : 0] o_funct,
        output wire [5 : 0] o_opp,
        output wire [BUS_WIDTH - 1 : 0] o_shamt_ext_unsigned,
        output wire [BUS_WIDTH - 1 : 0] o_inm_ext_signed,
        output wire [BUS_WIDTH - 1 : 0] o_inm_upp,
        output wire [BUS_WIDTH - 1 : 0] o_inm_ext_unsigned,
        output wire [BUS_WIDTH - 1 : 0] o_next_seq_pc,
        // ctrl
        output wire o_stop_jump,
        output wire [2 : 0] o_mem_read_source,
        output wire [1 : 0] o_mem_write_source,
        output wire o_mem_write,
        output wire o_wb,
        output wire o_mem_to_reg,
        output wire [1 : 0] o_reg_dst,
        output wire o_alu_source_A,
        output wire [2 : 0] o_alu_source_B,
        output wire [2 : 0] o_alu_opp,
        output wire o_halt
    );

    reg [BUS_WIDTH - 1 : 0] bus_A;
    reg [BUS_WIDTH - 1 : 0] bus_B;
    reg [4 : 0] rs;
    reg [4 : 0] rt;
    reg [4 : 0] rd;
    reg [5 : 0] funct;
    reg [5 : 0] opp;
    reg [BUS_WIDTH - 1 : 0] shamt_ext_unsigned;
    reg [BUS_WIDTH - 1 : 0] inm_ext_signed;
    reg [BUS_WIDTH - 1 : 0] inm_upp;
    reg [BUS_WIDTH - 1 : 0] inm_ext_unsigned;
    reg [BUS_WIDTH - 1 : 0] next_seq_pc;
    
    reg stop_jump;
    reg [2 : 0] mem_read_source;
    reg [1 : 0] mem_write_source;
    reg mem_write;
    reg wb;
    reg mem_to_reg;
    reg [1 : 0] reg_dst;
    reg alu_src_A;
    reg [2 : 0] alu_src_B;
    reg [2 : 0] alu_opp;
    reg halt;

    always @(posedge i_clk)
    begin
        if (i_reset || i_flush)
            begin
                stop_jump <= 1'b0;
                mem_read_source <= 'b0;
                mem_write_source <= 'b0;
                mem_write <= 1'b0;
                wb <= 1'b0;
                mem_to_reg <= 1'b0;
                reg_dst <= 'b0;
                alu_src_A <= 1'b0;
                alu_src_B <= 'b0;
                alu_opp <= 'b0;
                bus_A <= 'b0;
                bus_B <= 'b0;
                rs <= 'b0;
                rt <= 'b0;
                rd <= 'b0;
                funct <= 'b0;
                opp <= 'b0;
                shamt_ext_unsigned <= 'b0;
                inm_ext_signed <= 'b0;
                inm_upp <= 'b0;
                inm_ext_unsigned <= 'b0;
                next_seq_pc <= 'b0;
                halt <= 1'b0;
            end
        else if (i_enable)
            begin
                stop_jump <= i_stop_jump;
                mem_read_source <= i_mem_read_source;
                mem_write_source <= i_mem_write_source;
                mem_write <= i_mem_write;
                wb <= i_wb;
                mem_to_reg <= i_mem_to_reg;
                reg_dst <= i_reg_dst;
                alu_src_A <= i_alu_source_A;
                alu_src_B <= i_alu_source_B;
                alu_opp <= i_alu_opp;
                bus_A <= i_bus_A;
                bus_B <= i_bus_B;
                rs <= i_rs;
                rt <= i_rt;
                rd <= i_rd;
                funct <= i_funct;
                opp <= i_opp;
                shamt_ext_unsigned <= i_shamt_ext_unsigned;
                inm_ext_signed <= i_inm_ext_signed;
                inm_upp <= i_inm_upp;
                inm_ext_unsigned <= i_inm_ext_unsigned;
                next_seq_pc <= i_next_seq_pc;
                halt <= i_halt;
            end
    end

    assign o_stop_jump = stop_jump;
    assign o_mem_read_source = mem_read_source;
    assign o_mem_write_source = mem_write_source;
    assign o_mem_write = mem_write;
    assign o_wb = wb;
    assign o_mem_to_reg = mem_to_reg;
    assign o_reg_dst = reg_dst;
    assign o_alu_source_A = alu_src_A;
    assign o_alu_source_B = alu_src_B;
    assign o_alu_opp = alu_opp;
    assign o_bus_A = bus_A;
    assign o_bus_B = bus_B;
    assign o_rs = rs;
    assign o_rt = rt;
    assign o_rd = rd;
    assign o_funct = funct;
    assign o_opp = opp;
    assign o_shamt_ext_unsigned = shamt_ext_unsigned;
    assign o_inm_ext_signed = inm_ext_signed;
    assign o_inm_upp = inm_upp;
    assign o_inm_ext_unsigned = inm_ext_unsigned;
    assign o_next_seq_pc = next_seq_pc;
    assign o_halt = halt;

endmodule

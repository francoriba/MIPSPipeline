`timescale 1ns / 1ps

module alu_ctrl
    #(
        parameter ALU_CTRL_BUS_WIDTH   = 6,
        parameter ALU_OP_BUS_WIDTH    = 3,
        parameter ALU_FUNCT_BUS_WIDTH = 6
    )
    (
        input  wire [ALU_FUNCT_BUS_WIDTH - 1 : 0] i_funct,
        input  wire [ALU_OP_BUS_WIDTH - 1 : 0]    i_alu_opp,
        output wire [ALU_CTRL_BUS_WIDTH - 1 : 0]   o_alu_ctrl
    );

    localparam CTRL_LOAD_TYPE = 3'b000; // Load instructions
    localparam CTRL_STORE_TYPE = 3'b000; // Store instructions
    localparam CTRL_ADDI = 3'b000; // Add immediate instruction
    localparam CTRL_ANDI = 3'b010; // And immediate instruction
    localparam CTRL_ORI = 3'b011; // Or immediate instruction
    localparam CTRL_XORI = 3'b100; // Xor immediate instruction
    localparam CTRL_SLTI = 3'b101; // Set less than immediate instruction
    localparam CTRL_R_TYPE = 3'b110; // R-Type instructions
    localparam CTRL_JUMP_TYPE = 3'b111; // Jump instructions
    localparam EX_SC_B = 6'b001001; // Short circuit B
    localparam EX_NOP = 6'bxxxxxx; // No operation
    localparam EX_AND = 6'b100100; // Logical and
    localparam EX_OR = 6'b100101; // Logical or
    localparam EX_XOR = 6'b100110; // Logical xor
    localparam EX_SLT = 6'b101010; // Set if less than
    localparam EX_ADD = 6'b100000; // Sum

    reg [ALU_CTRL_BUS_WIDTH - 1 : 0] alu_ctrl;

    always@(*)
    begin
        case(i_alu_opp)
            CTRL_R_TYPE      : alu_ctrl = i_funct;
            CTRL_LOAD_TYPE   : alu_ctrl = EX_ADD;
            CTRL_JUMP_TYPE   : alu_ctrl = EX_SC_B;
            CTRL_ANDI        : alu_ctrl = EX_AND;
            CTRL_ORI         : alu_ctrl = EX_OR;
            CTRL_XORI        : alu_ctrl = EX_XOR;
            CTRL_SLTI        : alu_ctrl = EX_SLT;
            default          : alu_ctrl = EX_NOP;
        endcase


    end

    assign o_alu_ctrl = alu_ctrl;

endmodule
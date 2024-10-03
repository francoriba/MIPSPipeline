`timescale 1ns / 1ps

/*
Implements the Instruction Decode (ID) stage,
handling the necessary control and data signals for executing instructions.
*/

module id
    #(
        parameter REGISTER_BANK_SIZE = 32,
        parameter PC_SIZE = 32,
        parameter BUS_SIZE = 32
    )
    (
        /* input controls wires */
        input wire i_clk, 
        input wire i_reset, 
        input wire i_flush, 
        input wire i_write_enable, 
        input wire i_ctrl_reg_source, 
        /* input data wires */
        input wire [$clog2(REGISTER_BANK_SIZE) - 1 : 0] i_reg_write_addr, // address in the register bank where the data will be written
        input wire [BUS_SIZE - 1 : 0] i_reg_write_bus, // data to be written in the register bank
        input wire [BUS_SIZE - 1 : 0] i_instruction, // instruction being decoded
        input wire [BUS_SIZE - 1 : 0] i_ex_data_A, // data A from the EX stage
        input wire [BUS_SIZE - 1 : 0] i_ex_data_B, // data B from the EX stage
        input wire [PC_SIZE - 1 : 0] i_next_seq_pc, // address of the next sequential instruction
        /* output control wires */
        output wire o_next_pc_source, //  source of the next PC. Can have two values: 1 for a normal sequence (PC sequential increment) and 0 for an external source like a jump instruction.
        output wire [2 : 0] o_mem_read_source, // source of the data to read from memory
        output wire [1 : 0] o_mem_write_source, // // source of the data to write to memory
        output wire o_mem_write, // signal to write to memory
        output wire o_wb, // write-back signal
        output wire o_mem_to_reg, // indicates if the data read from memory should be transferred to the register bank
        output wire [1 : 0] o_reg_dst, // destination of the data in the register bank
        output wire o_alu_source_A, // indicates if the first ALU operand should come from the execution stage (1) or the register bank (0)
        output wire [2 : 0] o_alu_source_B, // indicates the source of the second ALU operand
        output wire [2 : 0] o_alu_opp, // operation that the ALU will perform
        /* output data wires */
        output wire [BUS_SIZE - 1 : 0] o_bus_A,  // value on bus A that will be sent to the next stage of the pipeline
        output wire [BUS_SIZE - 1 : 0] o_bus_B, // value on bus B that will be sent to the next stage of the pipeline
        output wire [PC_SIZE - 1 : 0] o_next_not_seq_pc, // address of the next non-sequential instruction
        output wire [4 : 0] o_rs, // source register RS
        output wire [4 : 0] o_rt, // source register RT
        output wire [4 : 0] o_rd, // destination register RD
        output wire [5 : 0] o_funct, // function of the instruction
        output wire [5 : 0] o_opp, // operation of the instruction
        output wire [BUS_SIZE - 1 : 0] o_shamt_ext_unsigned, // unsigned extended shamt
        output wire [BUS_SIZE - 1 : 0] o_inm_ext_signed, // signed extended immediate
        output wire [BUS_SIZE - 1 : 0] o_inm_upp, // immediate extended with zeros in the least significant bits
        output wire [BUS_SIZE - 1 : 0] o_inm_ext_unsigned, // unsigned extended immediate
        /* debug wires */
        output wire [REGISTER_BANK_SIZE * BUS_SIZE - 1 : 0] o_bus_debug
    );

    /* Internal wires */
    wire are_equal_values_result; // signal to know if two values are different
    wire is_nop_result; // signal to know if the instruction is a NOP
    wire [1 : 0] jmp_ctrl; // control to know if the instruction is a jump
    wire [19 : 0] ctrl_register; // control registers for the ID stage
    wire [16 : 0] next_stage_ctrl_register; // control registers for the next stage
    wire [BUS_SIZE - 1 : 0] inm_ext_signed_shifted; // signed extended and shifted immediate
    wire [BUS_SIZE - 1 : 0] dir_ext_unsigned; // unsigned extended address
    wire [BUS_SIZE - 1 : 0] dir_ext_unsigned_shifted; // unsigned extended and shifted address

    wire [4 : 0] shamt; // shamt of the instruction
    wire [15 : 0] inm; // immediate of the instruction
    wire [25 : 0] dir; // address of the instruction
    wire [BUS_SIZE - 1 : 0] branch_pc_dir; // address of the next instruction in case of a conditional jump
    wire [BUS_SIZE - 1 : 0] jump_pc_dir; // address of the next instruction in case of an unconditional jump
    
    /* Assignment internal wires */
    assign jmp_ctrl = ctrl_register[18:17]; // control to know if the instruction is a jump
    assign jump_pc_dir = { i_next_seq_pc[31:28], dir_ext_unsigned_shifted[27:0] }; // calculate jump address

    /* Instruction format */
    assign o_opp = i_instruction[31:26];
    assign o_rs = i_instruction[25:21]; // R-Type
    assign o_rt = i_instruction[20:16];
    assign o_rd = i_instruction[15:11];
    assign shamt = i_instruction[10:6];
    assign o_funct = i_instruction[5:0];
    assign inm = i_instruction[15:0]; // I-Type
    assign dir = i_instruction[25:0]; // J-Type

    assign o_next_pc_source = ctrl_register[19];
    assign o_reg_dst = next_stage_ctrl_register[16:15];
    assign o_alu_source_A = next_stage_ctrl_register[14];
    assign o_alu_source_B = next_stage_ctrl_register[13:11];
    assign o_alu_opp = next_stage_ctrl_register[10:8];
    assign o_mem_read_source = next_stage_ctrl_register[7:5];
    assign o_mem_write_source = next_stage_ctrl_register[4:3];
    assign o_mem_write = next_stage_ctrl_register[2];
    assign o_wb = next_stage_ctrl_register[1];
    assign o_mem_to_reg = next_stage_ctrl_register[0];

    /* Register Bank */
    registers 
    #(
        .REGISTERS_BANK_SIZE (REGISTER_BANK_SIZE),
        .REGISTERS_SIZE      (BUS_SIZE)
    ) 
    registers_unit 
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_flush        (i_flush),
        .i_write_enable (i_write_enable),
        .i_addr_A       (o_rs),
        .i_addr_B       (o_rt),
        .i_addr_wr      (i_reg_write_addr),
        .i_bus_wr       (i_reg_write_bus),
        .o_bus_A        (o_bus_A),
        .o_bus_B        (o_bus_B),
        .o_bus_debug    (o_bus_debug)
    );

    /* Control: generate necessary control signals */
    ctrl_register ctrl_register_unit 
    (
        .i_are_equal (are_equal_values_result),
        .i_instr_nop (is_nop_result),
        .i_opp (o_opp),
        .i_funct (o_funct),
        .o_ctrl_register (ctrl_register)
    );

    /* Multiplexer to select the next control register for the stage */
    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(17)
    ) 
    mux_ctrl_regs_unit 
    (
        .selector (i_ctrl_reg_source),
        .data_in  ({17'b0, ctrl_register[16:0]}),
        .data_out (next_stage_ctrl_register)
    );

    /* Multiplexer to select the next PC */
    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_jump_unit 
    (
        .selector (jmp_ctrl),
        .data_in  ({jump_pc_dir, i_ex_data_A, branch_pc_dir}),
        .data_out (o_next_not_seq_pc)
    );

    /* Extend unsigned for DIR */
    extend 
    #(
        .DATA_ORIGINAL_SIZE  (26), 
        .DATA_EXTENDED_SIZE (BUS_SIZE)
    ) 
    extend_u_dir_unit  
    (
        .i_value (dir),
        .i_is_signed (1'b0),
        .o_extended_value (dir_ext_unsigned)
    );

    /* Extend unsigned for SHAMT */
    extend 
    #(
        .DATA_ORIGINAL_SIZE  (5), 
        .DATA_EXTENDED_SIZE (BUS_SIZE)
    ) 
    extend_u_shamt_unit  
    (
        .i_value (shamt),
        .i_is_signed (1'b0),
        .o_extended_value (o_shamt_ext_unsigned)
    );

    /* Extend signed for INM */
    extend 
    #(
        .DATA_ORIGINAL_SIZE (16), 
        .DATA_EXTENDED_SIZE (BUS_SIZE)
    ) 
    extend_s_inm_unit  
    (
        .i_value (inm),
        .i_is_signed (1'b1),
        .o_extended_value (o_inm_ext_signed)
    );
    
    /* Extend unsigned for INM */
    extend 
    #(
        .DATA_ORIGINAL_SIZE  (16), 
        .DATA_EXTENDED_SIZE (BUS_SIZE)
    ) 
    extend_u_inm_unit 
    (
        .i_value (inm),
        .i_is_signed (1'b0),
        .o_extended_value (o_inm_ext_unsigned)
    );    

    /*Check A = B */
    is_equal 
    #(
        .DATA_LEN (BUS_SIZE)
    )
    is_equal_unit 
    (
        .i_data_A (i_ex_data_A),
        .i_data_B (i_ex_data_B),
        .o_is_equal (are_equal_values_result)
    );

    /* Check if it's NOP */
    is_nop 
    #(
        .DATA_LEN (BUS_SIZE)
    )
    is_nop_unit 
    (
        .i_opp (i_instruction),
        .o_is_nop (is_nop_result)
    );


    /* Shift left 2 for extended signed INM */
    shift_left 
    #(
        .DATA_LEN (BUS_SIZE), 
        .POS_TO_SHIFT (2)
    ) 
    shift_left_ext_inm_s_unit  
    (
        .i_value (o_inm_ext_signed),
        .o_shifted (inm_ext_signed_shifted)
    );


    /* Shift left 2 for DIR */
    shift_left 
    #(
        .DATA_LEN (BUS_SIZE), 
        .POS_TO_SHIFT (2)
    ) 
    shift_left_dir_unit 
    (
        .i_value (dir_ext_unsigned),
        .o_shifted (dir_ext_unsigned_shifted)
    );


    /* Shift left 16 for INM */
    shift_left 
    #(
        .DATA_LEN (BUS_SIZE), 
        .POS_TO_SHIFT (16)
    ) 
    shift_left_inm_unit 
    (
        .i_value (o_inm_ext_unsigned),
        .o_shifted (o_inm_upp)
    );

    /* Compute next branch PC */
    adder 
    #
    (
        .BUS_SIZE (BUS_SIZE)
    ) 
    adder_unit 
    (
        .a   (i_next_seq_pc),
        .b   (inm_ext_signed_shifted),
        .sum (branch_pc_dir)
    );

endmodule

`timescale 1ns / 1ps

/*
    Hazard Detection Module:
    This module detects hazards and control risks in the pipeline.
*/

module hazard_detection
    #(
        // Function codes for various instructions
        parameter CODE_FUNCT_JALR = 6'b001001, // Function code for JALR (Jump and Link Register)
        parameter CODE_FUNCT_JR = 6'b001000,   // Function code for JR (Jump Register)

        // Operation codes for various instructions
        parameter CODE_OP_R_TYPE = 6'b000000, // Operation code for R-type instructions
        parameter CODE_OP_BNE = 6'b000101,    // Operation code for BNE (Branch Not Equal)
        parameter CODE_OP_BEQ = 6'b000100,    // Operation code for BEQ (Branch Equal)

        parameter CODE_OP_HALT = 6'b111111,   // Operation code for HALT

        parameter CODE_OP_LW = 6'b100011,    // Operation code for LW (Load Word)
        parameter CODE_OP_LB = 6'b100000,    // Operation code for LB (Load Byte)
        parameter CODE_OP_LBU = 6'b100100,   // Operation code for LBU (Load Byte Unsigned)
        parameter CODE_OP_LH = 6'b100001,    // Operation code for LH (Load Halfword)
        parameter CODE_OP_LHU = 6'b100101,   // Operation code for LHU (Load Halfword Unsigned)
        parameter CODE_OP_LUI = 6'b001111,   // Operation code for LUI (Load Upper Immediate)
        parameter CODE_OP_LWU = 6'b100111    // Operation code for LWU (Load Word Unsigned)
    )
    (
        input wire                         i_jump_stop, // Indicates if the pipeline should be stopped due to a jump
        input wire [4:0]                   i_if_id_rs, // Source register rs in IF/ID stage
        input wire [4:0]                   i_if_id_rd, // Destination register rd in IF/ID stage
        input wire [5:0]                   i_if_id_op, // Operation code in IF/ID stage
        input wire [5:0]                   i_if_id_funct, // Function code in IF/ID stage

        input wire [4:0]                   i_id_ex_rt, // Source register rt in ID/EX stage
        input wire [5:0]                   i_id_ex_op, // Operation code in ID/EX stage

        output wire                        o_jmp_stop, // Indicates if the pipeline should be stopped for one cycle due to a jump
        output wire                        o_not_load, // Indicates if the pipeline should not load a register due to a load hazard
        output wire                        o_halt, // Indicates if a HALT operation is detected
        output wire                        o_ctr_reg_src // Control signal for propagating control hazard information
    );

    /*
        Determine if a jump stop is required:
        - If the instruction in the IF/ID stage is JALR or JR (R-type) or BNE or BEQ (I-type), and jump stop is not already indicated,
          then the pipeline should be stopped.
    */
    assign o_jmp_stop = (
            (i_if_id_funct == CODE_FUNCT_JALR || i_if_id_funct == CODE_FUNCT_JR && i_if_id_op == CODE_OP_R_TYPE) || 
            (i_if_id_op == CODE_OP_BNE || i_if_id_op == CODE_OP_BEQ)
            ) && !i_jump_stop;

    /*
        Determine if a load hazard is present:
        - If the source register rt in the ID/EX stage matches either the source or destination register in the IF/ID stage
          and the operation in the ID/EX stage is a load operation (LW, LB, LBU, LH, LHU, LUI, LWU),
          or if a jump stop is indicated, then a load hazard is present.
    */
    assign o_not_load = (
            (i_id_ex_rt == i_if_id_rs || i_id_ex_rt == i_if_id_rd) && 
            (i_id_ex_op == CODE_OP_LW || i_id_ex_op == CODE_OP_LB || 
             i_id_ex_op == CODE_OP_LBU || i_id_ex_op == CODE_OP_LH || 
             i_id_ex_op == CODE_OP_LHU || i_id_ex_op == CODE_OP_LUI ||
             i_id_ex_op == CODE_OP_LWU)
            ) || o_jmp_stop;

    /*
        The control register source signal is used to propagate the control hazard information through the pipeline.
    */
    assign o_ctr_reg_src = o_not_load;

    /*
        The HALT signal indicates if a HALT operation is detected in the IF/ID stage.
    */
    assign o_halt = i_if_id_op == CODE_OP_HALT;

endmodule

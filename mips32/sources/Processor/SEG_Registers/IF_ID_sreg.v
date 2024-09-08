`timescale 1ns / 1ps

module if_id
    #(
        parameter PC_SIZE          = 32,
        parameter INSTRUCTION_SIZE = 32
    )
    (
        input  wire                            i_clk,
        input  wire                            i_reset,
        input  wire                            i_enable,
        input  wire                            i_flush,
        input  wire                            i_halt,
        input  wire [PC_SIZE - 1 : 0]          i_next_seq_pc,
        input  wire [INSTRUCTION_SIZE - 1 : 0] i_instruction,
        output wire                            o_halt,
        output wire [PC_SIZE - 1 : 0]          o_next_seq_pc,
        output wire [INSTRUCTION_SIZE - 1 : 0] o_instruction
    );

    reg [PC_SIZE - 1 : 0]          next_seq_pc;
    reg [INSTRUCTION_SIZE - 1 : 0] instruction;
    reg                            halt;

    always @(posedge i_clk) 
    begin
        if (i_reset || i_flush)
            begin
                next_seq_pc <= 'b0;
                instruction <= 'b0;
                halt        <= 1'b0;
            end
        else if (i_enable)
            begin
                next_seq_pc <= i_next_seq_pc;
                instruction <= i_instruction;
                halt        <= i_halt;
            end
    end

    assign o_next_seq_pc = next_seq_pc;
    assign o_instruction = instruction;
    assign o_halt        = halt;

endmodule
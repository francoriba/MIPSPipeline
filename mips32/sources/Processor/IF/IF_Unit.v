`timescale 1ns / 1ps

/*
    Instruction Fetch (IF) Stage: Fetches the next instruction and updates the PC.
*/

module _if
    #(
        parameter PC_SIZE = 32,                     // Width of the PC
        parameter WORD_SIZE_IN_BYTES = 4,           // Size of a word in bytes
        parameter MEM_SIZE_IN_WORDS = 10            // Size of the instruction memory in words
    )(
        input wire i_clk,                          // Clock input
        input wire i_reset,                        // Reset input
        input wire i_halt,                         // Halt signal
        input wire i_not_load,                     // Signal indicating whether to load the instruction
        input wire i_enable,                       // Enable signal for the module
        input wire i_next_pc_src,                  // Signal to select between sequential and non-sequential PC
        input wire i_write_mem,                    // Signal to write to memory
        input wire i_clear_mem,                    // Signal to clear memory
        input wire i_flush,                        // Flush signal
        input wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] i_instruction, // Instruction input
        input wire [PC_SIZE - 1 : 0] i_next_not_seq_pc, // Next non-sequential PC value
        input wire [PC_SIZE - 1 : 0] i_next_seq_pc, // Next sequential PC value
        output wire o_full_mem,                    // Indicates if the instruction memory is full
        output wire o_empty_mem,                   // Indicates if the instruction memory is empty
        output wire [WORD_SIZE_IN_BYTES*8 - 1 : 0] o_instruction, // Output instruction
        output wire [PC_SIZE - 1 : 0] o_next_seq_pc, // Output for next sequential PC value
        output wire [PC_SIZE - 1 : 0] o_current_pc  // Output for current PC value
    );
    
    localparam BUS_SIZE = WORD_SIZE_IN_BYTES * 8; // Size of the data bus

    wire [PC_SIZE - 1 : 0] next_pc; // Wire for the next PC value
    wire [PC_SIZE - 1 : 0] pc;       // Wire for the current PC value

    assign o_current_pc = pc;         // Output current PC value

    /* 
        Multiplexer to select the next PC value (sequential or non-sequential) 
    */
    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_pc_unit
    (
        .selector (i_next_pc_src),               // Selects between sequential and non-sequential PC
        .data_in ({i_next_not_seq_pc, i_next_seq_pc}), // Inputs for the multiplexer
        .data_out (next_pc)                     // Output of the multiplexer
    );

    /* 
        Adder to calculate the next sequential PC 
    */
    adder 
    #
    (
        .BUS_SIZE(BUS_SIZE)
    ) 
    adder_unit 
    (
        .a (WORD_SIZE_IN_BYTES),                // Increment value (size of a word)
        .b (pc),                                // Current PC value
        .sum(o_next_seq_pc)                     // Output for the next sequential PC
    );

    /* 
        Program Counter (PC) module to maintain and update the PC value 
    */
    pc 
    #(
        .PC_WIDTH(PC_SIZE)
    ) 
    pc_unit 
    (
        .i_clk (i_clk),                         // Clock input
        .i_reset (i_reset),                     // Reset input
        .i_flush (i_flush),                     // Flush signal
        .i_clear (i_clear_mem),                 // Clear memory signal
        .i_halt (i_halt),                       // Halt signal
        .i_not_load(i_not_load),                // Signal indicating not to load new PC
        .i_enable (i_enable),                   // Enable signal
        .i_next_pc (next_pc),                   // Next PC value
        .o_pc (pc)                              // Output current PC value
    );

    /* 
        Instruction Memory module for storing and retrieving instructions 
    */
    Instruction_Memory 
    #(
        .WORD_WIDTH_BYTES (WORD_SIZE_IN_BYTES), // Width of each word in bytes
        .MEM_SIZE_WORDS (MEM_SIZE_IN_WORDS),    // Size of the memory in words
        .PC_WIDTH (PC_SIZE)                     // Width of the PC
    ) 
    instruction_memory_unit 
    (
        .i_clk (i_clk),                        // Clock input
        .i_reset (i_reset),                    // Reset input
        .i_inst_write (i_write_mem),           // Signal to write instruction to memory
        .i_pc (pc),                            // Current PC value
        .i_instruction (i_instruction),        // Input instruction
        .i_clear (i_clear_mem),                // Clear memory signal
        .o_full_mem (o_full_mem),              // Indicates if the memory is full
        .o_empty_mem (o_empty_mem),            // Indicates if the memory is empty
        .o_instruction (o_instruction)         // Output instruction
    );

endmodule

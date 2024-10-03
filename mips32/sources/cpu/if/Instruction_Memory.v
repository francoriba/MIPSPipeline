`timescale 1ns / 1ps

/* Instruction Memory: Stores and retrieves program instructions */

module Instruction_Memory
   #(
    parameter PC_WIDTH = 32, // 32 bits
    parameter WORD_WIDTH_BITS = 32, // 32 bits
    parameter WORD_WIDTH_BYTES = 4, // 4 bytes
    parameter MEM_SIZE_WORDS = 10, // 10 words
    parameter POINTER_SIZE = $clog2(MEM_SIZE_WORDS*4) // 10 words, 4 addressable bytes in each
    )
    (
    input wire i_clk, // clock signal
    input wire i_reset, // reset signal
    input wire i_clear, // clear signal
    input wire i_inst_write, // write signal
    input wire [PC_WIDTH-1:0] i_pc, // program counter
    input wire [WORD_WIDTH_BITS-1:0] i_instruction, // instruction to write
    output wire [WORD_WIDTH_BITS-1:0] o_instruction, // instruction read
    output wire o_full_mem, // memory full
    output wire o_empty_mem // memory empty
    );
    
    localparam MEM_SIZE_BITS = MEM_SIZE_WORDS * WORD_WIDTH_BITS; // 10 words of 32 bits
    localparam BYTE_SIZE = 8;
    localparam MAX_POINTER_DIR = MEM_SIZE_WORDS * WORD_WIDTH_BYTES;
    
    reg [POINTER_SIZE-1:0] pointer; // memory pointer
    reg [MEM_SIZE_BITS-1:0] memory; // memory
    
    always @(posedge i_clk)
    begin
        if(i_reset || i_clear) // if reset, clear memory and pointer
            begin
                memory <= 'b0;
                pointer <= 'b0;
            end
        else
            begin
                if(i_inst_write) // if write signal is active, write instruction to memory
                    begin
                        memory[BYTE_SIZE*pointer +: WORD_WIDTH_BITS] = i_instruction; // +: is an operator to select a range of bits
                        // 8*pointer value +: selects WORD_WIDTH bits
                        // if (8*0), the first 32 bits are selected
                        // if (8*1)*4 (4 is pointer increment), the next 32 bits (32-63) are selected
                        pointer = pointer + 4; // increment pointer by one word
                    end
            end
    end
    
    assign o_instruction = memory[BYTE_SIZE*i_pc +: WORD_WIDTH_BITS]; // instruction read from memory
                                                                      // selects 32 bits from the PC address (PC is already incremented by 4)
    assign o_full_mem = (pointer == MAX_POINTER_DIR); // if pointer reaches the end of memory, memory is full
    assign o_empty_mem = (pointer == 'b0); // if pointer is at 0, memory is empty
    
endmodule

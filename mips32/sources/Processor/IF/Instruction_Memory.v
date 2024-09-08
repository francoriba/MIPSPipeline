`timescale 1ns / 1ps

/* Memoria de instrucciones: Almacena y obtiene instrucciones del programa */

module Instruction_Memory
   #(
    parameter PC_WIDTH = 32, // 32 bits
    parameter WORD_WIDTH_BITS = 32, // 32 bits
    parameter WORD_WIDTH_BYTES = 4, // 4 bytes
    parameter MEM_SIZE_WORDS = 10, // 10 palabras
    parameter POINTER_SIZE = $clog2(MEM_SIZE_WORDS*4) // 10 palabras, 4 bytes direccionables en c/u 
    )
    (
    input wire i_clk, // seï¿½al de clock
    input wire i_reset, // seï¿½al de reset
    input wire i_clear, // seï¿½al de limpieza
    input wire i_inst_write, // seï¿½al de escritura
    input wire [PC_WIDTH-1:0] i_pc, // program counter
    input wire [WORD_WIDTH_BITS-1:0] i_instruction, // instrucciï¿½n a escribir
    output wire [WORD_WIDTH_BITS-1:0] o_instruction, // instrucciï¿½n leï¿½da
    output wire o_full_mem, // memoria llena
    output wire o_empty_mem // memoria vacï¿½a
    );
    
    localparam MEM_SIZE_BITS = MEM_SIZE_WORDS * WORD_WIDTH_BITS; // 10 palabras de 32 bits
    localparam BYTE_SIZE = 8;
    localparam MAX_PONINTER_DIR = MEM_SIZE_WORDS * WORD_WIDTH_BYTES;
    
    reg [POINTER_SIZE-1:0] pointer; // puntero de memoria
    reg [MEM_SIZE_BITS-1:0] memory; // memoria
    
    always @(posedge i_clk)
    begin
        if(i_reset || i_clear) // si hay reset, se limpia la memoria y el puntero
            begin
                memory <= 'b0;
                pointer <= 'b0;
            end
        else
            begin
                if(i_inst_write) // si hay seï¿½al de escritura, se escribe la instrucciï¿½n en la memoria
                    begin
                        memory[BYTE_SIZE*pointer +: WORD_WIDTH_BITS] = i_instruction; // +: es un operando que selcciona un rango de bits
                        //8*valor del puntero +: se seleccionan WORD_WIDTH bits
                        // si (8*0), se seleccionan los primeros 32 bits
                        // si (8*1)*4 (4 es incremento del puntero), se seleccionan los siguientes 32 bits (32-63)
                        pointer = pointer + 4; // incremento una palabra puntero
                    end
            end
    end
    
    assign o_instruction = memory[BYTE_SIZE*i_pc +: WORD_WIDTH_BITS]; // instruccion leida de la memoria
                                                                // se seleccionan 32 bits a partir de la direcciï¿½n del PC (el PC ya viene incrementado en 4)
    assign o_full_mem = (pointer == MAX_PONINTER_DIR); // si el puntero llega al final de la memoria, la memoria estï¿½ llena
    assign o_empty_mem = (pointer == 'b0); // si el puntero estï¿½ en 0, la memoria estï¿½ vacï¿½a
    
endmodule


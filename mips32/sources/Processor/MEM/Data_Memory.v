`timescale 1ns / 1ps

/* 
    Data Memory Module:
    Implements a memory block that supports read and write operations.
*/

module data_memory
    #(
        parameter ADDR_SIZE = 5,         // Size of the memory address
        parameter SLOT_SIZE = 32         // Size of each memory slot
    )
    (
        input wire i_clk,                                // Clock input
        input wire i_reset,                              // Reset input
        input wire i_flush,                              // Flush signal
        input wire i_wr_rd,                              // Write or read operation (write if 1, read if 0)
        input wire [ADDR_SIZE - 1 : 0] i_addr,           // Address for read/write operations
        input wire [SLOT_SIZE - 1 : 0] i_data,           // Data to be written into memory
        output wire [SLOT_SIZE - 1 : 0] o_data,          // Data read from memory
        output wire [2**ADDR_SIZE * SLOT_SIZE - 1 : 0] o_bus_debug // Debug bus showing entire memory content
    );

    reg [SLOT_SIZE - 1 : 0] memory [2**ADDR_SIZE - 1 : 0]; // Memory array

    integer i = 0;

    always @(posedge i_clk) 
    begin
        if (i_reset || i_flush) 
        begin
            // Reset or flush: clear all memory locations
            for (i = 0; i < 2**ADDR_SIZE; i = i + 1)
                memory[i] <= 'b0;
        end
        else
        begin
            // Write operation
            if (i_wr_rd) 
                memory[i_addr] <= i_data;
        end
    end

    // Read operation: output the data at the given address
    assign o_data = memory[i_addr];

    /* 
        Generate a debug bus that shows the entire memory content.
        This can be used for debugging purposes to inspect memory state.
    */
    generate
        genvar j;

        for (j = 0; j < 2**ADDR_SIZE; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * SLOT_SIZE - 1 : j * SLOT_SIZE] = memory[j];
        end
    endgenerate

endmodule

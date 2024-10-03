`timescale 1ns / 1ps

/*
    Configurable Register Bank Module:
    Provides functionality to read, write, and reset registers.
*/

module registers
    #(
        parameter REGISTERS_BANK_SIZE = 32,   // Number of registers in the bank
        parameter REGISTERS_SIZE = 32          // Width of each register
    )
    (
        input  wire i_clk,                              // Clock input
        input  wire i_reset,                            // Reset input
        input  wire i_flush,                            // Flush signal
        input  wire i_write_enable,                      // Write enable signal
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0] i_addr_A, // Address for reading from register A
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0] i_addr_B, // Address for reading from register B
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0] i_addr_wr, // Address for writing to register
        input  wire [REGISTERS_SIZE - 1 : 0] i_bus_wr,  // Data to be written to register
        
        output wire [REGISTERS_SIZE - 1 : 0] o_bus_A,  // Data output from register A
        output wire [REGISTERS_SIZE - 1 : 0] o_bus_B,  // Data output from register B
        output wire [REGISTERS_BANK_SIZE * REGISTERS_SIZE - 1 : 0] o_bus_debug // Debug bus showing all registers
    );
    
    reg [REGISTERS_SIZE - 1 : 0] registers [REGISTERS_BANK_SIZE - 1 : 0]; // Register array
    
    integer i; // Loop variable for initialization
    
    // Update registers on the negative edge of the clock
    always @(negedge i_clk) 
    begin
        if (i_reset || i_flush) 
        begin
            // If reset or flush is active, clear all registers
            for (i = 0; i < REGISTERS_BANK_SIZE; i = i + 1)
                registers[i] <= 'b0;
        end
        else
        begin
            if (i_write_enable)
            begin
                if (i_addr_wr != 0)
                    // Write data to the specified register
                    registers[i_addr_wr] = i_bus_wr;
                else
                    // Clear register 0
                    registers[i_addr_wr] = 'b0;
            end
        end
    end

    // Assign data from the specified registers to output buses
    assign o_bus_A = registers[i_addr_A];
    assign o_bus_B = registers[i_addr_B];

    // Generate a debug bus showing all registers
    generate
        genvar j;
        for (j = 0; j < REGISTERS_BANK_SIZE; j = j + 1) begin : GEN_DEBUG_BUS
            assign o_bus_debug[(j + 1) * REGISTERS_SIZE - 1 : j * REGISTERS_SIZE] = registers[j];
        end
    endgenerate

endmodule

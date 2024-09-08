`timescale 1ns / 1ps

/*
    Memory Stage (MEM) Module:
    Accesses memory for read and write operations as required by the instruction.
*/

module mem
    #(
        parameter IO_BUS_SIZE = 32,       // Size of the I/O bus
        parameter MEM_ADDR_SIZE = 5       // Size of memory address
    )
    (
        input wire i_clk,                                // Clock input
        input wire i_reset,                              // Reset input
        input wire i_flush,                              // Flush signal
        input wire i_mem_wr_rd,                          // Memory operation (write or read)
        input wire [1 : 0] i_mem_wr_src,                 // Source for write data
        input wire [2 : 0] i_mem_rd_src,                 // Source for read data
        input wire [MEM_ADDR_SIZE - 1 : 0] i_mem_addr,   // Memory address to access
        input wire [IO_BUS_SIZE - 1 : 0] i_bus_b,        // Data to write into memory
        output wire [IO_BUS_SIZE - 1 : 0] o_mem_rd,      // Data read from memory
        output wire [2**MEM_ADDR_SIZE * IO_BUS_SIZE - 1 : 0] o_bus_debug // Debug bus showing all memory contents
    );

    wire [8 - 1 : 0] bus_b_byte;                       // Byte portion of the write data
    wire [IO_BUS_SIZE / 2 - 1 : 0] bus_b_halfword;     // Halfword portion of the write data
    wire [IO_BUS_SIZE - 1 : 0] bus_b_uext_byte;        // Unsigned extended byte data
    wire [IO_BUS_SIZE - 1 : 0] bus_b_uext_halfword;    // Unsigned extended halfword data

    wire [8 - 1 : 0] mem_out_data_byte;                // Byte data read from memory
    wire [IO_BUS_SIZE / 2 - 1 : 0] mem_out_data_halfword; // Halfword data read from memory
    wire [IO_BUS_SIZE - 1 : 0] mem_out_data_uext_byte; // Unsigned byte data read from memory
    wire [IO_BUS_SIZE - 1 : 0] mem_out_data_uext_halfword; // Unsigned halfword data read from memory
    wire [IO_BUS_SIZE - 1 : 0] mem_out_data_sext_byte; // Signed byte data read from memory
    wire [IO_BUS_SIZE - 1 : 0] mem_out_data_sext_halfword; // Signed halfword data read from memory

    wire [IO_BUS_SIZE - 1 : 0] mem_in_data;            // Data to be written into memory
    wire [IO_BUS_SIZE - 1 : 0] mem_out_data;           // Data read from memory

    // Assign portions of write data to individual signals
    assign bus_b_byte = i_bus_b[8 - 1 : 0];
    assign bus_b_halfword = i_bus_b[IO_BUS_SIZE / 2 - 1 : 0];

    // Assign portions of memory output data to individual signals
    assign mem_out_data_byte = mem_out_data[8 - 1 : 0];
    assign mem_out_data_halfword = mem_out_data[IO_BUS_SIZE / 2 - 1 : 0];

    // Data Memory module instantiation
    data_memory
    #(
        .ADDR_SIZE (MEM_ADDR_SIZE),       // Size of memory address
        .SLOT_SIZE (IO_BUS_SIZE)          // Size of each memory slot
    )
    data_memory_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_flush (i_flush),
        .i_wr_rd (i_mem_wr_rd),           // Write or read operation
        .i_addr (i_mem_addr),             // Memory address
        .i_data (mem_in_data),            // Data to write into memory
        .o_data (mem_out_data),           // Data read from memory
        .o_bus_debug (o_bus_debug)        // Debug bus output
    );

    /* Selects the data to write into memory based on the write source */
    mux 
    #(
        .CHANNELS (3), 
        .BUS_SIZE (IO_BUS_SIZE)
    ) 
    mux_write_mem_unit
    (
        .selector (i_mem_wr_src),          // Selector for write data source
        .data_in ({bus_b_uext_byte, bus_b_uext_halfword, i_bus_b}),
        .data_out (mem_in_data)            // Data to be written into memory
    );

    /* Selects the format of the data read from memory (extended, halfword, byte, full) */
    mux 
    #(
        .CHANNELS (5), 
        .BUS_SIZE (IO_BUS_SIZE)
    ) 
    mux_read_format_unit
    (
        .selector (i_mem_rd_src),          // Selector for read data format
        .data_in ({mem_out_data_uext_byte, mem_out_data_uext_halfword, mem_out_data_sext_byte, mem_out_data_sext_halfword, mem_out_data}),
        .data_out (o_mem_rd)               // Data read from memory
    );

    /* Extends byte data to the full bus width for unsigned halfword extension */
    extend 
    #(
        .DATA_ORIGINAL_SIZE (IO_BUS_SIZE / 2), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    extend_b_usig_halfword_unit 
    (
        .i_value (bus_b_halfword),
        .i_is_signed (1'b0),
        .o_extended_value (bus_b_uext_halfword)
    );

    /* Extends byte data to the full bus width for unsigned byte extension */
    extend 
    #(
        .DATA_ORIGINAL_SIZE (8), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    extend_b_usig_byte_unit 
    (
        .i_value (bus_b_byte),
        .i_is_signed (1'b0),
        .o_extended_value (bus_b_uext_byte)
    );

    /* Extends halfword data to the full bus width for unsigned halfword extension */
    extend 
    #(
        .DATA_ORIGINAL_SIZE (IO_BUS_SIZE / 2), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    extend_usig_mem_out_halfword_unit 
    (
        .i_value (mem_out_data_halfword),
        .i_is_signed (1'b0),
        .o_extended_value (mem_out_data_uext_halfword)
    );

    /* Extends byte data to the full bus width for unsigned byte extension */
    extend 
    #(
        .DATA_ORIGINAL_SIZE (8), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    extend_usig_mem_out_byte_unit 
    (
        .i_value (mem_out_data_byte),
        .i_is_signed (1'b0),
        .o_extended_value (mem_out_data_uext_byte)
    );

    /* Extends halfword data to the full bus width for signed halfword extension */
    extend 
    #(
        .DATA_ORIGINAL_SIZE (IO_BUS_SIZE / 2), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    ) 
    extend_sig_mem_out_halfword_unit
    (
        .i_value (mem_out_data_halfword),
        .i_is_signed (1'b1),
        .o_extended_value (mem_out_data_sext_halfword)
    );

    /* Extends byte data to the full bus width for signed byte extension */
    extend
    #(
        .DATA_ORIGINAL_SIZE (8), 
        .DATA_EXTENDED_SIZE (IO_BUS_SIZE)
    )
    extend_sig_mem_out_byte_unit
    (
        .i_value (mem_out_data_byte),
        .i_is_signed (1'b1),
        .o_extended_value (mem_out_data_sext_byte)
    );

endmodule

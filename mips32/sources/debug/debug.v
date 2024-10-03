`timescale 1ns / 1ps

/*
    Debug Module:
    This module manages communication with UART for debugging purposes, 
    handles register and memory printing, and interfaces with the MIPS processor.
*/

module debug
    #(
        // Parameters for UART and data buses
        parameter UART_BUS_SIZE = 8,
        parameter DATA_IN_BUS_SIZE = UART_BUS_SIZE * 4,
        parameter DATA_OUT_BUS_SIZE = UART_BUS_SIZE * 7,
        parameter REGISTER_SIZE = 32,
        parameter REGISTER_BANK_BUS_SIZE = REGISTER_SIZE * 32,
        parameter MEMORY_SLOT_SIZE = 32,
        parameter MEMORY_DATA_BUS_SIZE = MEMORY_SLOT_SIZE * 32
    )
    (
        input wire i_clk, // Clock signal
        input wire i_reset, // Reset signal
        input wire i_uart_empty, // UART buffer empty signal
        input wire i_uart_full, // UART buffer full signal
        input wire i_instruction_memory_empty, // Instruction memory empty signal
        input wire i_instruction_memory_full, // Instruction memory full signal
        input wire i_mips_end_program, // End of program signal from MIPS processor
        input wire [UART_BUS_SIZE - 1 : 0] i_uart_data_rd, // Data read from UART
        input wire [REGISTER_BANK_BUS_SIZE - 1 : 0] i_registers_content, // Content of registers
        input wire [MEMORY_DATA_BUS_SIZE - 1 : 0] i_memory_content, // Content of memory
        input wire [REGISTER_SIZE - 1 : 0] i_current_pc, // Current program counter
        output wire o_uart_wr, // UART write enable
        output wire o_uart_rd, // UART read enable
        output wire o_mips_instruction_wr, // Write new instruction signal
        output wire o_mips_flush, // Flush the pipeline
        output wire o_mips_clear_program, // Clear the program memory
        output wire o_mips_enabled, // Enable the MIPS processor
        output wire [UART_BUS_SIZE - 1 : 0] o_uart_data_wr, // Data to write to UART
        output wire [REGISTER_SIZE - 1 : 0] o_mips_instruction, // MIPS instruction to write
        output wire [4 : 0] o_state // Current state of the debug module
    );

    // Internal signals
    wire start_uart_rd; // Start reading from UART
    wire start_uart_wr; // Start writing to UART
    wire start_uart_wr_control; // Start writing control data to UART
    wire start_uart_wr_memory; // Start writing memory data to UART
    wire start_uart_wr_printer; // Start writing printer data to UART
    wire start_register_print; // Start printing register data
    wire start_memory_print; // Start printing memory data
    wire end_uart_rd; // UART read operation finished
    wire end_uart_wr; // UART write operation finished
    wire end_register_print; // Register printing operation finished
    wire end_memory_print; // Memory printing operation finished
    wire [UART_BUS_SIZE - 1 : 0] clk_cicle; // Clock cycle count
    wire [DATA_IN_BUS_SIZE - 1 : 0] data_uart_rd; // Data read from UART
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr; // Data to write to UART
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_control; // Control data to write to UART
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_memory; // Memory data to write to UART
    wire [DATA_OUT_BUS_SIZE - 1 : 0] data_uart_wr_printer; // Printer data to write to UART

    // Determine which data to write to UART
    assign start_uart_wr = start_uart_wr_control | start_uart_wr_memory | start_uart_wr_printer;

    // Register to store UART write data
    reg [DATA_OUT_BUS_SIZE - 1 : 0] reg_data_uart_wr;

    // Update UART write data register on clock edge
    always @(posedge i_clk) begin
        if (i_reset)
            reg_data_uart_wr <= 'b0;
        else begin
            if (start_uart_wr_control)
                reg_data_uart_wr <= data_uart_wr_control;
            else if (start_uart_wr_memory)
                reg_data_uart_wr <= data_uart_wr_memory;
            else if (start_uart_wr_printer)
                reg_data_uart_wr <= data_uart_wr_printer;
        end
    end

    // Assign UART write data
    assign data_uart_wr = reg_data_uart_wr;

    // Buffer reader for UART data
    buffer_reader
    #(
        .DATA_LEN (UART_BUS_SIZE),
        .DATA_OUT_LEN (DATA_IN_BUS_SIZE)
    )
    buffer_reader_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_is_uart_empty (i_uart_empty),
        .i_rd (start_uart_rd),
        .i_uart_data (i_uart_data_rd),
        .o_uart_rd (o_uart_rd),
        .o_rd_finished (end_uart_rd),
        .o_rd_buffer (data_uart_rd)
    );

    // Buffer writer for UART data
    buffer_writer
    #(
        .DATA_LEN (UART_BUS_SIZE),
        .DATA_IN_LEN (DATA_OUT_BUS_SIZE)
    )
    buffer_writer_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_is_uart_full (i_uart_full),
        .i_wr (start_uart_wr),
        .i_wr_data (data_uart_wr),
        .o_uart_wr (o_uart_wr),
        .o_wr_finished (end_uart_wr),
        .o_wr_buffer (o_uart_data_wr)
    );

    // Register printer for printing register data
    reg_printer
    #(
        .UART_BUS_SIZE (UART_BUS_SIZE),
        .DATA_OUT_BUS_SIZE (DATA_OUT_BUS_SIZE),
        .REGISTER_SIZE (REGISTER_SIZE),
        .REGISTER_BANK_BUS_SIZE (REGISTER_BANK_BUS_SIZE)
    )
    reg_printer_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_start (start_register_print),
        .i_is_mem(1'b0),
        .i_reg_bank (i_registers_content),
        .i_clk_cicle (clk_cicle),
        .i_current_pc (i_current_pc),
        .i_write_finish (end_uart_wr),
        .o_write (start_uart_wr_printer),
        .o_finish (end_register_print),
        .o_data_write (data_uart_wr_printer)
    );

    // Register printer for printing memory data
    reg_printer
    #(
        .UART_BUS_SIZE (UART_BUS_SIZE),
        .DATA_OUT_BUS_SIZE (DATA_OUT_BUS_SIZE),
        .REGISTER_SIZE (MEMORY_SLOT_SIZE),
        .REGISTER_BANK_BUS_SIZE (MEMORY_DATA_BUS_SIZE)
    )
    mem_printer_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_start (start_memory_print),
        .i_is_mem(1'b1),
        .i_reg_bank (i_memory_content),
        .i_clk_cicle (clk_cicle),
        .i_current_pc (i_current_pc),
        .i_write_finish (end_uart_wr),
        .o_write (start_uart_wr_memory),
        .o_finish (end_memory_print),
        .o_data_write (data_uart_wr_memory)
    );

    // Interface for managing debug operations and interactions with the MIPS processor
    interface
    #(
        .UART_DATA_LEN (UART_BUS_SIZE),
        .DATA_IN_LEN (DATA_IN_BUS_SIZE),
        .DATA_OUT_LEN (DATA_OUT_BUS_SIZE),
        .REG_LEN (REGISTER_SIZE)
    )
    interface_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_instr_mem_empty (i_instruction_memory_empty),
        .i_instr_mem_full (i_instruction_memory_full),
        .i_finish_program (i_mips_end_program),
        .i_uart_read_finish (end_uart_rd),
        .i_uart_write_finish (end_uart_wr),
        .i_print_regs_finish (end_register_print),
        .i_print_mem_finish (end_memory_print),
        .i_data_uart_read (data_uart_rd),
        .o_clk_cicle (clk_cicle),
        .o_uart_write (start_uart_wr_control),
        .o_uart_read (start_uart_rd),
        .o_print_regs (start_register_print),
        .o_print_mem (start_memory_print),
        .o_new_instruction (o_mips_instruction_wr),
        .o_flush (o_mips_flush),
        .o_clear_program (o_mips_clear_program),
        .o_mips_enabled (o_mips_enabled),
        .o_ctrl_info (data_uart_wr_control),
        .o_mips_instruction (o_mips_instruction),
        .o_state (o_state)
    );

endmodule

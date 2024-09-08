`timescale 1ns / 1ps

module top 
    #(
        parameter MIPS_BUS_SIZE = 32,
        parameter MIPS_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES = 4,
        parameter MIPS_INSTRUCTION_MEMORY_SIZE_IN_WORDS = 64,
        parameter MIPS_REGISTERS_BANK_SIZE = 32,
        parameter MIPS_DATA_MEMORY_ADDR_SIZE = 5,
        parameter UART_DATA_BITS = 8,
        parameter UART_SB_TICKS = 16,
        parameter UART_DVSR_BIT = 9,
        parameter UART_DVSR = 326,
        parameter UART_FIFO_SIZE = 512
    )
    (
        input wire i_clk, 
        input wire i_reset,
        input wire i_rx,
        output wire o_tx
    );

	localparam MIPS_REGISTER_CONTETNT_BUS_SIZE = MIPS_REGISTERS_BANK_SIZE * MIPS_BUS_SIZE;
	localparam MIPS_MEMORY_CONTETNT_BUS_SIZE   = 2**MIPS_DATA_MEMORY_ADDR_SIZE * MIPS_BUS_SIZE;

	wire mips_flush;
	wire mips_clear_program;
	wire mips_enabled;
	wire mips_end_program;
	wire mips_instruction_wr;
	wire mips_instruction_memory_full;
	wire mips_instruction_memory_empty;
	wire [MIPS_BUS_SIZE - 1 : 0] mips_instruction;
	wire [MIPS_REGISTER_CONTETNT_BUS_SIZE - 1 : 0] mips_registers_content;
	wire [MIPS_MEMORY_CONTETNT_BUS_SIZE - 1 : 0] mips_memory_content;
    wire [MIPS_BUS_SIZE - 1 : 0] current_pc;

    wire uart_rd;
    wire uart_wr;
    wire uart_rx_empty;
    wire uart_tx_full;
	wire [UART_DATA_BITS - 1 : 0] uart_data_wr;
	wire [UART_DATA_BITS - 1 : 0] uart_data_rd;

    wire [4: 0] state;

    uart
    #(
      .BITS_DATA (UART_DATA_BITS),
      .SB_TICK (UART_SB_TICKS),
      .COUNTER_BITS (UART_DVSR_BIT),
      .COUNTER_MOD (UART_DVSR),
      .FIFO_SIZE (UART_FIFO_SIZE)
    )
    uart_unit
    (
      .i_clk (i_clk),
      .i_reset (i_reset),
      .i_read_uart (uart_rd),
      .i_write_uart (uart_wr),
      .i_uart_rx (i_rx),
      .i_data_to_write (uart_data_wr),
      .o_tx_full (uart_tx_full),
      .o_rx_empty (uart_rx_empty),
      .o_uart_tx (o_tx),
      .o_data_to_read (uart_data_rd)
    );

	debug
	#(
		.UART_BUS_SIZE (UART_DATA_BITS),
        .DATA_IN_BUS_SIZE (UART_DATA_BITS * 4),
        .DATA_OUT_BUS_SIZE (UART_DATA_BITS * 7),
		.REGISTER_SIZE (MIPS_BUS_SIZE),
		.REGISTER_BANK_BUS_SIZE (MIPS_REGISTER_CONTETNT_BUS_SIZE),
		.MEMORY_SLOT_SIZE (MIPS_BUS_SIZE),
		.MEMORY_DATA_BUS_SIZE (MIPS_MEMORY_CONTETNT_BUS_SIZE)
	)
	debug_unit
	(
		.i_clk (i_clk),
		.i_reset (i_reset),
		.i_uart_empty (uart_rx_empty),
		.i_uart_full (uart_tx_full),
		.i_instruction_memory_empty (mips_instruction_memory_empty),
		.i_instruction_memory_full (mips_instruction_memory_full),
		.i_mips_end_program (mips_end_program),
		.i_uart_data_rd (uart_data_rd),
		.i_registers_content (mips_registers_content),
		.i_memory_content (mips_memory_content),
        .i_current_pc (current_pc),
		.o_uart_wr (uart_wr),
		.o_uart_rd (uart_rd),
		.o_mips_instruction_wr (mips_instruction_wr),
		.o_mips_flush (mips_flush),
		.o_mips_clear_program (mips_clear_program),
		.o_mips_enabled (mips_enabled),
		.o_uart_data_wr (uart_data_wr),
		.o_mips_instruction (mips_instruction),
        .o_state (state)
	);

    mips
    #(
        .PC_BUS_SIZE (MIPS_BUS_SIZE),
        .DATA_BUS_SIZE (MIPS_BUS_SIZE),
        .INSTRUCTION_BUS_SIZE (MIPS_BUS_SIZE),
        .INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES (MIPS_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES),
        .INSTRUCTION_MEMORY_SIZE_IN_WORDS (MIPS_INSTRUCTION_MEMORY_SIZE_IN_WORDS),
        .REGISTERS_BANK_SIZE (MIPS_REGISTERS_BANK_SIZE),
        .DATA_MEMORY_ADDR_SIZE (MIPS_DATA_MEMORY_ADDR_SIZE)
    )
    mips_unit
    (
        .i_clk (i_clk),
        .i_reset (i_reset),
        .i_enable (mips_enabled),
        .i_flush (mips_flush),
        .i_clear_program (mips_clear_program),
        .i_ins_mem_wr (mips_instruction_wr),
        .i_ins (mips_instruction),
        .o_end_program (mips_end_program),
        .o_ins_mem_full (mips_instruction_memory_full),
        .o_ins_mem_empty (mips_instruction_memory_empty),
        .o_registers (mips_registers_content),
        .o_mem_data (mips_memory_content),
        .o_current_pc (current_pc)
    );

endmodule
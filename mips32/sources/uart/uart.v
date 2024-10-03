`timescale 1ns / 1ps

module uart
    #(
        parameter BITS_DATA = 8,
        parameter SB_TICK  = 16,
        parameter COUNTER_BITS  = 9,
        parameter COUNTER_MOD      = 326,
        parameter FIFO_SIZE = 8
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_read_uart,
        input wire i_write_uart,
        input wire i_uart_rx,
        input wire [BITS_DATA - 1 : 0] i_data_to_write,
        output wire o_tx_full,
        output wire o_rx_empty,
        output wire o_uart_tx,
        output wire [BITS_DATA - 1 : 0] o_data_to_read
    );
    
    wire tick;
    wire rx_done, tx_done;
    wire tx_empty, tx_fifo_not_empty;
    wire [BITS_DATA - 1 : 0] tx_fifo_out, rx_data_out;
    
    baudrate_generator
    #(
      .COUNTER_BITS (COUNTER_BITS),
      .LIMITE (COUNTER_MOD)
    )
    baud_gen_unit
    (
      .i_clk (i_clk),
      .i_reset (i_reset),
      .o_ticks (tick),
      .baud_rate ()
    );
    
    uart_rx
    #(
      .BITS_DATA (BITS_DATA),
      .SB_TICK  (SB_TICK)
    )
    uart_rx_unit
    (
      .i_clk          (i_clk),
      .i_reset        (i_reset),
      .i_rx           (i_uart_rx),
      .i_tick       (tick),
      .o_rx_done (rx_done),
      .o_data_out         (rx_data_out)
    );
    
    uart_tx
    #(
      .BITS_DATA (BITS_DATA),
      .SB_TICK  (SB_TICK)
    )
    uart_tx_unit
    (
      .i_clk          (i_clk),
      .i_reset        (i_reset),
      .i_tx_start     (tx_fifo_not_empty),
      .i_tick       (tick),
      .i_data_in          (tx_fifo_out),
      .o_tx_done (tx_done),
      .o_tx           (o_uart_tx)
    );
 
    fifo_buffer
    #(
      .BITS_DATA  (FIFO_SIZE),
      .BITS_PTR (BITS_DATA)
    )
    fifo_rx_unit
    (
      .i_clk    (i_clk),
      .i_reset  (i_reset),
      .i_read     (i_read_uart),
      .i_write     (rx_done),
      .i_write_data (rx_data_out),
      .o_is_empty  (o_rx_empty),
      .o_is_full   (),
      .o_read_data (o_data_to_read)
    );
    
    fifo_buffer
    #(
      .BITS_DATA  (FIFO_SIZE),
      .BITS_PTR (BITS_DATA)
    )
    fifo_tx_unit
    (
      .i_clk (i_clk),
      .i_reset (i_reset),
      .i_read (tx_done),
      .i_write (i_write_uart),
      .i_write_data (i_data_to_write),
      .o_is_empty (tx_empty),
      .o_is_full (o_tx_full),
      .o_read_data (tx_fifo_out)
    );
    
    assign tx_fifo_not_empty = ~tx_empty;
    
endmodule

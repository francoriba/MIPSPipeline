`timescale 1ns / 1ps

/*
    Write Back (WB) Stage Module:
    This stage writes the result from either the ALU or memory back to the registers.
*/

module wb
    #(
        parameter BUS_WIDTH = 32   // Width of the data bus
    )
    (
        input  wire i_mem_to_reg,                   // Selects whether to write the memory result or ALU result
        input  wire [BUS_WIDTH - 1 : 0] i_alu_result, // ALU result to be written back
        input  wire [BUS_WIDTH - 1 : 0] i_mem_result, // Memory result to be written back
        output wire [BUS_WIDTH - 1 : 0] o_wb_data    // Data to be written to the registers
    );

    /* 
        Selects between ALU result and memory result based on the i_mem_to_reg signal.
        If i_mem_to_reg is 1, write the memory result; otherwise, write the ALU result.
    */
    mux 
    #(
        .CHANNELS (2), 
        .BUS_SIZE (BUS_WIDTH)
    ) 
    mux_wb_unit
    (
        .selector (i_mem_to_reg),                   // Select signal for the mux
        .data_in ({i_alu_result, i_mem_result}),   // Data inputs to the mux
        .data_out (o_wb_data)                      // Output data from the mux
    );

endmodule

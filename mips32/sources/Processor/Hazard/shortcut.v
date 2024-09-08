`timescale 1ns / 1ps

/*
    Short Circuit Detection Module:
    This module determines the source of data for registers A and B by checking
    if there is a data hazard between different pipeline stages.
*/

module fowarding
    #(
        parameter MEM_ADDR_SIZE = 5,

        // Data source identifiers for different pipeline stages
        parameter DATA_SRC_ID_EX = 2'b00, // Data source from ID/EX stage
        parameter DATA_SRC_MEM_WB = 2'b01, // Data source from MEM/WB stage
        parameter DATA_SRC_EX_MEM = 2'b10  // Data source from EX/MEM stage
    )
    (   
        input  wire                         i_ex_mem_wb, // Indicates if data from EX/MEM stage is valid
        input  wire                         i_mem_wb_wb, // Indicates if data from MEM/WB stage is valid
        input  wire [4 : 0]                 i_id_ex_rs, // Source register A in ID/EX stage
        input  wire [4 : 0]                 i_id_ex_rt, // Source register B in ID/EX stage
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_ex_mem_addr, // Address from EX/MEM stage
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_mem_wb_addr, // Address from MEM/WB stage
        output wire [1 : 0]                 o_sc_data_a_src, // Data source for register A
        output wire [1 : 0]                 o_sc_data_b_src  // Data source for register B
    );

    /*
        Determine the source of data for register A:
        - If the address from EX/MEM stage matches the register ID/EX address, and the register is not zero, and EX/MEM data is valid,
          set the source to EX/MEM.
        - If the address from MEM/WB stage matches the register ID/EX address, and the register is not zero, and MEM/WB data is valid,
          set the source to MEM/WB.
        - Otherwise, the source is from ID/EX.
    */
    assign o_sc_data_a_src = (i_ex_mem_addr == i_id_ex_rs && i_id_ex_rs != 0 && i_ex_mem_wb) ? DATA_SRC_EX_MEM :
                             (i_mem_wb_addr == i_id_ex_rs && i_id_ex_rs != 0 && i_mem_wb_wb) ? DATA_SRC_MEM_WB :
                                                                                              DATA_SRC_ID_EX;

    /*
        Determine the source of data for register B:
        - If the address from EX/MEM stage matches the register ID/EX address, and the register is not zero, and EX/MEM data is valid,
          set the source to EX/MEM.
        - If the address from MEM/WB stage matches the register ID/EX address, and the register is not zero, and MEM/WB data is valid,
          set the source to MEM/WB.
        - Otherwise, the source is from ID/EX.
    */
    assign o_sc_data_b_src = (i_ex_mem_addr == i_id_ex_rt && i_id_ex_rt != 0 && i_ex_mem_wb) ? DATA_SRC_EX_MEM :
                             (i_mem_wb_addr == i_id_ex_rt && i_id_ex_rt != 0 && i_mem_wb_wb) ? DATA_SRC_MEM_WB :
                                                                                              DATA_SRC_ID_EX;

endmodule

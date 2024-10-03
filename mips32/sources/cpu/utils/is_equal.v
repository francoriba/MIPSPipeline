`timescale 1ns / 1ps

module is_equal
    #(
        parameter DATA_LEN = 32
    )
    (
        input  wire [DATA_LEN - 1 : 0] i_data_A,
        input  wire [DATA_LEN - 1 : 0] i_data_B,
        output wire o_is_equal
    );

    assign o_is_equal = i_data_A == i_data_B;

endmodule
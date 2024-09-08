`timescale 1ns / 1ps

module shift_left
    #(
        parameter DATA_LEN = 32,
        parameter POS_TO_SHIFT = 2 // number of positions to shift
    )
    (
        input  wire [DATA_LEN - 1 : 0] i_value,
        output wire [DATA_LEN - 1 : 0] o_shifted
    );

    assign o_shifted = i_value << POS_TO_SHIFT;

endmodule

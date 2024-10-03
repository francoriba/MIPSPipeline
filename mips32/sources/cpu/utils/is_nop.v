`timescale 1ns / 1ps

module is_nop
    #(
        parameter DATA_LEN = 32
    )
    (
        input  wire [DATA_LEN - 1 : 0] i_opp,
        output wire o_is_nop
    );

    assign o_is_nop = i_opp == 0; //check length of i_opp

endmodule

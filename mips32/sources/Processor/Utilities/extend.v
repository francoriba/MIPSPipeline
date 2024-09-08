`timescale 1ns / 1ps

module extend
    #(
        parameter DATA_ORIGINAL_SIZE = 16,
        parameter DATA_EXTENDED_SIZE = 32
    )
    (
        input wire [DATA_ORIGINAL_SIZE - 1 : 0] i_value,
        input wire i_is_signed,  // Control signal: 1 for signed extension, 0 for unsigned extension
        output wire [DATA_EXTENDED_SIZE - 1 : 0] o_extended_value
    );

    // Extend the input value based on the i_is_signed control signal
    assign o_extended_value = i_is_signed ? 
        {{(DATA_EXTENDED_SIZE - DATA_ORIGINAL_SIZE){i_value[DATA_ORIGINAL_SIZE - 1]}}, i_value} : 
        {{(DATA_EXTENDED_SIZE - DATA_ORIGINAL_SIZE){1'b0}}, i_value};

endmodule
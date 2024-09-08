`timescale 1ns / 1ps

module tb_shift_left;

    parameter DATA_LEN = 32;
    parameter POS_TO_SHIFT = 2; // Default number of positions to shift

    // test signals
    reg [DATA_LEN - 1 : 0] i_value;
    wire [DATA_LEN - 1 : 0] o_shifted;

    // shift_left module
    shift_left #(
        .DATA_LEN(DATA_LEN),
        .POS_TO_SHIFT(POS_TO_SHIFT)
    ) uut (
        .i_value(i_value),
        .o_shifted(o_shifted)
    );

    initial begin
        // Test case 1: Simple value
        i_value = 32'b0000_0000_0000_0000_0000_0000_0000_0001; // 1
        #10;
        $display("Input: %b, Shifted: %b", i_value, o_shifted);
        if (o_shifted === (i_value << POS_TO_SHIFT))
            $display("TEST 1 OK");
        else
            $display("TEST 1 FAILED");

        // Test case 2: Simple value
        i_value = 32'b0000_0000_0000_0000_0000_0000_0000_0010; // 2
        #10;
        $display("Input: %b, Shifted: %b", i_value, o_shifted);
        if (o_shifted === (i_value << POS_TO_SHIFT))
            $display("TEST 2 OK");
        else
            $display("TEST 2 FAILED");

        // Test case 3: A larger value
        i_value = 32'b0000_0000_0000_0000_1111_1111_1111_1111; // 65535
        #10;
        $display("Input: %b, Shifted: %b", i_value, o_shifted);
        if (o_shifted === (i_value << POS_TO_SHIFT))
            $display("TEST 3 OK");
        else
            $display("TEST 3 FAILED");

        // Test case 4: All bits set to 1
        i_value = 32'b1111_1111_1111_1111_1111_1111_1111_1111; // 0xFFFFFFFF
        #10;
        $display("Input: %b, Shifted: %b", i_value, o_shifted);
        if (o_shifted === (i_value << POS_TO_SHIFT))
            $display("TEST 4 OK");
        else
            $display("TEST 4 FAILED");

        // Test case 5: All bits set to 0
        i_value = 32'b0000_0000_0000_0000_0000_0000_0000_0000; // 0
        #10;
        $display("Input: %b, Shifted: %b", i_value, o_shifted);
        if (o_shifted === (i_value << POS_TO_SHIFT))
            $display("TEST 5 OK");
        else
            $display("TEST 5 FAILED");

        $stop;
    end
endmodule

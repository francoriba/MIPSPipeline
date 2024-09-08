`timescale 1ns / 1ps

module tb_extend;

    parameter DATA_ORIGINAL_SIZE = 16;
    parameter DATA_EXTENDED_SIZE = 32;

    // test signals
    reg [DATA_ORIGINAL_SIZE - 1 : 0] i_value;
    reg i_is_signed;
    wire [DATA_EXTENDED_SIZE - 1 : 0] o_extended_value;

    // extend module
    extend #(
        .DATA_ORIGINAL_SIZE(DATA_ORIGINAL_SIZE),
        .DATA_EXTENDED_SIZE(DATA_EXTENDED_SIZE)
    ) uut (
        .i_value(i_value),
        .i_is_signed(i_is_signed),
        .o_extended_value(o_extended_value)
    );

    initial begin
        // Test case 1: Positive number, signed extension
        i_value = 16'b0000_0000_0000_1010; // 10
        i_is_signed = 1;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b0000_0000_0000_0000_0000_0000_0000_1010)
            $display("TEST 1 OK");
        else
            $display("TEST 1 FAILED");

        // Test case 2: Negative number, signed extension
        i_value = 16'b1111_1111_1111_1010; // -6
        i_is_signed = 1;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b1111_1111_1111_1111_1111_1111_1111_1010)
            $display("TEST 2 OK");
        else
            $display("TEST 2 FAILED");

        // Test case 3: Zero, unsigned extension
        i_value = 16'b0000_0000_0000_0000; // 0
        i_is_signed = 0;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b0000_0000_0000_0000_0000_0000_0000_0000)
            $display("TEST 3 OK");
        else
            $display("TEST 3 FAILED");

        // Test case 4: Maximum positive number, signed extension
        i_value = 16'b0111_1111_1111_1111; // 32767
        i_is_signed = 1;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b0000_0000_0000_0000_0111_1111_1111_1111)
            $display("TEST 4 OK");
        else
            $display("TEST 4 FAILED");

        // Test case 5: Maximum negative number, signed extension
        i_value = 16'b1000_0000_0000_0000; // -32768
        i_is_signed = 1;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b1111_1111_1111_1111_1000_0000_0000_0000)
            $display("TEST 5 OK");
        else
            $display("TEST 5 FAILED");

        // Test case 6: Maximum positive number, unsigned extension
        i_value = 16'b0111_1111_1111_1111; // 32767
        i_is_signed = 0;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b0000_0000_0000_0000_0111_1111_1111_1111)
            $display("TEST 6 OK");
        else
            $display("TEST 6 FAILED");

        // Test case 7: A positive number, unsigned extension
        i_value = 16'b0000_0000_0000_1010; // 10
        i_is_signed = 0;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b0000_0000_0000_0000_0000_0000_0000_1010)
            $display("TEST 7 OK");
        else
            $display("TEST 7 FAILED");

        // Test case 8: A negative number, unsigned extension
        i_value = 16'b1111_1111_1111_1010; // 65530 in unsigned
        i_is_signed = 0;
        #10;
        $display("Input: %b, Signed Extend: %b, Output: %b", i_value, i_is_signed, o_extended_value);
        if (o_extended_value === 32'b0000_0000_0000_0000_1111_1111_1111_1010)
            $display("TEST 8 OK");
        else
            $display("TEST 8 FAILED");

        $stop;
    end
endmodule

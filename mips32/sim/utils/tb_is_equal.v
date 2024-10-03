`timescale 1ns / 1ps

module tb_is_equal;

    parameter DATA_LEN = 32;

    // test signals
    reg [DATA_LEN - 1 : 0] i_data_A;
    reg [DATA_LEN - 1 : 0] i_data_B;
    wire o_is_equal;

    // is_equal module
    is_equal #(
        .DATA_LEN(DATA_LEN)
    ) uut (
        .i_data_A(i_data_A),
        .i_data_B(i_data_B),
        .o_is_equal(o_is_equal)
    );

    initial begin
        // Test case 1: Values are equal
        i_data_A = 32'b0000_0000_0000_0000_0000_0000_0000_1010; // 10
        i_data_B = 32'b0000_0000_0000_0000_0000_0000_0000_1010; // 10
        #10;
        $display("A: %b, B: %b, Equal: %b", i_data_A, i_data_B, o_is_equal);
        if (o_is_equal === 1)
            $display("TEST 1 OK");
        else
            $display("TEST 1 FAILED");

        // Test case 2: Values are not equal
        i_data_A = 32'b0000_0000_0000_0000_0000_0000_0000_1010; // 10
        i_data_B = 32'b0000_0000_0000_0000_0000_0000_0000_1100; // 12
        #10;
        $display("A: %b, B: %b, Equal: %b", i_data_A, i_data_B, o_is_equal);
        if (o_is_equal === 0)
            $display("TEST 2 OK");
        else
            $display("TEST 2 FAILED");

        // Test case 3: All bits set to 1 (equal)
        i_data_A = 32'b1111_1111_1111_1111_1111_1111_1111_1111; // 0xFFFFFFFF
        i_data_B = 32'b1111_1111_1111_1111_1111_1111_1111_1111; // 0xFFFFFFFF
        #10;
        $display("A: %b, B: %b, Equal: %b", i_data_A, i_data_B, o_is_equal);
        if (o_is_equal === 1)
            $display("TEST 3 OK");
        else
            $display("TEST 3 FAILED");

        // Test case 4: All bits set to 0 (equal)
        i_data_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000; // 0
        i_data_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000; // 0
        #10;
        $display("A: %b, B: %b, Equal: %b", i_data_A, i_data_B, o_is_equal);
        if (o_is_equal === 1)
            $display("TEST 4 OK");
        else
            $display("TEST 4 FAILED");

        // Test case 5: One bit difference
        i_data_A = 32'b0000_0000_0000_0000_0000_0000_0000_0001; // 1
        i_data_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000; // 0
        #10;
        $display("A: %b, B: %b, Equal: %b", i_data_A, i_data_B, o_is_equal);
        if (o_is_equal === 0)
            $display("TEST 5 OK");
        else
            $display("TEST 5 FAILED");

        // Test case 6: Different upper half
        i_data_A = 32'b1111_1111_1111_1111_0000_0000_0000_0000; // 0xFFFF0000
        i_data_B = 32'b0000_0000_0000_0000_0000_0000_0000_0000; // 0x00000000
        #10;
        $display("A: %b, B: %b, Equal: %b", i_data_A, i_data_B, o_is_equal);
        if (o_is_equal === 0)
            $display("TEST 6 OK");
        else
            $display("TEST 6 FAILED");

        // Test case 7: Different lower half
        i_data_A = 32'b0000_0000_0000_0000_0000_0000_0000_0000; // 0x00000000
        i_data_B = 32'b0000_0000_0000_0000_1111_1111_1111_1111; // 0x0000FFFF
        #10;
        $display("A: %b, B: %b, Equal: %b", i_data_A, i_data_B, o_is_equal);
        if (o_is_equal === 0)
            $display("TEST 7 OK");
        else
            $display("TEST 7 FAILED");

        $stop;
    end
endmodule

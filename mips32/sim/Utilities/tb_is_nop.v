`timescale 1ns / 1ps

module tb_is_nop;

    parameter DATA_LEN = 32;

    // test signals
    reg [DATA_LEN - 1 : 0] i_opp;
    wire o_is_nop;

    // is_nop module
    is_nop #(
        .DATA_LEN(DATA_LEN)
    ) uut (
        .i_opp(i_opp),
        .o_is_nop(o_is_nop)
    );

    initial begin
        // Test case 1: i_opp is 0 (NOP)
        i_opp = 32'b0000_0000_0000_0000_0000_0000_0000_0000; // 0
        #10;
        $display("i_opp: %b, o_is_nop: %b", i_opp, o_is_nop);
        if (o_is_nop === 1)
            $display("TEST 1 OK");
        else
            $display("TEST 1 FAILED");

        // Test case 2: i_opp is non-zero
        i_opp = 32'b0000_0000_0000_0000_0000_0000_0000_0001; // 1
        #10;
        $display("i_opp: %b, o_is_nop: %b", i_opp, o_is_nop);
        if (o_is_nop === 0)
            $display("TEST 2 OK");
        else
            $display("TEST 2 FAILED");

        // Test case 3: i_opp is a larger non-zero value
        i_opp = 32'b1111_1111_1111_1111_1111_1111_1111_1111; // 0xFFFFFFFF
        #10;
        $display("i_opp: %b, o_is_nop: %b", i_opp, o_is_nop);
        if (o_is_nop === 0)
            $display("TEST 3 OK");
        else
            $display("TEST 3 FAILED");

        // Test case 4: i_opp is a random non-zero value
        i_opp = 32'b0101_0101_0101_0101_0101_0101_0101_0101; // intercalado
        #10;
        $display("i_opp: %b, o_is_nop: %b", i_opp, o_is_nop);
        if (o_is_nop === 0)
            $display("TEST 4 OK");
        else
            $display("TEST 4 FAILED");

        $stop;
    end
endmodule

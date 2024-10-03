`timescale 1ns / 1ps

module tb_alu_ctrl;

    parameter ALU_CTRL_BUS_WIDTH = 6;
    parameter ALU_OP_BUS_WIDTH = 3;
    parameter ALU_FUNCT_BUS_WIDTH = 6;

    // test signals
    reg [ALU_FUNCT_BUS_WIDTH - 1 : 0] i_funct;
    reg [ALU_OP_BUS_WIDTH - 1 : 0] i_alu_opp;
    wire [ALU_CTRL_BUS_WIDTH - 1 : 0] o_alu_ctrl;

    // expected output
    reg [ALU_CTRL_BUS_WIDTH - 1 : 0] expected_alu_ctrl;

    // alu_ctrl module
    alu_ctrl #(
        .ALU_CTRL_BUS_WIDTH(ALU_CTRL_BUS_WIDTH),
        .ALU_OP_BUS_WIDTH(ALU_OP_BUS_WIDTH),
        .ALU_FUNCT_BUS_WIDTH(ALU_FUNCT_BUS_WIDTH)
    ) uut (
        .i_funct(i_funct),
        .i_alu_opp(i_alu_opp),
        .o_alu_ctrl(o_alu_ctrl)
    );

    initial begin
        // Test case 1: R-Type AND operation
        i_funct = 6'b100100; // AND function
        i_alu_opp = 3'b110; // R-Type
        expected_alu_ctrl = 6'b100100; // Expected AND control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: R-Type AND");
        else $display("FAILED: R-Type AND");

        // Test case 2: Load instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b000; // Load type
        expected_alu_ctrl = 6'b100000; // Expected ADD control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: Load instruction");
        else $display("FAILED: Load instruction");

        // Test case 3: Store instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b000; // Store type
        expected_alu_ctrl = 6'b100000; // Expected ADD control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: Store instruction");
        else $display("FAILED: Store instruction");

        // Test case 4: ADDI instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b000; // ADDI type
        expected_alu_ctrl = 6'b100000; // Expected ADD control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: ADDI instruction");
        else $display("FAILED: ADDI instruction");

        // Test case 5: ANDI instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b010; // ANDI type
        expected_alu_ctrl = 6'b100100; // Expected AND control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: ANDI instruction");
        else $display("FAILED: ANDI instruction");

        // Test case 6: ORI instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b011; // ORI type
        expected_alu_ctrl = 6'b100101; // Expected OR control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: ORI instruction");
        else $display("FAILED: ORI instruction");

        // Test case 7: XORI instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b100; // XORI type
        expected_alu_ctrl = 6'b100110; // Expected XOR control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: XORI instruction");
        else $display("FAILED: XORI instruction");

        // Test case 8: SLTI instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b101; // SLTI type
        expected_alu_ctrl = 6'b101010; // Expected SLT control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: SLTI instruction");
        else $display("FAILED: SLTI instruction");

        // Test case 9: Jump instruction
        i_funct = 6'bxxxxxx; // Don't care
        i_alu_opp = 3'b111; // Jump type
        expected_alu_ctrl = 6'b001001; // Expected SC_B control
        #10;
        if (o_alu_ctrl == expected_alu_ctrl) $display("TEST OK: Jump instruction");
        else $display("FAILED: Jump instruction");

        $stop;
    end
endmodule

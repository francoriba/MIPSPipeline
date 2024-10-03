`timescale 1ns / 1ps

module tb_ctrl_register;


    reg i_are_equal;
    reg i_instr_nop;
    reg [5:0] i_opp;
    reg [5:0] i_funct;


    wire [19:0] o_ctrl_register;

    // ctrl_register module
    ctrl_register uut (
        .i_are_equal(i_are_equal), 
        .i_instr_nop(i_instr_nop), 
        .i_opp(i_opp), 
        .i_funct(i_funct), 
        .o_ctrl_register(o_ctrl_register)
    );

    initial begin
        // Initialize Inputs
        i_are_equal = 0;
        i_instr_nop = 0;
        i_opp = 6'b000000;
        i_funct = 6'b000000;
        #100;
        
        // Test case 1: ADDI instruction
        i_opp = 6'b001000;
        #10;
        $display("Test ADDI: o_ctrl_register = %b", o_ctrl_register);

        // Test case 2: LW instruction
        i_opp = 6'b100011;
        #10;
        $display("Test LW: o_ctrl_register = %b", o_ctrl_register);

        // Test case 3: SW instruction
        i_opp = 6'b101011;
        #10;
        $display("Test SW: o_ctrl_register = %b", o_ctrl_register);

        // Test case 4: BEQ instruction, are_equal = 1
        i_opp = 6'b000100;
        i_are_equal = 1;
        #10;
        $display("Test BEQ (equal): o_ctrl_register = %b", o_ctrl_register);

        // Test case 5: BEQ instruction, are_equal = 0
        i_are_equal = 0;
        #10;
        $display("Test BEQ (not equal): o_ctrl_register = %b", o_ctrl_register);

        // Test case 6: J instruction
        i_opp = 6'b000010;
        #10;
        $display("Test J: o_ctrl_register = %b", o_ctrl_register);

        // Test case 7: NOP instruction
        i_instr_nop = 1;
        #10;
        $display("Test NOP: o_ctrl_register = %b", o_ctrl_register);

        // Finish simulation
        $finish;
    end
      
endmodule

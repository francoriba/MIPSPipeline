`timescale 1ns / 1ps

module alu
    #(
        parameter IO_BUS_WIDTH  = 8,
        parameter CTRL_BUS_WIDTH = 6
    )
    (
        input  [CTRL_BUS_WIDTH - 1 : 0] i_ctrl, 
        input  [IO_BUS_WIDTH - 1 : 0] i_data_A,
        input  [IO_BUS_WIDTH - 1 : 0] i_data_B,
        output [IO_BUS_WIDTH - 1 : 0] o_result
    );

    localparam SLL = 6'b000000; // Shift left logical
    localparam SRL = 6'b000010; // Shift right logical
    localparam SRA = 6'b000011; // Shift right arithmetic
    localparam ADD = 6'b100000; // Sum
    localparam ADDU = 6'b100001; // Sum unsigned
    localparam SUB = 6'b100010; // Substract 
    localparam SUBU = 6'b100011; // Substract unsigned
    localparam AND = 6'b100100; // Logical and
    localparam OR = 6'b100101; // Logical or
    localparam XOR = 6'b100110; // Logical xor
    localparam NOR = 6'b100111; // Logical nor
    localparam SLT = 6'b101010; // Set if less than
    localparam SLLV = 6'b000100; // Shift left logical
    localparam SRLV = 6'b000110; // Shift right logical
    localparam SRAV = 6'b000111; // Shift right arithmetic
    localparam SC_B = 6'b001001; // Short circuit B
    localparam NOP = 6'bxxxxxx; // No operation
    
    reg[IO_BUS_WIDTH - 1 : 0] result;

    always@(*)
    begin
        case(i_ctrl)
            SLL   : result = i_data_B << i_data_A;
            SRL   : result = i_data_B >> i_data_A;
            SRA   : result = $signed(i_data_B) >>> i_data_A;
            ADD   : result = $signed(i_data_A) + $signed(i_data_B);
            ADDU  : result = i_data_A + i_data_B;
            SUB   : result = $signed(i_data_A) - $signed(i_data_B);
            SUBU  : result = i_data_A - i_data_B;
            AND   : result = i_data_A & i_data_B;
            OR    : result = i_data_A | i_data_B;
            XOR   : result = i_data_A ^ i_data_B;
            NOR   : result = ~(i_data_A | i_data_B);
            SLT   : result = $signed(i_data_A) < $signed(i_data_B);
            SLLV  : result = i_data_A << i_data_B;
            SRLV  : result = i_data_A >> i_data_B;
            SRAV  : result = $signed(i_data_A) >>> i_data_B;
            SC_B  : result = i_data_B;
            default            : result = {IO_BUS_WIDTH {1'bz}};
        endcase
    end
    
    assign o_result = result; 
    
endmodule
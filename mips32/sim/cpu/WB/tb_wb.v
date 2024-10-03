`timescale 1ns / 1ps

module tb_wb;
    // Parameters
    parameter BUS_WIDTH = 32;

    // Test signals
    reg i_mem_to_reg;
    reg [BUS_WIDTH - 1 : 0] i_alu_result;
    reg [BUS_WIDTH - 1 : 0] i_mem_result;
    wire [BUS_WIDTH - 1 : 0] o_wb_data;

    // Instantiate the wb module
    wb #(
        .BUS_WIDTH(BUS_WIDTH)
    ) uut (
        .i_mem_to_reg(i_mem_to_reg),
        .i_alu_result(i_alu_result),
        .i_mem_result(i_mem_result),
        .o_wb_data(o_wb_data)
    );

    initial begin
        // Test case 1: Different ALU result, select ALU result
        i_mem_to_reg = 1;
        i_alu_result = 32'h12345678;
        i_mem_result = 32'h87654321;
        #10;
        if (o_wb_data === 32'h12345678)
            $display("TEST 1 OK: i_mem_to_reg: %b, i_alu_result: %h, i_mem_result: %h, o_wb_data: %h", i_mem_to_reg, i_alu_result, i_mem_result, o_wb_data);
        else
            $display("TEST 1 FAILED: i_mem_to_reg: %b, i_alu_result: %h, i_mem_result: %h, o_wb_data: %h", i_mem_to_reg, i_alu_result, i_mem_result, o_wb_data);

        // Test case 2: Different memory result, select memory result
        i_mem_to_reg = 0;
        i_alu_result = 32'h12345678;
        i_mem_result = 32'h87654321;
        #10;
        if (o_wb_data === 32'h87654321)
            $display("TEST 2 OK: i_mem_to_reg: %b, i_alu_result: %h, i_mem_result: %h, o_wb_data: %h", i_mem_to_reg, i_alu_result, i_mem_result, o_wb_data);
        else
            $display("TEST 2 FAILED: i_mem_to_reg: %b, i_alu_result: %h, i_mem_result: %h, o_wb_data: %h", i_mem_to_reg, i_alu_result, i_mem_result, o_wb_data);

        // Test case 3: Select ALU result
        i_mem_to_reg = 1;
        i_alu_result = 32'h00000000;
        i_mem_result = 32'hFFFFFFFF;
        #10;
        if (o_wb_data === 32'h00000000)
            $display("TEST 3 OK: i_mem_to_reg: %b, i_alu_result: %h, i_mem_result: %h, o_wb_data: %h", i_mem_to_reg, i_alu_result, i_mem_result, o_wb_data);
        else
            $display("TEST 3 FAILED: i_mem_to_reg: %b, i_alu_result: %h, i_mem_result: %h, o_wb_data: %h", i_mem_to_reg, i_alu_result, i_mem_result, o_wb_data);

        $stop;
    end
endmodule

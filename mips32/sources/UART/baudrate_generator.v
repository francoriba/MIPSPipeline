`timescale 1ns / 1ps

module baudrate_generator
    #(
        parameter COUNTER_BITS = 8,
        parameter LIMITE = 163
    )
    (
        input wire i_clk,
        input wire i_reset,
        output wire o_ticks,
        output wire [COUNTER_BITS - 1 : 0] baud_rate
    );
    
    reg [COUNTER_BITS - 1 : 0] counter_reg;
    wire [COUNTER_BITS - 1 : 0] counter_next;
    
    always @ (posedge i_clk) 
    begin
        if (i_reset)
            counter_reg <= 0;
        else
            counter_reg <= counter_next;
    end

    assign counter_next = (counter_reg == (LIMITE - 1)) ? 'b0 : counter_reg + 1;
    
    assign baud_rate = counter_reg;
    assign o_ticks = (counter_reg == (LIMITE - 1)) ? 1'b1 : 1'b0;
endmodule

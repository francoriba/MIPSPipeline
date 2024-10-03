`timescale 1ns / 1ps

/* PC module: Maintains and updates the Program Counter (PC) */

module pc
    #(
        parameter PC_WIDTH = 32,              // Width of the PC
        parameter PC_STATES_NUM = 3,          // Number of PC states
        parameter STATES_WIDTH = $clog2(PC_STATES_NUM), // Width of the state
       
        // PC states
        parameter PC_IDLE = 2'b00,            // Idle state
        parameter PC_NEXT = 2'b01,            // Next PC state
        parameter PC_END = 2'b10              // End of execution state
    )
    (
        input wire i_clk,                     // Clock input
        input wire i_reset,                   // Reset input
        input wire i_halt,                    // Halt signal
        input wire i_not_load,                // Signal indicating not to load new PC
        input wire i_enable,                  // Enable signal
        input wire i_flush,                  // Flush signal
        input wire i_clear,                   // Clear signal
        input wire [PC_WIDTH - 1 : 0] i_next_pc, // Input for next PC value
        output wire [PC_WIDTH - 1 : 0] o_pc    // Output for current PC value
    );

    reg [STATES_WIDTH - 1 : 0] state, state_next; // Current and next state
    reg [PC_WIDTH - 1 : 0] pc, pc_next;           // Current and next PC value

    // Update state and PC on the negative edge of the clock
    always @ (negedge i_clk) 
    begin
        if (i_reset || i_flush || i_clear) 
        begin
            // If reset, flush, or clear signal is active, set PC to zero and go to idle state
            state <= PC_IDLE;
            pc <= 32'b0;
        end
        else 
        begin
            // Otherwise, update state and PC with next values
            state <= state_next;
            pc <= pc_next;
        end
    end

    // Determine the next state and PC value based on current state and inputs
    always @ (*) 
    begin
        state_next = state;
        pc_next = pc;

        case (state)
            PC_IDLE: 
            begin
                // Idle state: Set PC to zero and move to the next state
                pc_next = 32'b0;
                state_next = PC_NEXT;
            end

            PC_NEXT: 
            begin
                if (i_enable) 
                begin
                    if (i_halt) 
                    begin
                        // If halt signal is active, move to end state
                        state_next = PC_END;
                    end
                    else 
                    begin
                        if (~i_not_load)
                        begin
                            // If not loading new PC, update PC with the next value
                            pc_next = i_next_pc;
                            state_next = PC_NEXT;
                        end
                    end
                end
            end

            PC_END: 
            begin
                if (~i_halt) 
                begin
                    // If halt signal is inactive, return to idle state
                    state_next = PC_IDLE;
                end
            end

        endcase
    end

    // Assign the current PC value to output
    assign o_pc = pc;

endmodule

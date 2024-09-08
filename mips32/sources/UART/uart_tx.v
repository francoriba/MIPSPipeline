`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module uart_tx#
(
    parameter BITS_DATA = 8, // data bits
    parameter SB_TICK = 16 // ticks for stop bits
)
(
    input wire i_clk,
    input wire i_reset,
    input wire i_tx_start,
    input wire i_tick,
    input wire [BITS_DATA-1 : 0] i_data_in,
    output reg o_tx_done,
    output wire o_tx
);

// States for state machine
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

//signal declaration
reg [1:0] state, next_state;
reg [3:0] ticks, next_ticks;
reg [2:0] bits_tx, bits_tx_next;
reg [BITS_DATA-1:0] byte_tx, byte_tx_next;

reg tx_reg; // output data o_tx
reg tx_next;

//STATE MACHINE
// FSMD state & data registers 
always @(posedge i_clk) begin
    if(i_reset) begin
        state <= IDLE;
        ticks <= 0;
        bits_tx <= 0;
        byte_tx <= 0;
        tx_reg <= 1'b1;
    end
    else begin
        state <= next_state;
        ticks <= next_ticks;
        bits_tx <= bits_tx_next;
        byte_tx <= byte_tx_next;
        tx_reg <= tx_next;
    end
end

// next state logic
always @(*) begin
    next_state = state;
    o_tx_done = 1'b0;
    next_ticks = ticks;
    bits_tx_next = bits_tx;
    byte_tx_next = byte_tx;
    tx_next = tx_reg;

    case (state)
        IDLE: begin // not transmitting
            tx_next = 1'b1;
            if(i_tx_start) begin
                next_state = START;
                next_ticks = 0;
                byte_tx_next = i_data_in;
            end
        end
        
        START: begin
            tx_next = 1'b0; // send start bit 0
            if (i_tick) begin
                if (ticks == SB_TICK-1) begin
                    next_state = DATA;
                    next_ticks = 0;
                    bits_tx_next = 0;
                end
                else begin
                    next_ticks = ticks + 1;
                end
            end
        end

        DATA: begin
            tx_next = byte_tx[0]; // current bit to be transmitted LSB
            if (i_tick) begin
                if(ticks==SB_TICK-1) begin
                    next_ticks = 0;
                    byte_tx_next = byte_tx >> 1; // shifting the tx_next bit out
                    if (bits_tx==(BITS_DATA-1)) begin // check if i transmitted all bits
                        next_state = STOP;
                    end
                    else begin
                        bits_tx_next = bits_tx + 1;
                    end
                end
                else begin // more data bits to transmit in this frame
                    next_ticks = ticks + 1;
                end
            end
        end

        STOP: begin
            tx_next = 1'b1; // transmitting the stop bit 1
            if (i_tick) begin
                if (ticks==(SB_TICK-1)) begin
                    next_state = IDLE;
                    o_tx_done = 1'b1;
                end
                else begin
                    next_ticks = ticks + 1;
                end
            end
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end

assign o_tx = tx_reg;

endmodule

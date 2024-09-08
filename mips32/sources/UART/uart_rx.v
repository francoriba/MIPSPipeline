`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module uart_rx #(
    parameter BITS_DATA = 8, // data bits
    parameter SB_TICK = 16 // ticks for stop bits
)(
    input wire i_clk,
    input wire i_reset,
    input wire i_rx,
    input wire i_tick,
    output reg o_rx_done,
    output wire [BITS_DATA-1:0] o_data_out 
);

// States for state machine
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

//Signal declaration
reg [1:0] state, next_state;
reg [3:0] ticks, next_ticks;      //Register to count the number of ticks
reg [2:0] bits_rx, bits_rx_next;     //Register to count the number of received bits
reg [BITS_DATA-1:0] byte_rx, byte_rx_next;    //Register to save te received frame

//STATE MACHINE
//state & data registers 
always @(posedge i_clk) begin
    if (i_reset) begin
        state <= IDLE;
        ticks <= 0;
        bits_rx <= 0;
        byte_rx <= 0;
    end
    else begin
        state <= next_state;
        ticks <= next_ticks;
        bits_rx <= bits_rx_next;
        byte_rx <= byte_rx_next;
    end
end

// next state logic
always @(*) begin
    next_state = state;
    o_rx_done = 1'b0;
    next_ticks = ticks;
    bits_rx_next = bits_rx;
    byte_rx_next = byte_rx;

    case (state)
        IDLE:
            if (~i_rx) begin // check for start bit 0
               next_state = START;
               next_ticks = 0; 
            end
        
        START:
            if (i_tick) begin
                if (ticks == 7) begin
                    next_state = DATA;
                    next_ticks = 0;
                    bits_rx_next = 0;
                end
                else begin
                    next_ticks = ticks + 1;
                end
            end

        DATA:
            if (i_tick) begin
                if (ticks == SB_TICK-1) begin
                    next_ticks = 0;
                    byte_rx_next = {i_rx, byte_rx[BITS_DATA-1:1]}; // assemble received data bits into a byte
                    if (bits_rx == (BITS_DATA-1)) begin // check if i received all bits
                        next_state = STOP;
                    end
                    else begin
                        bits_rx_next = bits_rx + 1;
                    end
                end
                else begin // more data bits are expected
                    next_ticks = ticks + 1;
                end
            end
        
        STOP:
            if (i_tick) begin
                if (ticks == (SB_TICK-1)) begin
                    next_state = IDLE;
                    if(i_rx) begin
                        o_rx_done = 1'b1;
                    end
                end 
                else begin
                    next_ticks = ticks + 1;
                end
            end

        default: 
            next_state = IDLE;   
    endcase
end

assign o_data_out = byte_rx;

endmodule
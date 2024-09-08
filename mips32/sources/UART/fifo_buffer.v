`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////

module fifo_buffer #(
    parameter BITS_DATA = 64,
    parameter BITS_PTR = 8
)(
    input wire i_clk,     
    input wire i_reset,
    input wire i_read,            
    input wire i_write,
    input wire [BITS_DATA-1 : 0] i_write_data, // Input data to be written into the FIFO
    output wire o_is_empty,
    output wire o_is_full,
    output wire [BITS_DATA-1 : 0] o_read_data // output read data
);

//Signal declaration
reg [BITS_DATA-1 : 0] buffer [(2**BITS_PTR)-1 : 0]; // register array
reg [BITS_PTR-1 : 0] write_ptr, write_ptr_next, write_ptr_succ;
reg [BITS_PTR-1 : 0] read_ptr, read_ptr_next, read_ptr_succ;

reg is_full, is_full_next;
reg is_empty, is_empty_next;

wire write_enable;

// register file write operation
always @(posedge i_clk) begin
    if(write_enable) begin
        buffer[write_ptr] <= i_write_data;
    end
end
// register file read operation
assign o_read_data = buffer[read_ptr];
// write enable only when fifo is not full
assign write_enable = i_write & ~is_full;

// Control
// check for reset or next
always @(posedge i_clk) begin
    if(i_reset) begin
        write_ptr <= 1'b0;
        read_ptr <= 1'b0;
        is_full <= 1'b0;
        is_empty <= 1'b1;
    end
    else begin
        write_ptr <= write_ptr_next;
        read_ptr <= read_ptr_next;
        is_full <= is_full_next;
        is_empty <= is_empty_next;
    end
end

// next-state logic for read and write pointers 
always @(*) begin
    //Successive pointer values
    write_ptr_succ = write_ptr + 1;
    read_ptr_succ = read_ptr + 1; 
    //Default: keep old values
    write_ptr_next = write_ptr;
    read_ptr_next = read_ptr;
    is_full_next = is_full;
    is_empty_next = is_empty;

    case ({i_write, i_read})
        2'b01: // read
            if (~is_empty) begin // not empty
                read_ptr_next = read_ptr_succ;
                is_full_next = 1'b0;
                if (read_ptr_succ==write_ptr) begin // read ptr reaches write ptr, fifo will empty
                    is_empty_next = 1'b1;
                end
            end
        2'b10: // write
            if (~is_full) begin // not full
                write_ptr_next = write_ptr_succ;
                is_empty_next = 1'b0;
                if (write_ptr_succ==read_ptr) begin
                    is_full_next = 1'b1;
                end
            end
        2'b11: // write and read
            begin
                write_ptr_next = write_ptr_succ;
                read_ptr_next = read_ptr_succ; 
            end 
        default: // 2'00 no op
            begin
                write_ptr_next = write_ptr_next;
                read_ptr_next = read_ptr_next;
            end

    endcase
end

// output
assign o_is_full = is_full;
assign o_is_empty = is_empty;

endmodule

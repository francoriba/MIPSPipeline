`timescale 1ns / 1ps

module buffer_writer
    #(
        parameter DATA_LEN = 8, // porque es uart
        parameter DATA_IN_LEN = 32
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_is_uart_full, // flag si tx uart está lleno y no puede aceptar más datos
        input wire i_wr, // inicia proceso de escritura
        input wire [DATA_IN_LEN - 1 : 0] i_wr_data, // datos a escribir por uart
        output wire o_uart_wr, // activa escritura uart
        output wire o_wr_finished, // indica fin de escritura
        output wire [DATA_LEN - 1 : 0] o_wr_buffer // buffer a enviar
    );

    localparam BUFFER_IDLE = 2'b00;
    localparam BUFFER_WR_IDLE = 2'b01;
    localparam BUFFER_WR = 2'b10;
    localparam BUFFER_POINTER_SIZE = $clog2(DATA_IN_LEN / DATA_LEN);

    reg [1 : 0] state, state_next;
    reg uart_wr, uart_wr_next, wr_finished, wr_finished_next;
    reg [DATA_LEN - 1 : 0] wr_buffer, wr_buffer_next;
    reg [BUFFER_POINTER_SIZE : 0] buffer_pointer, buffer_pointer_next;                          
    
    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state <= BUFFER_IDLE;
                buffer_pointer <= 'b0;
                wr_buffer <= 'b0;
                uart_wr <= 1'b0; 
                wr_finished <= 1'b0;
            end
        else
            begin
                state <= state_next;
                buffer_pointer <= buffer_pointer_next;
                wr_buffer <= wr_buffer_next;
                uart_wr <= uart_wr_next;
                wr_finished <= wr_finished_next;
            end
    end
    
    always @(*)
    begin
        state_next = state;
        buffer_pointer_next = buffer_pointer;
        wr_buffer_next = wr_buffer;
        uart_wr_next = uart_wr;
        wr_finished_next = wr_finished;
    
        case (state)
            // espera que se active la lectura de datos
            BUFFER_IDLE:
            begin
                if (i_wr)
                    begin
                        wr_finished_next = 1'b0;
                        state_next = BUFFER_WR_IDLE;
                    end
            end

            // verifico si hay espacio en uart
            BUFFER_WR_IDLE:
            begin     
                if (buffer_pointer < DATA_IN_LEN / DATA_LEN) // no llego a tamaño max
                    begin
                        if (!i_is_uart_full) // uart no está lleno
                            begin
                                wr_buffer_next = i_wr_data[buffer_pointer * DATA_LEN +: DATA_LEN]; // cargo datos
                                uart_wr_next = 1'b1;
                                state_next = BUFFER_WR;
                            end
                    end
                else // fin de escritura
                    begin
                        wr_finished_next = 1'b1; // flag escritura completa
                        buffer_pointer_next = 'b0;
                        state_next = BUFFER_IDLE; // vuelvo a esperar escritura
                    end
            end

            BUFFER_WR:
            begin
                state_next = BUFFER_WR_IDLE; // vuelvo a ver si hay mas datos
                uart_wr_next = 1'b0;
                buffer_pointer_next = buffer_pointer + 1; // se incrementa para prepararse para el siguiente dato
            end

        endcase
    end
    
    assign o_uart_wr = uart_wr;
    assign o_wr_buffer = wr_buffer;
    assign o_wr_finished = wr_finished;

endmodule
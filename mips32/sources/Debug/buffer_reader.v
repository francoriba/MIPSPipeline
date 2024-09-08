`timescale 1ns / 1ps

module buffer_reader
    #(
        parameter DATA_LEN = 8,
        parameter DATA_OUT_LEN = 32
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_is_uart_empty, // flag que indica si hay para leer de la uart
        input wire i_rd, // inicia proceso de lectura
        input wire [DATA_LEN - 1 : 0] i_uart_data, // datps que vienen de la uart
        output wire o_uart_rd, // activa lectura por uart
        output wire o_rd_finished, // indica fin lectura
        output wire [DATA_OUT_LEN - 1 : 0] o_rd_buffer // buffer
    );

    localparam BUFFER_IDLE = 2'b00;
    localparam BUFFER_RD_IDLE = 2'b01;
    localparam BUFFER_RD = 2'b10;
    localparam BUFFER_POINTER_SIZE = $clog2(DATA_OUT_LEN / DATA_LEN);

    reg [1 : 0] state, state_next;
    reg uart_rd, uart_rd_next, rd_finished, rd_finished_next;
    reg [DATA_OUT_LEN - 1 : 0] rd_buffer, rd_buffer_next;
    reg [BUFFER_POINTER_SIZE : 0] buffer_pointer, buffer_pointer_next;

    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state <= BUFFER_IDLE;
                rd_buffer <= 'b0;
                buffer_pointer <= 'b0;
                uart_rd <= 1'b0;
                rd_finished <= 1'b0;
            end
        else
            begin
                state <= state_next;
                rd_buffer <= rd_buffer_next;
                buffer_pointer <= buffer_pointer_next;
                uart_rd <= uart_rd_next;
                rd_finished <= rd_finished_next;
            end
    end
    
    always @(*)
    begin
        state_next = state;
        rd_buffer_next = rd_buffer;
        buffer_pointer_next = buffer_pointer;
        uart_rd_next = uart_rd;
        rd_finished_next = rd_finished;

        case (state)
            // espera que se active la lectura de datos
            BUFFER_IDLE:
            begin
                if (i_rd)
                    begin
                        state_next = BUFFER_RD_IDLE;
                        rd_finished_next = 1'b0;
                    end
            end

            // comprueba si hay datos para leidos para guardar en el buffer
            BUFFER_RD_IDLE:
            begin
                if (buffer_pointer < DATA_OUT_LEN / DATA_LEN) // no alcanza el tamaño maximo
                    begin
                        if (!i_is_uart_empty)
                            begin
                                rd_buffer_next[buffer_pointer * DATA_LEN +: DATA_LEN] = i_uart_data; // almaceno datos
                                uart_rd_next = 1'b1;
                                state_next = BUFFER_RD;
                            end
                    end
                else // fin de lectura
                    begin
                        rd_finished_next = 1'b1; // flag lectura completa
                        buffer_pointer_next = 'b0;
                        state_next = BUFFER_IDLE; // vuelvo a esperar que se active
                    end
            end

            BUFFER_RD:
            begin
                state_next = BUFFER_RD_IDLE; // vuelvo a ver si hay datos para guardar
                uart_rd_next = 1'b0;
                buffer_pointer_next = buffer_pointer + 1; // se incrementa para prepararse para el siguiente dato
            end

        endcase
    end

    assign o_uart_rd = uart_rd;
    assign o_rd_finished = rd_finished;
    assign o_rd_buffer = rd_buffer;

endmodule
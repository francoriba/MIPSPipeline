`timescale 1ns / 1ps

module reg_printer
    #(
        parameter UART_BUS_SIZE = 8,
        parameter DATA_OUT_BUS_SIZE = UART_BUS_SIZE * 7 ,
        parameter REGISTER_SIZE = 32,
        parameter REGISTER_BANK_BUS_SIZE = REGISTER_SIZE * 32
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_write_finish, // final de una operación de escritura
        input wire i_is_mem, // 1 si es memoria, 0 si es registro
        input wire i_start, 
        input wire [REGISTER_BANK_BUS_SIZE - 1 : 0] i_reg_bank, // contenido del register bank
        input wire [UART_BUS_SIZE - 1 : 0] i_clk_cicle,
        input wire [REGISTER_SIZE - 1 : 0] i_current_pc,
        output wire o_write, // indica si se debe escribir en la UART
        output wire o_finish, // indica si se ha terminado de escribir
        output wire [DATA_OUT_BUS_SIZE - 1 : 0] o_data_write // datos a escribir en la UART
    );

    // Estados de la máquina de estados
    localparam STATE_IDLE = 2'b00;
    localparam STATE_PRINT = 2'b01;
    localparam STATE_WAIT_WR_TRANSITION = 2'b10;
    localparam STATE_WAIT_WR = 2'b11;

    localparam REG_POINTER_SIZE = $clog2(REGISTER_BANK_BUS_SIZE / REGISTER_SIZE);

    reg [1 : 0] state, state_next;
    reg write, write_next;
    reg [DATA_OUT_BUS_SIZE - 1 : 0] data_write, data_write_next;
    reg [REG_POINTER_SIZE : 0] reg_pointer, reg_pointer_next;
    reg finish, finish_next;

    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state <= STATE_IDLE;
                reg_pointer <= 'b0;
                data_write <= 'b0;
                write <= 1'b0;
                finish <= 1'b0;
            end
        else
            begin
                state <= state_next;
                reg_pointer <= reg_pointer_next;
                data_write <= data_write_next;
                write <= write_next;
                finish <= finish_next;
            end
    end
    
    always @(*)
    begin
        state_next = state;
        reg_pointer_next = reg_pointer;
        data_write_next = data_write;
        write_next = write;
        finish_next = finish;

        case (state)
    
            // IDLE: espera inicio
            STATE_IDLE:
            begin          
                if (i_start)
                    begin
                        finish_next = 1'b0;
                        state_next = STATE_PRINT;
                    end
            end

            // PRINT: prepara dato para mandar
            STATE_PRINT:
            begin
                if (reg_pointer < REGISTER_BANK_BUS_SIZE / REGISTER_SIZE) // leer de a un registro
                    begin // 1 PARA REG Y 01 PARA MEM
                        data_write_next = {i_is_mem ? 8'b00000010 : 8'b00000001, i_clk_cicle, { { (UART_BUS_SIZE - REG_POINTER_SIZE - 1) { 1'b0 } }, reg_pointer } , i_reg_bank[reg_pointer * REGISTER_SIZE +: REGISTER_SIZE] };
                        reg_pointer_next = reg_pointer + 1;
                        write_next = 1'b1;
                        state_next = STATE_WAIT_WR_TRANSITION;
                    end
                else if (reg_pointer == REGISTER_BANK_BUS_SIZE / REGISTER_SIZE) // PC 
                    begin
                        data_write_next = {8'b00000011, i_clk_cicle, 8'b00000000, i_current_pc };
                        reg_pointer_next = reg_pointer + 1;
                        write_next = 1'b1;
                        state_next = STATE_WAIT_WR_TRANSITION;
                    end
                else
                    begin
                        finish_next = 1'b1;
                        reg_pointer_next = 'b0;
                        state_next = STATE_IDLE;
                    end
            end

            STATE_WAIT_WR_TRANSITION:
            begin
                state_next = STATE_WAIT_WR;
            end

            // WAIT_WR: espera a que se termine de escribir
            STATE_WAIT_WR:
            begin
                write_next = 1'b0;
                if (i_write_finish)
                    state_next = STATE_PRINT;
            end

        endcase
    end

    assign o_write = write;
    assign o_data_write = data_write;
    assign o_finish = finish;

endmodule
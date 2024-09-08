`timescale 1ns / 1ps

module interface
    #(
        parameter UART_DATA_LEN = 8,
        parameter DATA_IN_LEN = UART_DATA_LEN * 4,
        parameter DATA_OUT_LEN = UART_DATA_LEN * 7,
        parameter REG_LEN = 32
    )
    (
        input wire i_clk,
        input wire i_reset,
        input wire i_instr_mem_empty,
        input wire i_instr_mem_full,
        input wire i_finish_program,
        input wire i_uart_read_finish,
        input wire i_uart_write_finish,
        input wire i_print_regs_finish,
        input wire i_print_mem_finish,
        input wire [DATA_IN_LEN - 1 : 0] i_data_uart_read,
        output wire [UART_DATA_LEN - 1 : 0] o_clk_cicle,
        output wire o_uart_write,
        output wire o_uart_read,
        output wire o_print_regs,
        output wire o_print_mem,
        output wire o_new_instruction,
        output wire o_flush,
        output wire o_clear_program,
        output wire o_mips_enabled,
        output wire [DATA_OUT_LEN - 1 : 0] o_ctrl_info,
        output wire [REG_LEN - 1 : 0] o_mips_instruction,
        output wire [4 : 0] o_state
    );

    localparam CODE_NO_CICLE_MASK = 8'b00000000;
    localparam CODE_NO_ADDRESS_MASK = 8'b00000000;
    localparam CODE_ERROR_PREFIX = 8'b11111111;
    localparam CODE_INFO_PREFIX = 8'b00000000;
    localparam CODE_INFO_END_PROGRAM = 32'b00000000000000000000000000000001;
    localparam CODE_INFO_LOAD_PROGRAM = 32'b00000000000000000000000000000010;
    localparam CODE_INFO_END_STEP = 32'b00000000000000000000000000000011;
    localparam CODE_ERROR_INSTRUCTION_MEMORY_FULL = 32'b00000000000000000000000000000001;
    localparam CODE_ERROR_NO_PROGRAM_LOAD = 32'b00000000000000000000000000000010;
    localparam INSTRUCTION_HALT = 32'b11111111111111111111111111111111;
    
    // Estados de la máquina de estados
    localparam STATE_READ = 5'b00000;
    localparam STATE_ACTIVATE_READER_BUFFER = 5'b00001;
    localparam STATE_WRITE = 5'b00010;
    localparam STATE_ACTIVATE_WRITER_BUFFER = 5'b00011 ;
    localparam STATE_EMPTY_PROGRAM = 5'b00110;
    localparam STATE_CMD_INSTRUCTION = 5'b01000;
    localparam STATE_IDLE = 5'b01001;
    localparam STATE_FLUSH = 5'b01010;
    localparam STATE_LOAD_INSTRUCTION = 5'b01100;
    localparam STATE_CONTINUE_LOADING = 5'b01101;
    localparam STATE_RUN_STEP_INSTRUCTION = 5'b01110;
    localparam STATE_WAIT_NEXT_STEP = 5'b01111;
    localparam STATE_FINISH_RUN = 5'b10000;
    localparam STATE_RUN_CONTINUOUS = 5'b10010;
    localparam STATE_PRINT_REGS_START = 5'b10011;
    localparam STATE_PRINT_REGS = 5'b10100;
    localparam STATE_PRINT_MEM_START = 5'b10101;
    localparam STATE_PRINT_MEM = 5'b10110;

    reg [4 : 0] state, state_next, return_state, return_state_next;
    reg flush, flush_next; // reset de etapas
    reg mips_enabled, mips_enabled_next; // habilita ejecución
    reg clear_program, clear_program_next; // borra programa cargado
    reg uart_read, uart_read_next, uart_write, uart_write_next;
    reg print_regs, print_regs_next, print_mem, print_mem_next;
    reg [DATA_OUT_LEN - 1 : 0] ctrl_info, ctrl_info_next;
    reg new_instruction, new_instruction_next; // para pasarle a IF
    reg [REG_LEN - 1 : 0] mips_instruction, mips_instruction_next; // instrucción MIPS a tratar
    reg step_mode, step_mode_next; // modo de ejecución paso a paso
    reg [UART_DATA_LEN - 1 : 0] clk_counter, clk_counter_next;

    always @(posedge i_clk) 
    begin
        if (i_reset)
            begin
                state <= STATE_IDLE;
                return_state <= STATE_IDLE;
                flush <= 1'b0;
                mips_enabled <= 1'b0;
                clear_program <= 1'b0;
                uart_read <= 1'b0;
                uart_write <= 1'b0;
                print_regs <= 1'b0;
                print_mem <= 1'b0;
                new_instruction <= 1'b0;
                step_mode <= 1'b0;
                clk_counter <= 'b0;
                mips_instruction <= 'b0;
                ctrl_info <= 'b0;
            end
        else
            begin
                state <= state_next;
                return_state <= return_state_next;
                flush <= flush_next;
                mips_enabled <= mips_enabled_next;
                clear_program <= clear_program_next;
                uart_read <= uart_read_next;
                uart_write <= uart_write_next;
                print_regs <= print_regs_next;
                print_mem <= print_mem_next;
                new_instruction <= new_instruction_next;
                step_mode <= step_mode_next;
                clk_counter <= clk_counter_next;
                mips_instruction <= mips_instruction_next;
                ctrl_info <= ctrl_info_next;
            end
    end
    
    always @(*)
    begin
        state_next = state;
        return_state_next = return_state;
        flush_next = flush;
        mips_enabled_next = mips_enabled;
        clear_program_next = clear_program;
        uart_read_next = uart_read;
        uart_write_next = uart_write;
        print_regs_next = print_regs;
        print_mem_next = print_mem;
        new_instruction_next = new_instruction;
        step_mode_next = step_mode;
        clk_counter_next = clk_counter;
        mips_instruction_next = mips_instruction;
        ctrl_info_next = ctrl_info;
    
        case (state)

            // IDLE: esperar lectura
            STATE_IDLE:
            begin
                clk_counter_next = { { (UART_DATA_LEN - 1) { 1'b0 } }, 1'b1 }; // inicializo clock counter (1)
                mips_enabled_next = 1'b0;
                new_instruction_next = 1'b0;
                flush_next = 1'b0;
                clear_program_next  = 1'b0;
                uart_read_next = 1'b1;
                return_state_next = STATE_CMD_INSTRUCTION;
                state_next = STATE_ACTIVATE_READER_BUFFER;
            end

            /*####################### Lectura y escritura con buffer #######################*/

            // ACTIVATE READER BUFFER: activo lectura de datos
            STATE_ACTIVATE_READER_BUFFER:
            begin
                uart_read_next = 1'b0;
                state_next = STATE_READ;
            end

            // READ: leo datos de la UART hasta que se complete la lectura
            STATE_READ:
            begin
                if (i_uart_read_finish)
                    state_next = return_state;
            end

            // ACTIVATE WRITER BUFFER: activo escritura de datos
            STATE_ACTIVATE_WRITER_BUFFER:
            begin
                uart_write_next = 1'b0;
                state_next = STATE_WRITE;
            end

            // WRITE: escribo datos en la UART hasta que se complete la escritura
            STATE_WRITE:
            begin
                if (i_uart_write_finish)
                    state_next = return_state;
            end

            /* ########################## Control ########################## */

            STATE_EMPTY_PROGRAM:
            begin
                ctrl_info_next = {CODE_ERROR_PREFIX, CODE_NO_CICLE_MASK, CODE_NO_ADDRESS_MASK, CODE_ERROR_NO_PROGRAM_LOAD};
                uart_write_next = 1'b1;
                return_state_next = return_state;
                state_next = STATE_ACTIVATE_WRITER_BUFFER;
            end

            /* ########################## Modos de operación ########################## */

            // CMD INSTRUCTION: comando de instrucción recibido
            STATE_CMD_INSTRUCTION:
            begin
                case (i_data_uart_read[7 : 0])
                    // LOAD: cargar nuevo .asm
                    "L": 
                    begin
                        flush_next = 1'b1;
                        clear_program_next = 1'b1;
                        return_state_next = STATE_LOAD_INSTRUCTION;
                        state_next = STATE_FLUSH;
                    end

                    // CONTINUOUS: modo continuo de ejecución
                    "C":
                    begin
                        step_mode_next = 1'b0;
                        flush_next = 1'b1;
                        return_state_next = STATE_RUN_CONTINUOUS;
                        state_next = STATE_FLUSH;
                    end

                    // STEPS: ejecución paso a paso
                    "S":
                    begin
                        flush_next = 1'b1;
                        step_mode_next = 1'b1;
                        print_regs_next = 1'b1;
                        return_state_next = STATE_PRINT_REGS_START;
                        state_next = STATE_FLUSH;
                    end

                    default:
                    begin
                        state_next = STATE_IDLE;
                    end 
                endcase
            end

            /* ########################## Flush ########################## */

            // FLUSH: reseteo etapas
            STATE_FLUSH:
            begin
                clear_program_next = 1'b0;
                flush_next = 1'b0;
                state_next = return_state;
            end

            /* ########################## Carga de programa ########################## */
            
            // LOAD INSTRUCTION: cargar instruccion
            STATE_LOAD_INSTRUCTION:
            begin
                new_instruction_next = 1'b0;

                if (mips_instruction != INSTRUCTION_HALT) // cualquier instruccion excepto HALT
                    begin
                        if (!i_instr_mem_full) // hay espacio
                            begin
                                uart_read_next = 1'b1;
                                return_state_next = STATE_CONTINUE_LOADING;
                                state_next = STATE_ACTIVATE_READER_BUFFER; // sigo leyendo
                            end
                        else // lleno
                            begin
                                ctrl_info_next = {CODE_ERROR_PREFIX, CODE_NO_CICLE_MASK, CODE_NO_ADDRESS_MASK, CODE_ERROR_INSTRUCTION_MEMORY_FULL};
                                uart_write_next = 1'b1;
                                state_next = STATE_ACTIVATE_WRITER_BUFFER;
                                return_state_next  = STATE_IDLE;
                            end
                    end
                else // para instruccion HALT (finaliza carga del programa)
                    begin
                        ctrl_info_next = {CODE_INFO_PREFIX, CODE_NO_CICLE_MASK, CODE_NO_ADDRESS_MASK, CODE_INFO_LOAD_PROGRAM};
                        uart_write_next = 1'b1;
                        state_next = STATE_ACTIVATE_WRITER_BUFFER;
                        return_state_next = STATE_IDLE;
                        mips_instruction_next = 'b0;
                    end
            end

            // CONTINUE LOADING: continuar carga de proxima instruccion
            STATE_CONTINUE_LOADING:
            begin
                mips_instruction_next = i_data_uart_read;
                new_instruction_next = 1'b1;
                state_next = STATE_LOAD_INSTRUCTION;
            end

            /* ########################## Ejecución del Programa ########################## */

            // RUN CONTINUOUS: ejecutar en modo continuo
            STATE_RUN_CONTINUOUS:
            begin
                if (!i_instr_mem_empty)
                    begin
                        if (i_finish_program) // fin programa: imprimo registros
                            begin
                                print_regs_next = 1'b1;
                                state_next = STATE_PRINT_REGS_START;
                            end
                        else // programa continua: sigo ejecutando
                            begin
                                mips_enabled_next = 1'b1;
                                clk_counter_next = clk_counter + 1;
                            end
                    end
                else
                    begin
                        return_state_next = STATE_IDLE;
                        state_next = STATE_EMPTY_PROGRAM;
                    end
            end

            // RUN STEP: ejecutar un paso (por indicación por consola)
            STATE_RUN_STEP_INSTRUCTION:
            begin
                if (i_data_uart_read[7 : 0] == "N") // NEXT: ejecuto el siguiente paso
                    begin
                        if (!i_instr_mem_empty) // hay mas pasos
                        begin
                            mips_enabled_next = 1'b1;
                            print_regs_next = 1'b1;
                            state_next = STATE_PRINT_REGS_START; // print
                            clk_counter_next = clk_counter + 1;
                        end
                        else // lleno
                            begin
                                return_state_next = STATE_IDLE;
                                state_next = STATE_EMPTY_PROGRAM;
                            end
                    end
                else
                    begin
                        state_next = STATE_WAIT_NEXT_STEP;
                    end
            end

            // WAIT NEXT STEP: esperar siguiente paso (por indicación por UART)
            STATE_WAIT_NEXT_STEP:
            begin
                uart_read_next = 1'b1;
                return_state_next = STATE_RUN_STEP_INSTRUCTION;
                state_next = STATE_ACTIVATE_READER_BUFFER;
            end

            // FINISH RUN: finalizar ejecución o un paso
            STATE_FINISH_RUN:
            begin
                if (!i_finish_program) // no termina el programa
                    begin
                        if (step_mode) // terminar un paso
                            begin
                                ctrl_info_next = {CODE_INFO_PREFIX, CODE_NO_CICLE_MASK, CODE_NO_ADDRESS_MASK, CODE_INFO_END_STEP};
                                uart_write_next = 1'b1;
                                return_state_next = STATE_WAIT_NEXT_STEP;
                                state_next = STATE_ACTIVATE_WRITER_BUFFER;
                            end
                        else
                            mips_enabled_next = 1'b1; // NO HACE FALTA YA
                    end
                else // programa termina
                    begin
                        ctrl_info_next = {CODE_INFO_PREFIX, CODE_NO_CICLE_MASK, CODE_NO_ADDRESS_MASK, CODE_INFO_END_PROGRAM};
                        uart_write_next = 1'b1;
                        return_state_next = STATE_IDLE;
                        state_next = STATE_ACTIVATE_WRITER_BUFFER;
                    end
            end

            /* ########################## Registros y Memoria ########################## */
            
            STATE_PRINT_REGS_START:
            begin
                mips_enabled_next = 1'b0;
                print_regs_next = 1'b0;
                state_next = STATE_PRINT_REGS;
            end

            STATE_PRINT_REGS:
            begin
                if (i_print_regs_finish)
                    begin
                        print_mem_next = 1'b1;
                        state_next = STATE_PRINT_MEM_START;
                    end
            end

            STATE_PRINT_MEM_START:
            begin
                print_mem_next = 1'b0;
                state_next = STATE_PRINT_MEM;
            end

            STATE_PRINT_MEM:
            begin
                if (i_print_mem_finish)
                    state_next = STATE_FINISH_RUN;
            end
            
        endcase
    end

    assign o_mips_instruction = mips_instruction;
    assign o_new_instruction = new_instruction;
    assign o_flush = flush;
    assign o_clear_program = clear_program;
    assign o_mips_enabled = mips_enabled;
    assign o_uart_write = uart_write;
    assign o_uart_read = uart_read;
    assign o_print_regs = print_regs;
    assign o_print_mem = print_mem;
    assign o_ctrl_info = ctrl_info;
    assign o_clk_cicle = clk_counter;
    assign o_state = state;

endmodule
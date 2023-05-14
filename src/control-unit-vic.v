// Unidad de control
module control_unit (
    input wire clk,
    input wire reset,
    input wire [31:0] instruction,
    output reg [15:0] control_signals
);

reg ID_jmpl_instr;
reg ID_call_instr;
reg ID_branch_instr;
reg ID_load_instr;
reg ID_register_file_Enable;

reg ID_data_mem_SE;
reg ID_data_mem_RW;
reg ID_data_mem_Enable;
reg ID_data_mem_Size;

reg I31;
reg I30;
reg I24;
reg I13;

reg [3:0] ID_ALU_OP_instr;

reg CC_Enable;
endmodule

// Registros con rising edge-triggered y reset sincrónico
module register (
    input wire clk,
    input wire reset,
    input wire load_enable,
    input wire [31:0] data_in,
    output reg [31:0] data_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 32'b0;
        end else if (load_enable) begin
            data_out <= data_in;
        end
    end
endmodule

// Módulo top con la conexión entre la unidad de control y registros
module top (
    input wire clk,
    input wire reset,
    input wire [31:0] instruction,
    output wire [15:0] control_signals
);
    wire [31:0] nPC, PC;
    wire [15:0] ex_control_signals, mem_control_signals, wb_control_signals;

    control_unit cu (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .control_signals(control_signals)
    );

    register nPC_reg (
        .clk(clk),
        .reset(reset),
        .load_enable(/* ... */),
        .data_in(/* ... */),
        .data_out(nPC)
    );

    register PC_reg (
        .clk(clk),
        .reset(reset),
        .load_enable(/* ... */),
        .data_in(/* ... */),
        .data_out(PC)
    );

    // ... Conectar las señales de control a las etapas EX, MEM y WB ...
endmodule

// Módulo de prueba para simular el comportamiento
module testbench;
    reg clk = 0;
    reg reset = 1;
    reg [31:0] instruction;
    wire [15:0] control_signals;

    top top_inst (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .control_signals(control_signals)
    );

    // Generar la señal de reloj
    always begin
        #2 clk = ~clk;
    end

    // Procedimiento para la simulación
    initial begin
        // Inicializar las señales
        reset <= 1;
        instruction <= 32'b0;

        // Cambiar el valor de reset en tiempo 3
        #3 reset <= 0;

        // Cargar instrucciones y mostrar los valores de PC, nPC, y señales de control
        // ... Carga las instrucciones y muestra los resultados como se describe ...

        // Cambiar la señal S del multiplexor en tiempo 40
        #40 /* Cambiar la señal S del multiplexor aquí */;

        // Finalizar la simulación en tiempo 48
        #48 $finish;
    end
endmodule
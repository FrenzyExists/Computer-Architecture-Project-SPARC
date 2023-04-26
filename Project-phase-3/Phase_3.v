//   ID_shift_imm - immediate shift signal
//   ID_load_instr - load instruction
//   ID_RF_enable - enable RF
//   bit_S - allows modifications to cond flags
//   ID_Enable_instr - data memory enable
//   ID_ReadWrite_instr - read/write for instr memory
//   ID_shiftType - informs the shifter which type of instr is and what type of shifts should occur
//   ID_Size_instr - bit B from instruction (word/byte)
//   ID_ALU_op - ALU operation codes (opcodes) 
//   mux_enable - depends on the nop that comes from hazard and condition handler


//Control unit 
module control_unit(output [13:0] cu_out, output [1:0] b_bl_signals, input [31:0] instruction);

reg ID_shift_imm;
reg ID_load_instr;
reg ID_RF_enable;
reg ID_B_instr;
reg ID_BL_instr;
reg bit_S;
reg ID_Enable_instr; 
reg ID_ReadWrite_instr;
reg [1:0] ID_shiftType;
reg [1:0] ID_Size_instr;
reg [3:0] ALU_op;

assign cu_out[0] = ID_shift_imm;

assign cu_out[1] = ID_load_instr;
assign cu_out[2] = ID_RF_enable;
assign cu_out[3] = ID_Enable_instr;
assign cu_out[4] = ID_ReadWrite_instr;
assign cu_out[6:5] = ID_Size_instr;

assign cu_out[7] = bit_S;
assign cu_out[9:8] = ID_shiftType;
assign cu_out[13:10] = ALU_op;

assign b_bl_signals[0] = ID_B_instr;
assign b_bl_signals[1] = ID_BL_instr;

//SHIFTTYPE ES 3 BITS


// ShiftTypes Legend
// 00 -> Data Processing Immediate Shift 
// 01 -> Load/Store Immediate Offset
// 10 -> Data Processing Immediate [2]
// 11 -> Load/Store Register Offset 


reg [2:0] instr_ID;     //bits 27-25 to identify instruction

always @ (instruction)


begin
    if(instruction == 32'b0)        //a NOP occurs
        begin
            ID_shift_imm = 1'b0;
            ID_load_instr = 1'b0;
            ID_RF_enable = 1'b0;
            ID_B_instr = 1'b0;
            ID_BL_instr = 1'b0;
            bit_S = 1'b0;
            ID_Enable_instr = 1'b0;
            ID_ReadWrite_instr = 1'b0;
            ID_shiftType = 2'b00;
            ID_Size_instr = 2'b00;
            ALU_op = 4'b0000;
        end
    else 
    begin
        instr_ID = instruction [27:25];

        case(instr_ID)      //instruction formats by bits I25-I27

            //Data processing immediate shift 
            3'b000:     
            begin
                bit_S = instruction[20];
                ALU_op = instruction[24:21];        //this bits contain the opcodes
                //bit 4 of this instruction must be 0
                if(instruction[4] == 0)    
                begin
                    if(instruction[11:5] == 7'b0)   //register shifter operand special case
                    begin
                        ID_shift_imm = 1'b0;
                        ID_load_instr = 1'b0;
                        ID_RF_enable = 1'b1;
                        ID_B_instr = 1'b0;
                        ID_BL_instr = 1'b0;
                        bit_S = 1'b0;
                        ID_Enable_instr = 1'b0;
                        ID_ReadWrite_instr = 1'b0;
                        ID_shiftType = 2'b00;       
                        ID_Size_instr = 2'b00;
                    end
                    else
                    begin
                        ID_shift_imm = 1'b1;
                        ID_load_instr = 1'b0;
                        ID_RF_enable = 1'b1;
                        ID_B_instr = 1'b0;
                        ID_BL_instr = 1'b0;
                        bit_S = 1'b0;
                        ID_Enable_instr = 1'b0;
                        ID_ReadWrite_instr = 1'b0;
                        ID_shiftType = 2'b00;       
                        ID_Size_instr = 2'b00;
                    end
                end
            end     

            //Data processing immediate [2]
            3'b001:      
            begin

                ID_shift_imm = 1'b1;
                ID_load_instr = 1'b0;
                ID_RF_enable = 1'b1;
                ID_B_instr = 1'b0;
                ID_BL_instr = 1'b0;
                bit_S = instruction[20];
                ID_Enable_instr = 1'b0;
                ID_ReadWrite_instr = 1'b0;
                ID_shiftType = 2'b10;       
                ID_Size_instr = 2'b00;
                ALU_op = instruction[24:21]; 
                
            end

            //Addressing Mode 2 (slide 73 instruction formats)
            //Load/store Immediate offset
            3'b010:  
            begin
                ID_shift_imm = 1'b1;
                ID_B_instr = 1'b0;
                ID_BL_instr = 1'b0;
                bit_S = 1'b0;
                ID_shiftType = 2'b01;       //UPDATE
                
                    
                    // P=0 & W=1 instructions are LDRBT, LDRT, LRSBT, LDRT
                    // bit 23 = U -> add: U=1 | substract: U=0
                    // bit 22 = B -> word: B=0 | byte: B=1
                    // bit 21 = W -> 
                    // bit 20 = L -> store: L=0 | load: L=1
                
                if(instruction[23] == 0)        //verifies the sign (U - bit 23)
                begin
                    ALU_op = 4'b0010;   //U: 0 => substract  

                    if(instruction[22] == 1'b0 & instruction[20] == 1'b0)
                        begin
                            
                            ID_load_instr = 1'b0;
                            ID_RF_enable = 1'b0;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b10;
                            ID_ReadWrite_instr = 1'b1;

                        end
                    else if(instruction[22] == 1'b1 & instruction[20] == 1'b0)
                        begin
                            
                            ID_load_instr = 1'b0;
                            ID_RF_enable = 1'b0;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b00;
                            ID_ReadWrite_instr = 1'b1;

                        end
                    else if(instruction[22] == 1'b0 & instruction[20] == 1'b1)
                        begin
                            
                            ID_load_instr = 1'b1;
                            ID_RF_enable = 1'b1;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b10;
                            ID_ReadWrite_instr = 1'b0;

                        end
                    else if(instruction[22] == 1'b1 & instruction[20] == 1'b1)
                        begin
                            
                            ID_load_instr = 1'b1;
                            ID_RF_enable = 1'b1;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b00;
                            ID_ReadWrite_instr = 1'b0;

                        end          
                end
                else        //bit 23 is 1, therefore U = 1
                begin
                    ALU_op = 4'b0100;   //U: 1 => add

                    if(instruction[22] == 1'b0 & instruction[20] == 1'b0)
                        begin
                            
                            ID_load_instr = 1'b0;
                            ID_RF_enable = 1'b0;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b10;
                            ID_ReadWrite_instr = 1'b1;

                        end
                    else if(instruction[22] == 1'b1 & instruction[20] == 1'b0)
                        begin
                            
                            ID_load_instr = 1'b0;
                            ID_RF_enable = 1'b0;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b00;
                            ID_ReadWrite_instr = 1'b1;

                        end
                    else if(instruction[22] == 1'b0 & instruction[20] == 1'b1)
                        begin
                            
                            ID_load_instr = 1'b1;
                            ID_RF_enable = 1'b1;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b10;
                            ID_ReadWrite_instr = 1'b0;

                        end
                    else if(instruction[22] == 1'b1 & instruction[20] == 1'b1)
                        begin
                            
                            ID_load_instr = 1'b1;
                            ID_RF_enable = 1'b1;
                            ID_Enable_instr = 1'b1;
                            ID_Size_instr = 2'b00;
                            ID_ReadWrite_instr = 1'b0;

                        end       
                end 
            end

            //Load/Store Register Offset
            3'b011:     
            begin
                bit_S = 0;          //can't modify condition codes 
                ID_B_instr = 1'b0;
                ID_BL_instr = 1'b0;

                if(instruction[11:4] == 7'b0)       //special case of scaled register offset 
                    ID_shift_imm = 1'b0;
                else                                //Scaled register offset instruction
                    ID_shift_imm = 1'b1;
                    ID_shiftType = 2'b11;       //UPDATE

                if(instruction[4] == 0)     //bit 4 of this instruction must be 0, ALWAYS | If it is 1, wrong addressing modeh
                begin
                    if(instruction[23] == 0)        //verifies the sign (U - bit 23)
                    begin
                        ALU_op = 4'b0010;   //U: 0 => substract  

                        if(instruction[22] == 1'b0 & instruction[20] == 1'b0)
                            begin
                                
                                ID_load_instr = 1'b0;
                                ID_RF_enable = 1'b0;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b10;
                                ID_ReadWrite_instr = 1'b1;

                            end
                        else if(instruction[22] == 1'b1 & instruction[20] == 1'b0)
                            begin
                                
                                ID_load_instr = 1'b0;
                                ID_RF_enable = 1'b0;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b00;
                                ID_ReadWrite_instr = 1'b1;

                            end
                        else if(instruction[22] == 1'b0 & instruction[20] == 1'b1)
                            begin
                                
                                ID_load_instr = 1'b1;
                                ID_RF_enable = 1'b1;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b10;
                                ID_ReadWrite_instr = 1'b0;

                            end
                        else if(instruction[22] == 1'b1 & instruction[20] == 1'b1)
                            begin
                                
                                ID_load_instr = 1'b1;
                                ID_RF_enable = 1'b1;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b00;
                                ID_ReadWrite_instr = 1'b0;

                            end          
                    end
                    else        //bit 23 is 1, therefore U = 1
                    begin
                        ALU_op = 4'b0100;   //U: 1 => add

                        if(instruction[22] == 1'b0 & instruction[20] == 1'b0)
                            begin
                                
                                ID_load_instr = 1'b0;
                                ID_RF_enable = 1'b0;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b10;
                                ID_ReadWrite_instr = 1'b1;

                            end
                        else if(instruction[22] == 1'b1 & instruction[20] == 1'b0)
                            begin
                                
                                ID_load_instr = 1'b0;
                                ID_RF_enable = 1'b0;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b00;
                                ID_ReadWrite_instr = 1'b1;

                            end
                        else if(instruction[22] == 1'b0 & instruction[20] == 1'b1)
                            begin
                                
                                ID_load_instr = 1'b1;
                                ID_RF_enable = 1'b1;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b10;
                                ID_ReadWrite_instr = 1'b0;

                            end
                        else if(instruction[22] == 1'b1 & instruction[20] == 1'b1)
                            begin
                                
                                ID_load_instr = 1'b1;
                                ID_RF_enable = 1'b1;
                                ID_Enable_instr = 1'b1;
                                ID_Size_instr = 2'b00;
                                ID_ReadWrite_instr = 1'b0;

                            end       
                    end
                end
            end

            //branch or branch&link
            3'b101:     
            begin
 

                ID_shift_imm = 1'b0;
                ID_load_instr = 1'b0;
                ID_RF_enable = 1'b0;  //se ejecuta como un NOP
                ID_B_instr = 1'b1;      //bits 27-25 are 101 indeed
                bit_S = 1'b0;
                ID_Enable_instr = 1'b0;
                ID_ReadWrite_instr = 1'b0;
                ID_shiftType = 2'b00;       //UPDATE
                ID_Size_instr = 2'b00;
                ALU_op = 4'b0000;

                if(instruction[24] == 1)       //L = 1 then BL instr signal should be 1
                    ID_BL_instr = 1;    
                else                            //L = 0 then Bl instr should be 0
                    ID_BL_instr = 0;
                
            end
        endcase
    end  
end  
endmodule

module register (output reg [31:0] Qs, input [31:0] PW, input Ld, clk, reset);

always @ (posedge clk)
   begin
   $display("PC reset value: %b | clk = %b | time:%d", reset, clk, $time);
     if(reset) Qs <= 32'b0;  
     else if (Ld) Qs <= PW;
   end 

endmodule


//IF Stage

module adder_PC4(output [31:0] PC4, input [31:0] PC_out);

    assign PC4 = PC_out + 4'b0100;

endmodule


//IF/ID Pipeline

module IF_ID_pipeline (output reg [31:0] instruction_to_CU, input [31:0] instr_memory_out, input clk, reset, enable);  //add enable!!
//FALTA enable | reset tiene prioridad 

always @ (posedge clk)
begin
    //$display("IF reset value: %b", reset);
    if(reset) instruction_to_CU <= 32'b00000000000000000000000000000000;
    else instruction_to_CU <= instr_memory_out; 
end 
endmodule

//Control Unit Multiplexer 
module mux_control_unit(output reg [13:0] mux_cu_out, input [13:0] cu_in_mux, input S);


// mux_cu_out[0] = ID_shift_imm;

// mux_cu_out[1] = ID_load_instr;
// mux_cu_out[2] = ID_RF_enable;
// mux_cu_out[3] = ID_Enable_instr;
// mux_cu_out[4] = ID_ReadWrite_instr;
// mux_cu_out[6:5] = ID_Size_instr;

// mux_cu_out[7] = bit_S;
// mux_cu_out[9:8] = ID_shiftType;
// mux_cu_out[13:10] = ALU_op;


always @(S, cu_in_mux)

    if(S) mux_cu_out <= 14'b0;
    else mux_cu_out <= cu_in_mux; 

endmodule

//ID/EX Stage
module ID_EX_pipeline (output reg [13:0] EX_signals_out, input [13:0] ID_signals_in, input clk, reset);


// EX_signals_out[0] = ID_shift_imm;

// EX_signals_out[1] = ID_load_instr;
// EX_signals_out[2] = ID_RF_enable;
// EX_signals_out[3] = ID_Enable_instr;
// EX_signals_out[4] = ID_ReadWrite_instr;
// EX_signals_out[6:5] = ID_Size_instr;

// EX_signals_out[7] = bit_S;
// EX_signals_out[9:8] = ID_shiftType;
// EX_signals_out[13:10] = ALU_op;


always @(posedge clk)

    if(reset) EX_signals_out <= 14'b0;
    else EX_signals_out <= ID_signals_in;
    
endmodule


//EX/MEM Stage
module EX_MEM_pipeline (output reg [5:0] MEM_signals_out, input [5:0] EX_signals_in, input clk, reset);



// MEM_signals_out[0] = ID_load_instr;
// MEM_signals_out[1] = ID_RF_enable;
// MEM_signals_out[2] = ID_Enable_instr;
// MEM_signals_out[3] = ID_ReadWrite_instr;
// MEM_signals_out[5:4] = ID_Size_instr;


always @( posedge clk)
     
     if(reset) MEM_signals_out <= 6'b0;
     else MEM_signals_out <= EX_signals_in;
     
endmodule


//MEM/WB Stage

module MEM_WB_pipeline (output reg [1:0] WB_signals_out, input [1:0] MEM_signals_in, input clk, reset);
 
// WB_signals_out[0] = ID_load_instr;
// WB_signals_out[1] = ID_RF_enable;

always @(posedge clk)

   if(reset) WB_signals_out <= 2'b0;
   else WB_signals_out <= MEM_signals_in;

endmodule




module inst_ram256x8(output reg[31:0] DataOut, input [31:0]Address); 
   // Definining 256 locations for bytes           
   reg[7:0] Mem[0:255];

   //Operation runs while cycle operates from 0 to 1
    always @(Address)

        begin
            DataOut = { Mem[Address], Mem[Address + 1], Mem[Address + 2], Mem[Address + 3]}; 
            $display("\n\n***address: %b | instr memory: %b | time: %d****\n\n", Address, DataOut, $time);
        end
endmodule




module container_box_phase3;

//parameter sym_time = 100;
//initial #sym_time $finish;
    

//Control Unit inputs & outputs
wire [13:0] cu_out;
wire [1:0] b_bl_signals;
reg [31:0] instruction;

//mux cu inputs & outputs
wire [13:0] mux_cu_out;
reg [13:0] cu_in_mux;
reg S;

//IF/ID inputs & outputs
wire [31:0] instruction_to_CU;
reg [31:0] instr_memory_out; 
reg clk, reset, enable;

//ID/EX inputs & outputs
wire [13:0] EX_signals_out;
reg [13:0] ID_signals_in;

//EX/MEM inputs & outputs
wire [5:0] MEM_signals_out;
reg [5:0] EX_signals_in;

//MEM/WB inputs & outputs
wire [1:0] WB_signals_out;
reg [1:0] MEM_signals_in; 
//reg clk, reset;

//register inputs & outputs
wire [31:0] Qs;
reg [31:0] PW;
reg Ld;

//adderpc4 inputs & outputs
wire [31:0] PC4;
reg [31:0] PC_out;



// initial #100 $finish;
// initial begin
//     clk <= 1'b1;
//     forever #2 clk = ~clk; 
// end

// initial begin
//     reset = 1'b1;
//     #3 reset = 1'b0;
// end



// initial #100 $finish;
// initial begin
//     clk <= 1'b0;
//     forever #2 clk = ~clk; 
// end

// initial begin
//     reset = 1'b1;
//     #2 reset = 1'b0;
// end

initial begin
     reset<=1'b1;
     clk<=1'b0;
     repeat(2) #2 clk=~clk;
     reset<=1'b0;
     $display("\n ******AFTER RESET****** TIME: %d", $time);
     //clk=1'b0;  //not necessary
     repeat(50)begin
        #2 clk=~clk;
     end
end


initial begin
    S = 1'b0;
end

initial begin
    Ld = 1'b1;
end


// initial begin
//     PC_out = 32'b00000000000000000000000000000000;
// end

    integer fi,fo,code,i; reg[7:0]data; 
    reg Enable, ReadWrite; reg [31:0] DataIn; 
    reg [31:0] Address; wire [31:0] DataOut;
    inst_ram256x8 ram1 (DataOut, Qs);
    initial begin
        fi = $fopen("PF1_Rodriguez_Ramos_Homar_ramint.txt","r"); 
        Address = 32'b0;

        while (!$feof(fi))
        begin
            code = $fscanf(fi, "%b", data);
            ram1.Mem[Address] = data; 
            Address = Address + 1;

        end
        $fclose(fi);
    end

    initial begin 
        fo=$fopen("PF1_Rodriguez_Ramos_Homar_ramInst_memcontent.txt","w");
        $display("Initializing Memory precharge with input data...");
        Enable = 1'b0; ReadWrite = 1'b1;
        Address = #1 32'b0;
        
        // $display("Instruction Memory Operation\n");
        // $display( "The following output prints the first 16 memory address locations\n");
        // $display( "         Address       Data Out");


    repeat (9) begin
        #5 Enable = 1'b1;
        #5 Enable = 1'b0;
        Address = Address + 4;
    end
    $finish; 
    end

    

adder_PC4 adder_test(PC4, Qs);  

register PC(Qs, PC4, Ld, clk, reset);

IF_ID_pipeline test1(instruction_to_CU, DataOut, clk, reset, enable);

control_unit test2 (cu_out, b_bl_signals, instruction_to_CU);

mux_control_unit test6(mux_cu_out, cu_out, S);

ID_EX_pipeline test3(EX_signals_out, mux_cu_out, clk, reset);

EX_MEM_pipeline test4(MEM_signals_out, EX_signals_out[6:1], clk, reset);

MEM_WB_pipeline test5(WB_signals_out, MEM_signals_out[1:0], clk, reset);
 

initial begin
       
       
    $monitor("\n\n TIME: %d | CLK: %b\nData Out (Memory): %b | PC: %d | Reset: %b\n--->IF ID out: %b<---\n--------Control Unit Outputs Signals-------- \n\nID_shift_imm: %b | ID_load_instr: %b | ID_RF_enable: %b | ID_Enable_instr: %b | ID_ReadWrite_instr: %b | ID_Size_instr: %b | bit_S: %b | ID_shiftType: %b | ALU_op: %b | ID_B_instr: %b | ID_BL_instr: %b \n\n-> Mux CU Output: %b \n---> Pipeline ID-EX Output: %b | B_instr: %b | BL_instr: %b \n-----> Pipeline EX-MEM Output: %b | B_instr: %b | BL_instr: %b \n--------> Pipeline MEM-WB Output: %b | B_instr: %b | BL_instr: %b", $time, clk, DataOut, Qs, reset, instruction_to_CU, cu_out[0], cu_out[1], cu_out[2], cu_out[3], cu_out[4], cu_out[6:5], cu_out[7], cu_out[9:8], cu_out[13:10], b_bl_signals[0], b_bl_signals[1], mux_cu_out, EX_signals_out, b_bl_signals[0], b_bl_signals[1], MEM_signals_out, b_bl_signals[0], b_bl_signals[1], WB_signals_out, b_bl_signals[0], b_bl_signals[1]);



//     $monitor("\n\n TIME: %d | CLK: %b\nData Out (Memory): %b | PC: %d | Reset: %b\n", $time, clk, DataOut, PC4, reset);
//     $monitor("--->IF ID out: %b<---\n--------Control Unit Outputs Signals-------- \n\nID_shift_imm: %b | ID_load_instr: %b | ID_RF_enable: %b | ID_Enable_instr: %b | ID_ReadWrite_instr: %b | ID_Size_instr: %b | bit_S: %b | ID_shiftType: %b | ALU_op: %b | ID_B_instr: %b | ID_BL_instr: %b ",instruction_to_CU, cu_out[0], cu_out[1], cu_out[2], cu_out[3], cu_out[4], cu_out[6:5], cu_out[7], cu_out[9:8], cu_out[13:10], b_bl_signals[0], b_bl_signals[1]);
//     $monitor("\n-> Mux CU Output: %b \n---> Pipeline ID-EX Output: %b | B_instr: %b | BL_instr: %b", mux_cu_out, EX_signals_out, b_bl_signals[0], b_bl_signals[1]);
//     $monitor("-----> Pipeline EX-MEM Output: %b | B_instr: %b | BL_instr: %b", MEM_signals_out, b_bl_signals[0], b_bl_signals[1]);
//     $monitor("--------> Pipeline MEM-WB Output: %b | B_instr: %b | BL_instr: %b", WB_signals_out, b_bl_signals[0], b_bl_signals[1]);




//     $display("TIME: %d\n RESET: %b | CLK: %b | Ld = %b | S: %b", $time, reset, clk, Ld, S);
        
    
//        $display("\n---------------- IF ID Pipeline ------------------");
//        $display("\nINSTRUCTION_TO_CU = %b", instruction_to_CU);

//        $display("\n---------------- CU output: %b | %b ------------------", cu_out, cu_out[13:10]);
//        $display("ID_SHIFT_IM = %b | ID_LOAD_INSTR = %b | ID_RF_ENABLE = %b | ID_ENABLE_INSTR = %b | ID_RW_INSTR = %b | SIZE = %b | bitS = %b | ID_SHIFT_TYPE = %b | ALU_OP_CODE = %b | ID_B_INSTR = %b | ID_BL_INSTR = %b", cu_out[0], cu_out[1], cu_out[2], cu_out[3], cu_out[4], cu_out[6:5], cu_out[7], cu_out[9:8], cu_out[13:10], b_bl_signals[0], b_bl_signals[1]);
        
//        $display("\n---------------- CU MUX output: %b | %b ------------------", mux_cu_out, cu_out[13:10]);
//        $display("ID_SHIFT_IM = %b | ID_LOAD_INSTR = %b | ID_RF_ENABLE = %b | ID_ENABLE_INSTR = %b | ID_RW_INSTR = %b | SIZE = %b | bitS = %b | ID_SHIFT_TYPE = %b | ALU_OP_CODE = %b", mux_cu_out[0], mux_cu_out[1], mux_cu_out[2], mux_cu_out[3], mux_cu_out[4], mux_cu_out[6:5], mux_cu_out[7], mux_cu_out[9:8], mux_cu_out[13:10]);
        
//        $display("\n---------------- ID EX Pipeline: %b | %b ------------------", EX_signals_out, cu_out[13:10]);
//        $monitor("EX_SHIFT_IM = %b | EX_LOAD_INSTR = %b | EX_RF_ENABLE = %b | EX_ENABLE_INSTR = %b | EX_RW_INSTR = %b | EX_SIZE = %b | EX_bitS = %b | EX_SHIFT_TYPE = %b | ALU_OP_CODE = %b", EX_signals_out[0], EX_signals_out[1], EX_signals_out[2], EX_signals_out[3], EX_signals_out[5:4], EX_signals_out[6], EX_signals_out[7], EX_signals_out[9:8], EX_signals_out[13:10]);

//        $display("\n---------------- EX MEM Pipeline: %b | %b ------------------", MEM_signals_out, cu_out[13:10]);
//        $display("MEM_LOAD_INSTR = %b | MEM_RF_ENABLE = %b | MEM_ENABLE_INSTR = %b | MEM_RW_INSTR = %b | MEM_SIZE = %b", MEM_signals_out[0], MEM_signals_out[1], MEM_signals_out[2], MEM_signals_out[3], MEM_signals_out[5:4]);

//        $display("\n---------------- MEM WB Pipeline: %b | %b ------------------", WB_signals_out, cu_out[13:10]);
//        $display("WB_LOAD_INSTR = %b | WB_RF_ENABLE = %b\n\n\n", WB_signals_out[0], WB_signals_out[1]);

//        $display("\n--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n");

end 

endmodule


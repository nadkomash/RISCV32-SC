
/*

Load instruction generator.
* AluResult[31:2] is the word address
* AluResult[1:0] is the byte offset within the word, used to determine which byte or half-word to select for LB, LH, LBU, LHU.

lb / lbu  :::  Explicitly: 
offset    |     DataGen
00              ReadData[7:0]  
01              ReadData[15:8] 
10              ReadData[23:16] 
11              ReadData[31:24] 

lh / lhu  :::  Explicitly: 
offset[1]   |     DataGen
0              ReadData[15:0]  
1              ReadData[31:16] 
*/


module loadGenerator (
    
    input  logic [31:0] ReadData, // data read from memory
    input  logic [1:0]  offset,    //byte offset within the word  [ALUResult[1:0]]
    input  logic [2:0]  Size,      ///by funct3
    output logic [31:0] DataGen     // the final output after applying the appropriate load type (LB, LH, LW, LBU, LHU)
);

    // Byte and Half-word selection using Indexed Part-Select   
    wire [7:0]  byte_sel = ReadData[8*offset +: 8];
    wire [15:0] half_sel = ReadData[16*offset[1] +: 16];

    // Sign Extension
    wire [31:0] LB_out  = {{24{byte_sel[7]}},  byte_sel};
    wire [31:0] LH_out  = {{16{half_sel[15]}}, half_sel};
    wire [31:0] LW_out  = ReadData;

    // Zero Extention implementation for LBU and LHU
    wire [31:0] LBU_out = {24'b0, byte_sel};
    wire [31:0] LHU_out = {16'b0, half_sel};

    //Output
    assign DataGen =
        (Size == 3'b000) ? LB_out  :
        (Size == 3'b001) ? LH_out  :
        (Size == 3'b010) ? LW_out  :
        (Size == 3'b100) ? LBU_out :
        (Size == 3'b101) ? LHU_out :
                                 32'hDEAD_BEEF; // illegal funct3
endmodule
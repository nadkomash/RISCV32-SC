
/*
Sign extensor implementation:
for different instruction types, the immediate value is located in different positions in the instruction. 
This module takes the instruction as input and outputs the sign-extended immediate value.


*/
module signExtensor(
    input logic [31:7] in, // 25 bits of the instruction (bits [31:7]) (without the opcode)
    input logic [2:0] ImmSrc, // opcode to determine instruction type
    output logic [31:0] signImm

);
    wire [11:0] immI = in[31:20];
    wire [11:0] immS = {in[31:25], in[11:7]};
    wire [12:0] immB = {in[31], in[7], in[30:25], in[11:8], 1'b0};
    wire [20:0] immJ = {in[31], in[19:12], in[20], in[30:21], 1'b0};
    wire [19:0] immU = {in[31:12]};

    assign signImm =
        (ImmSrc == 3'b000) ? {{20{immI[11]}}, immI} :
        (ImmSrc == 3'b001) ? {{20{immS[11]}}, immS} :
        (ImmSrc == 3'b010) ? {{19{immB[12]}}, immB} :
        (ImmSrc == 3'b011) ? {{11{immJ[20]}}, immJ} :
                             {immU, 12'b0};

endmodule



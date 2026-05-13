/*
Alu module for RISC-V 32-bit single-cycle processor.

base on alu decoder truth table from documentation.

outputs:
result : 32-bit result of the ALU operation
zero : 1-bit flag that is set to 1 if the result is zero, otherwise 0

*/

module alu (
    
    //inputs
    input logic [31:0] a, 
    input logic [31:0] b,
    input logic [3:0] ALUControl,

    //outputs
    output logic [31:0] y,
    output logic Zero,
    output logic Neg,
    output logic NegU
);



    //if ALUControl[0] is 1, we want to perform subtraction, which is equivalent to adding the
    // two's complement of b (i.e., ~b + 1)
    // if ALUControl[0] is 0, we want to perform addition, which is just a + b


    wire [31:0] b_eff   = b ^ {32{ALUControl[0]}};   // B or ~B
    wire        cin     = ALUControl[0];             // 0: ADD, 1: SUB

    // wide adders so we get carries
    wire [32:0] sum_agg  = {1'b0, a} + {1'b0, b_eff} + cin;     // full 32b add
    wire [31:0] sum     = sum_agg[31:0];
    wire        c_out   = sum_agg[32];

    // carry *into* MSB (from lower 31 bits) for signed overflow detection
    wire [31:0] low_sum31;
    wire        c_in31;
    assign {c_in31, low_sum31[30:0]} =
        {1'b0, a[30:0]} + {1'b0, b_eff[30:0]} + cin;

    // Flags
    wire N = sum[31];
    wire V = c_in31 ^ c_out;     // signed overflow (add/sub)
    wire C = c_out;              // carry-out (for unsigned)
            

    assign Zero = (y == 32'b0);
    assign Neg  = N ^ V;         // a < b (signed)  from a-b path
    assign NegU = ~C;            // a < b (unsigned) : borrow = ~carry

    logic [4:0] shamt;
    assign shamt = b[4:0]; //logical shamt is rs2[4:0] or uimm = immediate[4:0] for shift instructions

    always_comb begin
        case (ALUControl)
            4'b0000: y = sum;                                  // add
            4'b0001: y = sum;                                  // SUB
            4'b0010: y = $unsigned(a) << shamt;                // slli ,sll
            4'b0011: y = Neg;                                  // slti , slt (using sub method as before)
            4'b1011: y = NegU   ;                               // sltu, sltiu
            4'b0100: y = a ^ b;                                 // xori .xor
            4'b0101: y = $unsigned(a) >> shamt;                 // srli, srl            
            4'b1101: y = $signed(a) >>> shamt;                  // srai, sra
            4'b0110: y = a | b;                                 // ori, or
            4'b0111: y = a & b;                                 // andi, and   

            default: y = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx; // undefined
        endcase
    end

    

endmodule
module branchLogic(
    input logic [2:0] funct3,
    input logic Zero,
    input logic Neg,
    input logic NegU,
    output logic btFlag
);

wire funct3_lsb = funct3[0];
always_comb begin
    case(funct3)
        3'b000:  btFlag = Zero ;    // beq     
        3'b001:  btFlag = ~Zero ;   // bne
        3'b100:  btFlag = Neg  ;    // blt
        3'b101:  btFlag = ~Neg  ;   // bge
        3'b110:  btFlag = NegU  ;   // bltu
        3'b111:  btFlag = ~NegU ;   // bgeu
        default:
         btFlag = 1'bx;
    endcase
end
endmodule
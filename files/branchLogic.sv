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
        3'b110:  btFlag = NegU  ;   // bltuS
        3'b111:  btFlag = ~NegU ;   // bgeu
        default:
         btFlag = 1'b0;
    endcase
end

// always @(funct3, Zero, Neg, NegU) begin
//     if ($time >= 80 && $time <= 100) begin
//         $display("[%0t] BRANCH_DEBUG: funct3=%b, Zero=%b, Neg=%b -> btFlag=%b", 
//                  $time, funct3, Zero, Neg, btFlag);
//     end
// end
endmodule
module branchLogic(
    input logic [2:0] funct3,
    input logic Zero,
    input logic NEG,
    input logic NEGU,
    output logic Branch_Taken
);

wire funct3_lsb = funct3[0];
always_comb begin
    case(funct3)
    3'b000,3'b001:
        Branch_Taken = Zero ^ funct3_lsb;
    3'b100,3'b101:
        Branch_Taken = NEG ^ funct3_lsb;
    3'b110,3'b111:
        Branch_Taken = NEGU ^ funct3_lsb;
    default:
        Branch_Taken = 1'bx;
    endcase
end

endmodule
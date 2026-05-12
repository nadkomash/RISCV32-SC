// module controller(
//     input logic [6:0] opcode,
//     input logic [2:0] funct3,
//     input logic funct7_5,
//     input logic Zero,
//     input logic Neg,
//     input logic NegU,
//     output logic RegWrite,
//     output logic [2:0] ImmSrc,
//     output logic ALUSrcB,
//     output logic ALUSrcA,
//     output logic MemWrite,
//     output logic [1:0] ResultSrc,
//     output logic [1:0] PCSrc,
//     output logic [3:0] ALUControl,
//     output logic [2:0] Size
// );
//     logic Branch;
//     logic Jump;
//     logic Jalr;
//     logic [1:0] ALUOp;
//     logic btFlag;

//     mainDecoder md (.opcode(opcode), .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrcA(ALUSrcA), .Jalr(Jalr),
//     .ALUSrcB(ALUSrcB), .MemWrite(MemWrite), .ResultSrc(ResultSrc), .ALUOp(ALUOp), .Jump(Jump), .Branch(Branch));

//     aluDecoder ad (.ALUOp(ALUOp), .funct3(funct3), .op5(opcode[5]), .funct7_5(funct7_5),
//      .ALUControl(ALUControl));

//     branchLogic bl (.funct3(funct3), .Zero(Zero), .neg(neg), .NegU(NegU), .btFlag(btFlag));

//     assign PCSrc = (Branch & btFlag ? 2'b01 :
//                     Jump                    ? 2'b01 :
//                     Jalr                   ? 2'b10 : 2'b00;

//     assign Size = funct3;

// endmodule
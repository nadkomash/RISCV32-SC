module controller(
    //inputs from instruction fields
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_5,
    //inputs from ALU flags
    input logic Zero,
    input logic Neg,
    input logic NegU,

    //outputs - control signals to datapath.
    output logic RegWrite,ALUSrcA,ALUSrcB,MemWrite,
    output logic [2:0] ImmSrc,
    output logic [1:0] ResultSrc,
    output logic [1:0] PCSrc,
    output logic [3:0] ALUControl,
    output logic [2:0] Size
);

    //those are the control signals to stay within the controlpath.
    logic Branch;
    logic Jump;
    logic Jalr;
    logic [1:0] ALUOp;
    logic btFlag;


    mainDecoder md (.opcode(opcode), .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), 
     .MemWrite(MemWrite), .ResultSrc(ResultSrc),  .Branch(Branch),.ALUOp(ALUOp), .Jump(Jump), .Jalr(Jalr));
//added

    aluDecoder ad (.ALUOp(ALUOp), .funct3(funct3), .op5(opcode[5]), .funct7_5(funct7_5),
     .ALUControl(ALUControl));

    branchLogic bl (.funct3(funct3), .Zero(Zero), .Neg(Neg), .NegU(NegU), .btFlag(btFlag));

    assign PCSrc = (Branch & btFlag | Jump) ? 2'b01 :
                    Jalr                   ? 2'b10 : 
                    2'b00;

    assign Size = funct3;

endmodule
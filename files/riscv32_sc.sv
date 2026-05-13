 module riscv32_sc(
    input logic clk, rst_n,
    input logic [31:0] ReadData,
    input logic [31:0] instr,
    output logic [31:0] PC,
    output logic MemWrite,
    output logic [31:0] ALUResult, WriteData,
    output logic [2:0] Size
);

    logic ALUSrcB,ALUSrcA, RegWrite, Jump, Zero, Neg, NegU;
    logic [1:0] ResultSrc;
    logic [2:0] ImmSrc;
    logic [3:0] ALUControl;
    logic [1:0] PCSrc;

    controlpath cp(.opcode(instr[6:0]), .funct3(instr[14:12]), .funct7_5(instr[30]), 
                   .Zero(Zero), .Neg(Neg), .NegU(NegU),
                   .RegWrite(RegWrite),  .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA),.MemWrite(MemWrite),
                   .ImmSrc(ImmSrc),.ResultSrc(ResultSrc), .PCSrc(PCSrc),.ALUControl(ALUControl), .Size(Size),);
                  


    datapath dp(.clk(clk), .rst_n(rst_n), .instr(instr),
                .RegWrite(RegWrite),.ALUSrcA(ALUSrcA),.ALUSrcB(ALUSrcB),
                .ImmSrc(ImmSrc), .ResultSrc(ResultSrc), .PCSrc(PCSrc), .ReadData(ReadData),
                .ALUControl(ALUControl),.Size(Size),
                .PC(PC), .Zero(Zero),.Neg(Neg), .NegU(NegU),.ALUResult(ALUResult),
                .WriteData(WriteData),);

endmodule
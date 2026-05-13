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

    controlpath cp(.opcode(instr[6:0]), .funct3(instr[14:12]), .funct7_5(instr[30]), .Zero(Zero),
                .ResultSrc(ResultSrc), .MemWrite(MemWrite), .PCSrc(PCSrc), .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA),
                .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUControl(ALUControl), .Size(Size), .Neg(Neg), .NegU(NegU));

    datapath dp(.clk(clk), .rst_n(rst_n), .ResultSrc(ResultSrc), .PCSrc(PCSrc), .ALUSrcB(ALUSrcB),
                .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrcA(ALUSrcA),
                .ALUControl(ALUControl), .Zero(Zero), .PC(PC), .instr(instr), .ALUResult(ALUResult),
                .WriteData(WriteData), .ReadData(ReadData), .Size(Size), .Neg(Neg), .NegU(NegU));

endmodule
// module datapath(
//     input clk,
//     input rst_n,
//     input logic [31:0] instr,
//     input logic RegWrite, ALUSrcA, ALUSrcB,
//     input logic [2:0] ImmSrc,
//     input logic [1:0] ResultSrc,
//     input logic [1:0] PCSrc,
//     input logic [31:0] ReadData,
//     input logic [3:0] ALUControl,
//     input logic [2:0] Size,

//     output logic [31:0] PC,
//     output logic Zero,Neg,NegU,
//     output logic [31:0] ALUResult,
//     output logic [31:0] WriteData
// );
//      // logics inside the datapath 
//     logic [31:0] SrcA, SrcB, immGen, PCplusImm, PCplus4, PCNext, Result, dataGen, RD1;
//     wire [31:0] masked_pc = {ALUResult[31:1], 1'b0};

//     adder PCplus4 (.a(PC), .b(32'b100), .y(PCplus4));
//     adder PCplusImm (.a(PC), .b(immGen), .y(PCplusImm));

//     ImmGenerator ig (.in(instr[31:7]), .ImmSrc(ImmSrc), .ImmGen(immGen));

//     registerFile rf (.clk(clk), .RegWrite(RegWrite), .a1(instr[19:15]), .a2(instr[24:20]), .a3(instr[11:7]), .wd3(Result), .rd1(RD1), .rd2(WriteData));

//     ff_r PC_Next_Reg (.clk(clk), .rst_n(rst_n), .d(PCNext), .q(PC));

//     mux2to1 mux_SrcB (.a(WriteData), .b(immGen), .s(ALUSrcB), .y(SrcB));
//     mux2to1 mux_SrcA (.a(RD1), .b(PC), .s(ALUSrcA), .y(SrcA));
//     mux4to1 mux_Result (.a(ALUResult), .b(dataGen), .c(PCCplus4), .d(immGen), .s(ResultSrc), .y(Result));
//     mux3to1 mux_PCNext (.a(PCplus4), .b(PCplusImm), .c(masked_pc), .s(PCSrc), .y(PCNext));

//     alu alu (.a(SrcA), .b(SrcB), .ALUControl(ALUControl), .y(ALUResult), .Zero(Zero), .Neg(Neg), .NegU(NegU));
//     LoadGenerator lg (.ReadData(ReadData), .offset(ALUResult[1:0]), .Size(Size), .DataGen(dataGen));

// endmodule
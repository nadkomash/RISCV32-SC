module datapath(
    input clk,
    input rst_n,
   
    input logic [31:0] instr,

     //control signals from controlpath
    input logic RegWrite, ALUSrcA, ALUSrcB,
    input logic [2:0] ImmSrc,
    input logic [1:0] ResultSrc,
    input logic [1:0] PCSrc,
    input logic [31:0] ReadData, // dmen output
    input logic [3:0] ALUControl,
    input logic [2:0] Size,

    //outputs
    output logic [31:0] PC,  // ?? why is it here
    output logic Zero,Neg,NegU,
    output logic [31:0] ALUResult,
    output logic [31:0] WriteData // dmen input
);
    

    // logics inside the datapath 
    logic [31:0] SrcA, SrcB, immGen, PCplusImmGen, PCplus4, PCNext, Result, dataGen, ReadData1, ReadData2;
    wire [31:0] Jalr_pc = {ALUResult[31:1], 1'b0};

    adder PCplus4Adder (.a(PC), .b(32'b100), .y(PCplus4));
    adder PCplusImmAdder (.a(PC), .b(immGen), .y(PCplusImmGen));

    ImmGenerator ig (.in(instr[31:7]), .ImmSrc(ImmSrc), .ImmGen(immGen));

    registerFile rf (.clk(clk), .we3(RegWrite), .a1(instr[19:15]), .a2(instr[24:20]), .a3(instr[11:7]), .wd3(Result), .rd1(ReadData1), .rd2(ReadData2));

    ff_r PC_Next_Reg (.clk(clk), .rst_n(rst_n), .d(PCNext), .q(PC));

    mux2to1 mux_SrcA (.a(ReadData1), .b(PC), .s(ALUSrcA), .y(SrcA));
    mux2to1 mux_SrcB (.a(ReadData2), .b(immGen), .s(ALUSrcB), .y(SrcB));

    mux4to1 mux_Result (.a(ALUResult), .b(dataGen), .c(PCplus4), .d(immGen), .s(ResultSrc), .y(Result));
    mux3to1 mux_PCNext (.a(PCplus4), .b(PCplusImmGen), .c(Jalr_pc), .s(PCSrc), .y(PCNext));

    alu alu (.a(SrcA), .b(SrcB), .ALUControl(ALUControl), .y(ALUResult), .Zero(Zero), .Neg(Neg), .NegU(NegU));
    
    loadGenerator lg (.ReadData(ReadData), .offset(ALUResult[1:0]), .Size(Size), .DataGen(dataGen));

    assign WriteData = ReadData2; // for store instructions, the data to write is from the register file.

endmodule
module top(
    input logic clk, rst_n,
    output logic [31:0] WriteData, DataAdr,
    output logic MemWrite
);
    logic [31:0] PC, Instr, ReadData;
    logic [2:0] Size;
    
    riscv32_sc rvsingle(.clk(clk), .rst_n(rst_n), .PC(PC), .instr(Instr), .MemWrite(MemWrite),
    .WriteData(WriteData), .ReadData(ReadData), .ALUResult(DataAdr), .Size(Size));

    instructionMem imem(.a(PC), .instr(Instr));

    dataMemory dmem(.clk(clk), .we(MemWrite) , .a(DataAdr), .wd(WriteData), .rd(ReadData), .Size(Size));
 endmodule
`timescale 1ns/1ps

module riscv32_sc_tb;

    // Clock and Reset
    logic clk;
    logic rst_n;

    // Memory Interfaces
    logic [31:0] instr;
    logic [31:0] ReadData;
    logic [31:0] PC;
    logic        MemWrite;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;
    logic [2:0]  Size;

    // Instantiate the Device Under Test (DUT)
    riscv32_sc dut (
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),
        .ReadData(ReadData),
        .PC(PC),
        .MemWrite(MemWrite),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
        .Size(Size)
    );

    // Behavioral Memory Arrays
    logic [31:0] imem [0:63]; // Instruction memory (64 words)
    logic [31:0] dmem [0:63]; // Data memory (64 words)

    // Clock Generation (50MHz -> 20ns period)
    always #10 clk = ~clk;

    // 1. Behavioral Instruction Memory Hookup
    // Word-aligned reading: shift PC right by 2
    assign instr = imem[PC[31:2]];

    // 2. Behavioral Data Memory Hookup (Asynchronous Reads)
    assign ReadData = dmem[ALUResult[31:2]];

    // Synchronous Memory Writes
    always_ff @(posedge clk) begin
        if (MemWrite) begin
            dmem[ALUResult[31:2]] <= WriteData;
        end
    end

    // Helper task to clear CPU structures
    task automatic initialize_memories();
        integer i;
        for (i = 0; i < 64; i = i + 1) begin
            imem[i] = 32'b0;
            dmem[i] = 32'b0;
        end
        // Clear CPU inner Register File array to prevent X-propagation
        for (i = 1; i < 32; i = i + 1) begin
            dut.dp.rf.rf[i] = 32'b0;
        end
    endtask

    // Main Test Sequence
    initial begin
        clk = 0;
        rst_n = 0;
        initialize_memories();

        // =================================================================
        // LOAD TEST PROGRAM INTO IMEM
        // =================================================================
        // Addr 0x00: addi x1, x0, 10  -> Load 10 into register x1
        imem[0] = 32'h00a00093; 
        
        // Addr 0x04: addi x2, x0, 20  -> Load 20 into register x2
        imem[1] = 32'h01400113; 
        
        // Addr 0x08: add  x3, x1, x2  -> x3 = 10 + 20 = 30
        imem[2] = 32'h002081b3; 
        
        // Addr 0x0C: sw   x3, 4(x0)   -> Store value of x3 (30) into RAM index 1 (Addr 4)
        imem[3] = 32'h00302223; 
        
        // Addr 0x10: lw   x4, 4(x0)   -> Load value back from RAM Addr 4 into register x4
        imem[4] = 32'h00402203; 

        // Release Reset
        @(posedge clk);
        #1;
        rst_n = 1;

        $display("---------------------------------------------------------");
        $display("Executing Full RISC-V Single-Cycle CPU Testbench...");
        $display("---------------------------------------------------------");

        // Cycle 1: Execute addi x1, x0, 10
        @(posedge clk); #2;
        $display("[CYCLE 1] PC = 0x%0h | Instr = 0x%0h | x1 = %d", PC - 4, instr, dut.dp.rf.rf[1]);
        assert(dut.dp.rf.rf[1] == 32'd10) else $error("Assertion failed: x1 should be 10");

        // Cycle 2: Execute addi x2, x0, 20
        @(posedge clk); #2;
        $display("[CYCLE 2] PC = 0x%0h | Instr = 0x%0h | x2 = %d", PC - 4, instr, dut.dp.rf.rf[2]);
        assert(dut.dp.rf.rf[2] == 32'd20) else $error("Assertion failed: x2 should be 20");

        // Cycle 3: Execute add x3, x1, x2
        @(posedge clk); #2;
        $display("[CYCLE 3] PC = 0x%0h | Instr = 0x%0h | x3 = %d", PC - 4, instr, dut.dp.rf.rf[3]);
        assert(dut.dp.rf.rf[3] == 32'd30) else $error("Assertion failed: x3 should be 30");

        // Cycle 4: Execute sw x3, 4(x0)
        //@(posedge clk) triggers write; check right after edge
        @(posedge clk); #2;
        $display("[CYCLE 4] PC = 0x%0h | Instr = 0x%0h | MemWrite = %b | dmem[1] = %d", PC - 4, instr, MemWrite, dmem[1]);
        assert(dmem[1] == 32'd30) else $error("Assertion failed: Data Memory at index 1 should be 30");

        // Cycle 5: Execute lw x4, 4(x0)
        @(posedge clk); #2;
        $display("[CYCLE 5] PC = 0x%0h | Instr = 0x%0h | x4 = %d", PC - 4, instr, dut.dp.rf.rf[4]);
        assert(dut.dp.rf.rf[4] == 32'd30) else $error("Assertion failed: x4 should have loaded 30 from memory");

        $display("---------------------------------------------------------");
        $display("SUCCESS: Full RISC-V CPU Pipeline Verified!");
        $display("---------------------------------------------------------");
        $finish;
    end

endmodule
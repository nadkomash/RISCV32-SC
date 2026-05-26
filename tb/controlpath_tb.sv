`timescale 1ns/1ps

module controller_tb;

    // Inputs to Controller
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_5;
    logic       Zero;
    logic       Neg;
    logic       NegU;

    // Outputs from Controller
    logic       RegWrite;
    logic       ALUSrcA;
    logic       ALUSrcB;
    logic       MemWrite;
    logic [2:0] ImmSrc;
    logic [1:0] ResultSrc;
    logic [1:0] PCSrc;
    logic [3:0] ALUControl;
    logic [2:0] Size;

    // Instantiate the Unit Under Test (UUT)
    controller uut (
        .opcode(opcode), .funct3(funct3), .funct7_5(funct7_5),
        .Zero(Zero), .Neg(Neg), .NegU(NegU),
        .RegWrite(RegWrite), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), .MemWrite(MemWrite),
        .ImmSrc(ImmSrc), .ResultSrc(ResultSrc), .PCSrc(PCSrc),
        .ALUControl(ALUControl), .Size(Size)
    );

    // Helper task to clear inputs before each scenario
    task clear_inputs();
        opcode   = 7'b0;
        funct3   = 3'b0;
        funct7_5 = 1'b0;
        Zero     = 1'b0;
        Neg      = 1'b0;
        NegU     = 1'b0;
        #5; // Let combinational logic settle
    endtask

    initial begin
        $display("---------------------------------------------------------");
        $display("Starting RISC-V Controller Isolation Testing...");
        $display("---------------------------------------------------------");

        // =================================================================
        // TEST 1: R-Type ADD Instruction
        // Opcode: 0110011, funct3: 000, funct7_5: 0
        // Expected: RegWrite=1, ALUSrcA=0, ALUSrcB=0, MemWrite=0, ALUControl=ADD (0000), PCSrc=PC+4 (00)
        // =================================================================
        clear_inputs();
        $display("[TEST 1] - R-Type ADD Decoding");
        opcode   = 7'b0110011; 
        funct3   = 3'b000;
        funct7_5 = 1'b0;
        #5; // Wait for combinational logic to propagate

        assert(RegWrite == 1'b1)   else $error("Test 1 Failed: RegWrite should be 1");
        assert(ALUSrcA == 1'b0)    else $error("Test 1 Failed: ALUSrcA should be 0 (rs1)");
        assert(ALUSrcB == 1'b0)    else $error("Test 1 Failed: ALUSrcB should be 0 (rs2)");
        assert(MemWrite == 1'b0)   else $error("Test 1 Failed: MemWrite should be 0");
        assert(ALUControl == 4'b0000) else $error("Test 1 Failed: ALUControl should be 4'b0000 (ADD)");
        assert(PCSrc == 2'b00)     else $error("Test 1 Failed: PCSrc should be 2'b00 (PC+4)");


        // =================================================================
        // TEST 2: I-Type LW (Load Word) Instruction
        // Opcode: 0000011, funct3: 010 (Word)
        // Expected: RegWrite=1, ALUSrcB=1 (Imm), ResultSrc=01 (DataMem), Size=010
        // =================================================================
        clear_inputs();
        $display("[TEST 2] - I-Type LW Decoding");
        opcode   = 7'b0000011;
        funct3   = 3'b010; 
        #5;

        assert(RegWrite == 1'b1)   else $error("Test 2 Failed: RegWrite should be 1");
        assert(ALUSrcB == 1'b1)    else $error("Test 2 Failed: ALUSrcB should be 1 (ImmGen)");
        assert(ResultSrc == 2'b01) else $error("Test 2 Failed: ResultSrc should be 2'b01 (ReadData)");
        assert(Size == 3'b010)     else $error("Test 2 Failed: Size must pass through funct3");
        assert(PCSrc == 2'b00)     else $error("Test 2 Failed: PCSrc should be 2'b00");


        // =================================================================
        // TEST 3: B-Type BEQ (Branch Equal) - Branch Taken Scenario
        // Opcode: 1100011, funct3: 000 (BEQ), Zero flag = 1
        // Expected: RegWrite=0, MemWrite=0, PCSrc=2'b01 (Target branch PC)
        // =================================================================
        clear_inputs();
        $display("[TEST 3] - B-Type BEQ (Branch Taken)");
        opcode   = 7'b1100011;
        funct3   = 3'b000;
        Zero     = 1'b1; // Simulate matching registers from the ALU
        #5;

        assert(RegWrite == 1'b0)   else $error("Test 3 Failed: RegWrite should be 0 for branches");
        assert(MemWrite == 1'b0)   else $error("Test 3 Failed: MemWrite should be 0");
        assert(PCSrc == 2'b01)     else $error("Test 3 Failed: PCSrc should be 2'b01 (Branch Taken)");


        // =================================================================
        // TEST 4: B-Type BEQ (Branch Equal) - Branch Not Taken Scenario
        // Opcode: 1100011, funct3: 000 (BEQ), Zero flag = 0
        // Expected: PCSrc=2'b00 (Fall-through to PC+4)
        // =================================================================
        clear_inputs();
        $display("[TEST 4] - B-Type BEQ (Branch Not Taken)");
        opcode   = 7'b1100011;
        funct3   = 3'b000;
        Zero     = 1'b0; // Simulate un-matched registers
        #5;

        assert(PCSrc == 2'b00)     else $error("Test 4 Failed: PCSrc should fallback to 2'b00 (PC+4)");


        // =================================================================
        // TEST 5: I-Type JALR Instruction
        // Opcode: 1100111
        // Expected: RegWrite=1, PCSrc=2'b10 (Jalr_pc address formatting)
        // =================================================================
        clear_inputs();
        $display("[TEST 5] - I-Type JALR Decoding");
        opcode   = 7'b1100111;
        #5;

        assert(RegWrite == 1'b1)   else $error("Test 5 Failed: RegWrite should be 1 for JALR link link");
        assert(PCSrc == 2'b10)     else $error("Test 5 Failed: PCSrc should route to 2'b10 (Jalr_pc)");

        $display("---------------------------------------------------------");
        $display("All Controller Verification Tests Completed Successfully!");
        $display("---------------------------------------------------------");
        $finish;
    end

endmodule
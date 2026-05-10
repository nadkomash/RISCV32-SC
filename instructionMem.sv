module instructionMem (


    input logic [31:0] a,   // Address input
    output logic [31:0] instr    // Instruction output
);
    // Instruction memory: 256 words of 32 bits each
    logic [31:0] imem [63:0];

    // Initialize instruction memory with some instructions (for testing)
    initial begin
        imem[0] = 32'h00000013; // NOP (ADDI x0, x0, 0)
        imem[1] = 32'h00100093; // ADDI x1, x0, 1
        imem[2] = 32'h00200113; // ADDI x2, x0, 2
        imem[3] = 32'h002081b3; // ADD x3, x1, x2
        imem[4] = 32'h00310233; // ADD x4, x2, x3
        // More instructions can be added here
    end

    // Read instruction from memory (combinational)
    assign instr = imem[a[9:2]]; // Use bits [9:2] to index the word address


endmodule

module instructionMem (


    input logic [31:0] a,   // Address input
    output logic [31:0] instr    // Instruction output
);
    // Instruction memory: 256 words of 32 bits each
    logic [31:0] imem [63:0];

    // Initialize instruction memory with some instructions (for testing)
    // initial 
    //     $readmemh("mem_sum.txt",imem);

    // Read instruction from memory (combinational)
    assign instr = imem[a[9:2]]; // Use bits [9:2] to index the word address


endmodule

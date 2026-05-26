`timescale 1ns/1ps

module datapath_tb;
    logic clk;
    logic rst_n;
    logic [31:0] instr;
    logic RegWrite, ALUSrcA, ALUSrcB;
    logic [2:0] ImmSrc;
    logic [1:0] ResultSrc;
    logic [1:0] PCSrc;
    logic [31:0] ReadData;
    logic [3:0] ALUControl;
    logic [2:0] Size;

    logic [31:0] PC;
    logic Zero, Neg, NegU;
    logic [31:0] ALUResult;
    logic [31:0] WriteData;

    datapath uut (
        .clk(clk), .rst_n(rst_n), .instr(instr),
        .RegWrite(RegWrite), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
        .ImmSrc(ImmSrc), .ResultSrc(ResultSrc), .PCSrc(PCSrc),
        .ReadData(ReadData), .ALUControl(ALUControl), .Size(Size),
        .PC(PC), .Zero(Zero), .Neg(Neg), .NegU(NegU),
        .ALUResult(ALUResult), .WriteData(WriteData)
    );

    always #10 clk = ~clk;

    // Helper task to clear or preset standard register data safely in iverilog
    task preset_registers();
        integer i;
        for (i = 1; i < 32; i = i + 1) begin
            uut.rf.rf[i] = 32'b0;
        end
    endtask

    initial begin

     // Initialize VCD dumping
        $dumpfile("tb_sim/dp_trace.vcd");
        $dumpvars(0, datapath_tb);



        clk = 0;
        rst_n = 0;
        instr = 32'b0;
        RegWrite = 0; ALUSrcA = 0; ALUSrcB = 0;
        ImmSrc = 3'b0; ResultSrc = 2'b0; PCSrc = 2'b0;
        ReadData = 32'b0; ALUControl = 4'b0; Size = 3'b0;
        
        preset_registers(); // Initialize the array safely
        
        @(posedge clk);
        #1;
        rst_n = 1;
        
        $display("---------------------------------------------------------");
        $display("Starting RISC-V Datapath Isolation Testing...");
        $display("---------------------------------------------------------");

        // =================================================================
        // TEST 1: R-Type ADD Routing
        // Target: add x3, x1, x2 (Assume x1=50, x2=30)
        // =================================================================
        $display("[TEST 1] - R-Type ADD Routing");
        uut.rf.rf[1] = 32'd50;  // Direct deposit instead of %force
        uut.rf.rf[2] = 32'd30;  
        
        instr = 32'b0000000_00010_00001_000_00011_0110011; 
        RegWrite   = 1;
        ALUSrcA    = 0; 
        ALUSrcB    = 0; 
        ALUControl = 4'b0000; 
        ResultSrc  = 2'b00;   
        PCSrc      = 2'b00;   

        @(posedge clk); #2; 
        assert(ALUResult == 32'd80) else $error("Test 1 Failed: ALUResult = %d, expected 80", ALUResult);
        assert(PC == 32'd4)         else $error("Test 1 Failed: PC = %d, expected 4", PC);


        // =================================================================
        // TEST 2: LW Routing
        // Target: lw x4, 8(x3) -> x3 was 0, let's write 80 to it. Address = 80 + 8 = 88
        // =================================================================
        $display("[TEST 2] - I-Type LW Routing");
        uut.rf.rf[3] = 32'd80; 
        
        instr = 32'b000000001000_00011_010_00100_0000011; 
        ImmSrc     = 3'b000;  
        ALUSrcA    = 0;       
        ALUSrcB    = 1;       
        ALUControl = 4'b0000; 
        ReadData   = 32'hDEADBEEF; 
        ResultSrc  = 2'b01;   
        RegWrite   = 1;
        PCSrc      = 2'b00;   
        Size       = 3'b010;  

        @(posedge clk); #2;
        assert(ALUResult == 32'd88) else $error("Test 2 Failed: Address calculation mismatch");
        assert(PC == 32'd8)         else $error("Test 2 Failed: PC did not increment to 8");

        $display("---------------------------------------------------------");
        $display("All Datapath Verification Tests Completed Successfully!");
        $display("---------------------------------------------------------");
        $finish;
    end
endmodule
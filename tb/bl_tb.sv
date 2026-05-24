`timescale 1ns / 1ps

module bl_tb;

    // Testbench signals
    logic [2:0] funct3;
    logic       Zero;
    logic       Neg;
    logic       NegU;
    wire        btFlag;

    // Simulation control
    logic clk;
    integer error_count = 0;


    always #5 clk = (clk === 1'b0); 

    // Instantiate the Device Under Test (DUT)
    branchLogic dut (
        .funct3(funct3),
        .Zero(Zero),
        .Neg(Neg),
        .NegU(NegU),
        .btFlag(btFlag)
    );

    // Verification Task
    task verify(
        input [2:0] t_funct3,
        input       t_Zero,
        input       t_Neg,
        input       t_NegU,
        input        exp_btFlag
    );
        begin
            @(posedge clk);
            funct3 <= t_funct3;
            Zero   <= t_Zero;
            Neg    <= t_Neg;
            NegU   <= t_NegU;
            
            @(posedge clk);
            #1; // Allow combinational logic to settle completely
            
            assert (btFlag === exp_btFlag) begin
                $display("SUCCESS | Time:%0t | funct3:%b | Flags [Z:%b N:%b NU:%b] | Target btFlag:%b", 
                         $time, funct3, Zero, Neg, NegU, btFlag);
            end else begin
                $error("MISMATCH! funct3:%b Flags [Z:%b N:%b NU:%b] | Got btFlag:%b | Expected:%b",
                       funct3, Zero, Neg, NegU, btFlag, exp_btFlag);
                error_count = error_count + 1;
            end
        end
    endtask

    // Main Test Vector Execution
    initial begin
          // Initialize VCD dumping
        $dumpfile("tb_sim/bl_trace.vcd");
        $dumpvars(0, bl_tb);
        // Initialize inputs
        clk = 0;
        funct3 = 3'b000;
        Zero = 0;
        Neg = 0;
        NegU = 0;

        $display("--- Starting Branch Logic Tests ---");
        #10;

        // ==========================================
        // 1. BEQ (3'b000) - Branch if Equal (Zero == 1)
        // ==========================================
        $display("\n--- Testing BEQ ---");
        verify(3'b000, 1, 0, 0, 1); // True
        verify(3'b000, 0, 1, 1, 0); // False (other flags ignored)

        // ==========================================
        // 2. BNE (3'b001) - Branch if Not Equal (Zero == 0)
        // ==========================================
        $display("\n--- Testing BNE ---");
        verify(3'b001, 0, 0, 0, 1); // True
        verify(3'b001, 1, 1, 1, 0); // False

        // ==========================================
        // 3. BLT (3'b100) - Branch if Less Than
        $display("\n--- Testing BLT ---");
        verify(3'b100, 0, 1, 0, 1); // True
        verify(3'b100, 1, 0, 1, 0); // False

        // ==========================================
        // 4. BGE (3'b101) - Branch if Greater or Equal Signed (Neg == 0)
        // ==========================================
        $display("\n--- Testing BGE ---");
        verify(3'b101, 0, 0, 1, 1); // True
        verify(3'b101, 0, 1, 0, 0); // False

        // ==========================================
        // 5. BLTU (3'b110) - Branch if Less Than Unsigned (NegU == 1)
        // ==========================================
        $display("\n--- Testing BLTU ---");
        verify(3'b110, 0, 0, 1, 1); // True
        verify(3'b110, 1, 1, 0, 0); // False

        // ==========================================
        // 6. BGEU (3'b111) - Branch if Greater or Equal Unsigned (NegU == 0)
        // ==========================================
        $display("\n--- Testing BGEU ---");
        verify(3'b111, 0, 1, 0, 1); // True
        verify(3'b111, 0, 0, 1, 0); // False

        // Summary Results
        $display("\n==========================================");
        if (error_count == 0) begin
            $display("  ALL TESTS PASSED SUCCESSFULLY! (Errors: 0)");
        end else begin
            $display("  TESTBENCH FAILED with %0d errors.", error_count);
        end
        $display("==========================================");

        $finish;
    end

endmodule
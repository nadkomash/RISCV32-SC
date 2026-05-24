`timescale 1ns/1ps

module alu_tb;
    // Signals
    logic clk;
    logic [31:0] a, b;
    logic [3:0]  ALUControl;
    logic [31:0] y;
    logic        Zero, Neg, NegU;

    // Error counter for tracking test status
    integer error_count = 0;

    // 1. Clock Generation
    always #5 clk = (clk === 1'b0); 

    // 2. DUT Instantiation
    alu dut (
        .a(a),
        .b(b),
        .ALUControl(ALUControl),
        .y(y),
        .Zero(Zero),
        .Neg(Neg),
        .NegU(NegU)
    );

    // 4. Combined Driver and Checker Task (Self-Checking)
    task verify(
        input [31:0] ta, 
        input [31:0] tb, 
        input [3:0]  top,
        input [31:0] exp_y,
        input        exp_zero,
        input        exp_neg,
        input        exp_negu
    );
        begin
            @(posedge clk);
            a          <= ta;
            b          <= tb;
            ALUControl <= top;
            
            @(posedge clk); // Wait for inputs to hit the DUT and evaluate
            #1;            // Small delay to allow combinational outputs to settle
            
            assert (y === exp_y && Zero === exp_zero && Neg === exp_neg && NegU === exp_negu)
                $display("SUCCESS | Time:%0t | OP:%b | A:%h B:%h | Y:%h | Flags [Z:%b N:%b NU:%b]",
                     $time, ALUControl, a, b, y, Zero, Neg, NegU);
            else begin
                $error("MISMATCH! OP:%b A:%h B:%h | Got: Y:%h Z:%b N:%b NU:%b | Expected: Y:%h Z:%b N:%b NU:%b",
                        ALUControl, a, b, y, Zero, Neg, NegU, exp_y, exp_zero, exp_neg, exp_negu);
                error_count = error_count + 1;
                
            end     
        end
    endtask

    // 5. Comprehensive Test Sequence (100% Instruction Matrix + Boundaries)
    initial begin
        // Initialize VCD dumping
        $dumpfile("tb_sim/alu_trace.vcd");
        $dumpvars(0, alu_tb);

        // Initialize signals
        clk = 0;
        a = 0; b = 0; ALUControl = 0;

        #10;
        $display("------- Starting 100%% Coverage Tests --------");

        // ==========================================
        // 1. ADD (4'b0000) Edge Cases
        // ==========================================
        $display("\n--- Testing ADD ---");
        // Zero baseline
        verify(32'h0000_0000, 32'h0000_0000, 4'b0000, 32'h0000_0000, 1, 0, 0);
        // Max negative addition (Your specific overflow case: INT_MIN + INT_MIN = 0)
        verify(32'h8000_0000, 32'h8000_0000, 4'b0000, 32'h0000_0000, 1, 0, 0);
        // Max positive addition (Signed overflow: INT_MAX + 1)
        verify(32'h7FFF_FFFF, 32'h0000_0001, 4'b0000, 32'h8000_0000, 0, 0, 0);
        // Unsigned roll-over (Carry out generated)
        verify(32'hFFFF_FFFF, 32'h0000_0001, 4'b0000, 32'h0000_0000, 1, 0, 0);

        // ==========================================
        // 2. SUB (4'b0001) Edge Cases
        // ==========================================
        $display("\n--- Testing SUB ---");
        // Equal numbers subtraction (Result 0)
        verify(32'hFFFF_FFFF, 32'hFFFF_FFFF, 4'b0001, 32'h0000_0000, 1, 0, 0);
        // Positive minus Negative causing signed overflow (7FFF_FFFF - (-1) = 8000_0000)
        verify(32'h7FFF_FFFF, 32'hFFFF_FFFF, 4'b0001, 32'h8000_0000, 0, 0, 1);
        // Small Unsigned minus Large Unsigned (Unsigned less-than / borrow check)
        verify(32'h0000_0005, 32'h0000_000A, 4'b0001, 32'hFFFF_FFFB, 0, 1, 1);

        // ==========================================
        // 3. SLL / SLLI (4'b0010) Shift Left Logical
        // ==========================================
        $display("\n--- Testing SLL ---");
        // Shift by 0
        verify(32'hFFFF_FFFF, 32'h0000_0000, 4'b0010, 32'hFFFF_FFFF, 0, 0, 0);
        // Shift by 1
        verify(32'h8000_0001, 32'h0000_0001, 4'b0010, 32'h0000_0002, 0, 0, 0);
        // Max Shift (31 bits)
        verify(32'hFFFF_FFFF, 32'h0000_001F, 4'b0010, 32'h8000_0000, 0, 0, 0);
        // another edge case
        verify(32'h1234_5678, 32'h0000_0020, 4'b0010, 32'h1234_5678, 0, 0, 0);

        // ==========================================
        // 4. SLT / SLTI (4'b0011) Set Less Than Signed
        // ==========================================
        $display("\n--- Testing SLT (Signed) ---");
        // Positive true condition
        verify(32'd10,        32'd20,        4'b0011, 32'h0000_0001, 0, 0, 0);
        // Negative true condition (-20 < -10)
        verify(32'hFFFF_FFEC, 32'hFFFF_FFF6, 4'b0011, 32'h0000_0001, 0, 0, 0);
        // False condition (positive vs negative)
        verify(32'd5,         32'hFFFF_FFFF, 4'b0011, 32'h0000_0000, 1, 0, 0);
        // Boundary Overflow Protection check (INT_MIN < 1 is True)
        verify(32'h8000_0000, 32'h0000_0001, 4'b0011, 32'h0000_0001, 0, 0, 0);

        // ==========================================
        // 5. SLTU / SLTIU (4'b1011) Set Less Than Unsigned
        // ==========================================
        $display("\n--- Testing SLTU (Unsigned) ---");
        // Small vs Large Unsigned (True)
        verify(32'h0000_0001, 32'hFFFF_FFFF, 4'b1011, 32'h0000_0001, 0, 0, 0);
        // Identical values (False)
        verify(32'hFFFF_FFFF, 32'hFFFF_FFFF, 4'b1011, 32'h0000_0000, 1, 0, 0);
        // Treat raw negative values as huge positive magnitudes (False)
        verify(32'hFFFF_FFFF, 32'h0000_0001, 4'b1011, 32'h0000_0000, 1, 0, 0);

        // ==========================================
        // 6. XOR / XORI (4'b0100)
        // ==========================================
        $display("\n--- Testing XOR ---");
        // Self XOR (Clears bits to 0)
        verify(32'hA5A5_5A5A, 32'hA5A5_5A5A, 4'b0100, 32'h0000_0000, 1, 0, 0);
        // Complementary XOR (Sets bits to 1)
        verify(32'h5555_5555, 32'hAAAA_AAAA, 4'b0100, 32'hFFFF_FFFF, 0, 0, 0);

        // ==========================================
        // 7. SRL / SRLI (4'b0101) Logical Right Shift
        // ==========================================
        $display("\n--- Testing SRL ---");
        // Shift right by 1 (Should shift a 0 into MSB)
        verify(32'h8000_0000, 32'h0000_0001, 4'b0101, 32'h4000_0000, 0, 0, 0);
        // Shift right by 31
        verify(32'h8000_0000, 32'h0000_001F, 4'b0101, 32'h0000_0001, 0, 0, 0);

        // ==========================================
        // 8. SRA / SRAI (4'b1101) Arithmetic Right Shift
        // ==========================================
        $display("\n--- Testing SRA ---");
        // Shift right on a negative number (Should preserve/replicate sign bit)
        verify(32'h8000_0000, 32'h0000_0001, 4'b1101, 32'hC000_0000, 0, 0, 0);
        // Shift right on a positive number (Should preserve 0 in MSB)
        verify(32'h7000_0000, 32'h0000_0001, 4'b1101, 32'h3800_0000, 0, 0, 0);
        // Full arithmetic extension down to 31 shifts
        verify(32'h8000_0000, 32'h0000_001F, 4'b1101, 32'hFFFF_FFFF, 0, 0, 0);

        // ==========================================
        // 9. OR / ORI (4'b0110)
        // ==========================================
        $display("\n--- Testing OR ---");
        verify(32'hF0F0_0000, 32'h0000_0F0F, 4'b0110, 32'hF0F0_0F0F, 0, 0, 0);

        // ==========================================
        // 10. AND / ANDI (4'b0111)
        // ==========================================
        $display("\n--- Testing AND ---");
        verify(32'hFFFF_0000, 32'hF0F0_FFFF, 4'b0111, 32'hF0F0_0000, 0, 0, 0);

        // Final Reporting
        #20;
        $display("\n------- Verification Finished -------");
        if (error_count == 0) begin
            $display(">>>> SUCCESS: 100%% Instruction Coverage Completed with 0 Errors! <<<<");
        end else begin
            $display(">>>> FAILURE: Verification complete with %d mismatches listed above. <<<<", error_count);
        end
       
        $finish;
    end

endmodule
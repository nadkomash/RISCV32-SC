`timescale 1ns/1ps

module rf_tb;
    // Signals
    logic        clk;
    logic        we3;
    logic [4:0]  a1, a2, a3;
    logic [31:0] wd3;
    logic [31:0] rd1, rd2;

    // Error counter for tracking test status
    integer error_count = 0;

    // Golden Model Mirror for Tracking Expected States in Random Testing
    // (An array of 32 elements, 32-bits wide)
    logic [31:0] golden_rf [31:0];
    integer i;

    // 1. Clock Generation
    always #5 clk = (clk === 1'b0); 

    // 2. DUT Instantiation
    registerFile dut (
        .clk(clk),
        .we3(we3),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .wd3(wd3),
        .rd1(rd1),
        .rd2(rd2)
    );

    // 4. Combined Driver and Checker Task (Self-Checking)
    task verify_write_read(
        input        t_we3,
        input [4:0]  t_a3,
        input [31:0] t_wd3,
        input [4:0]  t_a1,
        input [4:0]  t_a2,
        input [31:0] exp_rd1,
        input [31:0] exp_rd2
    );
        begin
            @(posedge clk);
            we3 <= t_we3;
            a3  <= t_a3;
            wd3 <= t_wd3;
            a1  <= t_a1;
            a2  <= t_a2;

          
            #1;            // Small delay to let asynchronous outputs settle
            
            assert (rd1 === exp_rd1 && rd2 === exp_rd2) begin
                // Silent on success during large loops to keep logs clean
            end else begin
                $error("MISMATCH! WE:%b A3:%d WD:%h | A1:%d Got RD1:%h (Exp:%h) | A2:%d Got RD2:%h (Exp:%h)",
                        we3, a3, wd3, a1, rd1, exp_rd1, a2, rd2, exp_rd2);
                error_count = error_count + 1;
            end     
            @(posedge clk);
        end
    endtask

    // 5. Test Sequence
    initial begin
        // Initialize VCD dumping
        $dumpfile("tb_sim/rf.vcd");
        $dumpvars(0, rf_tb);

        // Initialize signals & Golden Model
        clk = 0;
        we3 = 0; a1 = 0; a2 = 0; a3 = 0; wd3 = 0;
        for (i = 0; i < 32; i = i + 1) begin
            dut.rf[i]= 32'h0; 
            golden_rf[i] = 32'h0; // Assume registers clear to 0 internally or contain 0 for tracking
        end

        #10;
        $display("------- Starting Register File Directed Tests --------");

        // Directed Edge Cases (From previous stable version)
        verify_write_read(0, 5'd0, 32'h0, 5'd0, 5'd0, 32'h0, 32'h0); // Reset baseline
        verify_write_read(1, 5'd0, 32'hFFFF_FFFF, 5'd0, 5'd0, 32'h0, 32'h0); // x0 Protection

        // ==========================================================
        // 6. Constraint-Randomized Verification Loop (Icarus Friendly)
        // ==========================================================
        $display("\n--- Starting 200 Iterations of Random Testing ---");
        
        for (i = 0; i < 200; i = i + 1) begin
            // 1. Constrained generation using $urandom variables
            logic        rand_we3;
            logic [4:0]  rand_a3;
            logic [31:0] rand_wd3;
            logic [4:0]  rand_a1;
            logic [4:0]  rand_a2;
            
            logic [31:0] next_exp_rd1;
            logic [31:0] next_exp_rd2;

            // Roll the dice for inputs
            rand_we3 = $urandom_range(0, 1);       // 50% chance to write
            rand_a3  = $urandom_range(0, 31);      // Random destination address (0 to 31)
            rand_wd3 = $urandom();                 // Completely random 32-bit data
            rand_a1  = $urandom_range(0, 31);      // Random read register 1
            rand_a2  = $urandom_range(0, 31);      // Random read register 2

            // 2. Pre-calculate expected outputs using our Golden Model *before* the clock ticks
            next_exp_rd1 = (rand_a1 == 5'd0) ? 32'h0 : golden_rf[rand_a1];
            next_exp_rd2 = (rand_a2 == 5'd0) ? 32'h0 : golden_rf[rand_a2];

            // 3. Update our internal Golden Model to predict what the DUT will do on this clock cycle
            if (rand_we3 && (rand_a3 != 5'd0)) begin
                golden_rf[rand_a3] = rand_wd3;
            end

            // 4. Send the random stimuli to the verification task
            verify_write_read(rand_we3, rand_a3, rand_wd3, rand_a1, rand_a2, next_exp_rd1, next_exp_rd2);
        end

        // Final Reporting
        #20;
        $display("\n------- Verification Finished -------");
        if (error_count == 0) begin
            $display(">>>> SUCCESS: Directed + 200 Random Test Cycles Passed with 0 Errors! <<<<");
        end else begin
            $display(">>>> FAILURE: Verification complete with %d mismatches. <<<<", error_count);
        end
       
        $finish;
    end

endmodule
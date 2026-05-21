`timescale 1ns/1ps

module tb_alu;
    // Signals
    logic clk;
    logic [31:0] a, b;
    logic [3:0]  ALUControl;
    logic [31:0] y;
    logic        Zero, Neg, NegU;

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

    // 3. Driver Task (Acts as the "Driver")
    task drive(input [31:0] ta, input [31:0] tb, input [3:0] top);
        @(posedge clk);
        a <= ta;
        b <= tb;
        ALUControl <= top;
    endtask

    // 4. Monitor & Scoreboard Logic (Check results)
    always @(posedge clk) begin
        #1; // Wait for combinational logic to settle
        $display("Time:%0t | OP:%h | A:%h B:%h | Y:%h Zero:%b", 
                 $time, ALUControl, a, b, y, Zero);
        
        // Simple Scoreboard Check for ADD
        if (ALUControl == 4'b0000 && (y !== a + b)) 
            $error("ADD FAILED!");
    end

    // 5. Generator (The main test sequence)
    initial begin
        // Initialize VCD dumping
        $dumpfile("tb_sim/alu_trace.vcd");
        $dumpvars(0, tb_alu);

        // Initialize signals
        
        clk = 0;
        a = 0; b = 0; ALUControl = 0;

        $display("--- Starting Tests ---");

        // Test ADD
        drive(32'd10, 32'd5, 4'b0000);
        assert (y == (a + b)) 
    else $error("Addition failed! Expected %d, got %d", (a + b), y);

        
        // Test SUB
        drive(32'd20, 32'd8, 4'b0001);


        // Test Random cases (Icarus supports $urandom)
        repeat(5) begin
            drive($urandom, $urandom, 4'b0001); // Test 5 random SUBs
        end

        #20;
        $display("--- Tests Finished ---");
       
        $finish;
    end

endmodule
/*
Register file module for a simple CPU design. 
This module contains 32 registers, each 32 bits wide. 
It supports reading from two source registers and writing to a destination register on the rising edge of the clock.
 The register at index 0 is hardwired to zero and cannot be modified.
 

*/
module registerFile (
    input clk,
    input logic we3,             // Write enable
    input logic [4:0] a1,a2,    // Read  adresss
     input logic [4:0] a3,      // Write address
    input logic [31:0] wd3,     // Write data
    output logic [31:0] rd1,rd2   // Read data

);
    // Register array : 32 registers of 32 bits each: x0 is index 0
    logic [31:0] rf [31:0];

    // Synchronous Write: Register x0 is protected from writes
    always_ff @(posedge clk) begin
        if(we3 && (a3 != 0))
            rf[a3] <= wd3;
    end
        
    // Asynchronous Reads: Register x0 always returns 0
    assign rd1 = a1!= 0 ? rf[a1] : 0;
    assign rd2 = a2!= 0 ? rf[a2] : 0;

    
endmodule
/*

32-bit adder implementation:
* used for pc+4 
* branch target address calculation 
*/

module adder (
    input [31:0] a, b,
    output [31:0] y
);
assign y = a + b;
    
endmodule

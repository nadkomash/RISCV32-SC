/*

32-bit adder implementation:
* used for pc+4 
* branch target address calculation 
*/

module adder (
    input [31:0] in1, in2,
    output [31:0] result
);

assign result = in1 + in2;
    
endmodule

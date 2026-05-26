
/*
    *general 2-to-1 Multiplexer
*/

module  mux2to1 (
    input logic [31:0] a, b,
    input logic s,
    output logic [31:0] y
);

    assign y = s ? a : b;   

endmodule

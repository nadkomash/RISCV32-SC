
/*
    *general 2-to-1 Multiplexer
*/

module  mux2to1 (
    input logic [31:0] in0, in1,
    input logic sel,
    output logic [31:0] out
);

    assign out = sel ? in1 : in0;   

endmodule

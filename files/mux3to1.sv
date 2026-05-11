module mux3_1(
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    input [1:0] s,
    output [31:0] y
);

    assign y = (s[1]) ? c : (s[0]) ? b : a;

endmodule
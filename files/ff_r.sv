module ff_r #(parameter WIDTH = 32)
(
    input clk,
    input rst_n,
    input [WIDTH-1:0] d,
    output [WIDTH-1:0] q
);

    logic [WIDTH-1:0] q_reg;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            q_reg <= '0;
        else
            q_reg <= d;
    end

    assign q = q_reg;

endmodule
module ff_enr #(parameter WIDTH = 32)
(
    input clk,
    input rst_n,
    input en,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    logic [WIDTH-1:0] q_reg;
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            q_reg <= '0;
        else if(en)
            q_reg <= d;
    end

    assign q = q_reg;

endmodule
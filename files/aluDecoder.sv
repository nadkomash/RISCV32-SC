module alu_decoder(
    input logic [1:0] ALUOp,
    input logic [2:0] funct3,
    input logic op5,
    input logic funct7_5,
    output logic [3:0] ALUControl
);

    logic [1:0] op5func7_5_concat;
    assign op5func7_5_concat = {op5, funct7_5};

    always_comb begin
        if(ALUOp == 2'b00)
            ALUControl = 4'b0000;

        else if (ALUOp == 2'b01)
            ALUControl = 4'b0001;

        else begin
            case(funct3)
                3'b000: begin
                            if(op5func7_5_concat == 2'b00 || op5func7_5_concat == 2'b01 || op5func7_5_concat == 2'b10)
                                ALUControl = 4'b0000;
                            else if (op5func7_5_concat == 2'b11)
                                ALUControl = 4'b0001;
                        end
                3'b010:
                            ALUControl = 4'b0101;
                3'b011:
                            ALUControl = 4'b1001;
                3'b110:
                            ALUControl = 4'b0011;
                3'b111:
                            ALUControl = 4'b0010;
                3'b100:
                            ALUControl = 4'b0100;
                3'b001:
                            ALUControl = 4'b0110;
                3'b101:
                            ALUControl = funct7_5 ? 4'b1000 : 4'b0111;
                default:
                            ALUControl = 4'bxxxx;
            endcase
        end

    end
endmodule
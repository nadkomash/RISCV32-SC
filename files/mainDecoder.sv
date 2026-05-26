/*

main decoder based on Truth table from documentation.
*/
module main_decoder(
    input logic [6:0] opcode,
    output logic RegWrite,ALUSrcA,ALUSrcB,MemWrite,Branch,Jump,Jalr,
    output logic [2:0] ImmSrc,
    output logic [1:0] ResultSrc,
    output logic [1:0] ALUOp
);


      always_comb begin
        case(opcode)
            7'b0000011: //load
                {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b1, 3'b000, 1'b0, 1'b1, 1'b0, 2'b01, 1'b0,  2'b00, 1'b0, 1'b0};

            7'b0100011: //store
                 {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b0, 3'b001, 1'b0, 1'b1, 1'b1, 2'bxx, 1'b0,  2'b00, 1'b0, 1'b0};

            7'b0110011: //r-type
                {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b1, 3'bxxx, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0,  2'b10, 1'b0, 1'b0};

            7'b1100011: //branch
                {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b0, 3'b010, 1'b0, 1'b0, 1'b0, 2'bxx, 1'b1,  2'b01, 1'b0, 1'b0};

            7'b0010011: //i-type
                {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b1, 3'b000, 1'b0, 1'b1, 1'b0, 2'b00, 1'b0,  2'b10, 1'b0, 1'b0};

            7'b1101111: //jal
                {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b1, 3'b011, 1'bx, 1'bx, 1'b0, 2'b10, 1'b0,  2'bxx, 1'b1, 1'b0};

            7'b1100111: //jalr
                {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b1, 3'b000, 1'b0, 1'b1, 1'b0, 2'b10, 1'b0,  2'b00, 1'b0, 1'b1};

            7'b0010111: //Auipc
                 {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b1, 3'b100, 1'b1, 1'b1, 1'b0, 2'b00, 1'b0,  2'b00, 1'b0, 1'b0};

            7'b0110111: //lui
                 {RegWrite, ImmSrc, ALUSrcA, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump,  Jalr} = {1'b1, 3'b100, 1'b0, 1'bx, 1'b0, 2'b11, 1'b0,  2'bxx, 1'b0, 1'b0};

            default:
                {RegWrite, ImmSrc, ALUSrcB, MemWrite, ResultSrc, Branch, ALUOp, Jump, ALUSrcA, Jalr} = {1'bx, 3'bxxx, 1'bx, 1'bx, 2'bxx, 1'bx, 2'bxx, 1'bx, 1'bx, 1'bx}; 
        endcase

    end

endmodule
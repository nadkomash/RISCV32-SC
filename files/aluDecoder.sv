module alu_decoder(
    input logic [1:0] ALUOp,
    input logic [2:0] funct3,
    input logic op5,
    input logic funct7_5,
    output logic [3:0] ALUControl
);
  
  
    //Create funct2 based on op5 and funct7_5 for easier case statement.
    logic [1:0] funct2;
    assign funct2 = {op5, funct7_5};


    always_comb begin
        //00 : simple add  cases for load/store
        if(ALUOp == 2'b00)
            ALUControl = 4'b0000;

        //01 : branch case
        else if (ALUOp == 2'b01)
            ALUControl = 4'b0001;

        // 10 :  R-type and I-type cases - need to look at funct3 and funct2
        else begin
            case(funct3)
                3'b000: begin
                            if(funct2 == 2'b11)
                                ALUControl = 4'b0001; 
                            else    ALUControl = 4'b0000;   //add           
                        end
                3'b001:
                            ALUControl = 4'b0010; //slli ,sll
                3'b010:
                            ALUControl = 4'b0011; // slti ,slt   
                3'b011:
                            ALUControl = 4'b1011; // sltiu, sltu
                3'b100:
                            ALUControl = 4'b0100; // Xor, xori       

                3'b101: begin
                        if(funct2 == 2'b00 || funct2 == 2'b10) // srli, srl
                            ALUControl = 4'b0101;
                        else if (funct2 == 2'b01 || funct2 == 2'b11) // srai, sra
                            ALUControl = 4'b1101;
                        end
                3'b110:            
                            ALUControl = 4'b0110; // ori, or
                3'b111:
                            ALUControl = 4'b0111; // andi, and                          
                default:        
                            ALUControl = 4'bxxxx;
            endcase
        end

    end
endmodule
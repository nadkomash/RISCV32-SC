/*
ALUResult[31:2] = 00 -> word address
*/

module dataMemory(
    input  logic        clk, we,
    input  logic [31:0] a,     //aluresult [31:0]
    input  logic [31:0] wd,    // wd is always rs2_data
    input  logic [2:0]  Size,   // 000=SB, 001=SH, 010=SW (by funct3)
    output logic [31:0] rd
);

    //Data Memory initialization
    logic [31:0] dmem [0:63];

    always_ff @(posedge clk) begin
        //Store Opertations - handle sb/sh/sw
        if (we) begin
            case (Size)
                3'b010: begin // SW = Store word
                    dmem[a[31:2]] <= wd;
                end
                3'b001: begin // SH = Store half-word
                    case (a[1])
                        1'b0: dmem[a[31:2]][15:0]  <= wd[15:0];
                        1'b1: dmem[a[31:2]][31:16] <= wd[15:0];
                    endcase
                end
                3'b000: begin // SB = Store byte
                    case (a[1:0])
                        2'b00: dmem[a[31:2]][7:0]   <= wd[7:0];
                        2'b01: dmem[a[31:2]][15:8]  <= wd[7:0];
                        2'b10: dmem[a[31:2]][23:16] <= wd[7:0];
                        2'b11: dmem[a[31:2]][31:24] <= wd[7:0];
                    endcase
                end
            
            endcase
        end
    end

    assign rd = dmem[a[31:2]]; // word-aligned read

endmodule
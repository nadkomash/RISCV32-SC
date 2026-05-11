module loadExtensor (
    
    input  logic [31:0] ReadData,
    input  logic [1:0]  offset,
    input  logic [2:0]  MemSize,
    output logic [31:0] DataExt
);
    wire [7:0]  byte_sel = ReadData[8*offset +: 8];
    wire [15:0] half_sel = ReadData[16*offset[1] +: 16];

    wire [31:0] LB_out  = {{24{byte_sel[7]}},  byte_sel};
    wire [31:0] LH_out  = {{16{half_sel[15]}}, half_sel};
    wire [31:0] LW_out  = ReadData;
    wire [31:0] LBU_out = {24'b0, byte_sel};
    wire [31:0] LHU_out = {16'b0, half_sel};

    assign DataExt =
        (MemSize == 3'b000) ? LB_out  :
        (MemSize == 3'b001) ? LH_out  :
        (MemSize == 3'b010) ? LW_out  :
        (MemSize == 3'b100) ? LBU_out :
        (MemSize == 3'b101) ? LHU_out :
                                 32'hDEAD_BEEF; // illegal funct3
endmodule
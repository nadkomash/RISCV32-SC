# RV32I_SC

A single-cycle RISC-V RV32I core implemented in SystemVerilog,
-based on the Digital Design and Computer Architecture implementation by Harris&Harris


## Operational Documention

- PC register - contains the address if the instruction to execute.

- Instruction Memory: (data array of code)
inputs: pc 
outputs : Instruction to exectue.

- Register file: (data aray of registers)
addresses are 5 bit each. (a1,a2 sources/ a3 destination)
write enable = 1 bit (controled by RegWrite)
write data 32-bit data to write onto specific register.        
rd1,rd2 = its a register data value hence 32 bit.

- Data Memory :
inputs:
A = address 5bit
memory size = word/half word / byte 3bit
we = write enable (MemWrite Control) 1bit
wd = the data needed to be written 32bit
ouputs:
rd = data readed onto ReadData bus 32bit

- alu (needed:  alucontrol)
- alusrc mux (from regfile or signimm)
- regDst mux ??
- memtoreg mux (from dmem or from alu)
- pc+4 addeder (next instruction)
- PCbranch and shifter

- Control unit(main decoder, alu decoder)

-forward supporting jump instructions ( more muxes and shfters.)







  

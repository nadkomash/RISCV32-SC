# RV32I_SC

A single-cycle RISC-V RV32I core implemented in SystemVerilog,
-based on the Digital Design and Computer Architecture implementation by Harris&Harris


## Operational Documention

- PC register - contains the address if the instruction to execute.
  
-Instruction Memory: (data array of code)
inputs: pc 
outputs : Instruction to exectue.

- Register file: (data aray of registers)
addresses are 4 bit each. (a1,a2,a3) of source/destination
write enable = 1 bit
write data 32-bit data to write onto specific register.        
rd1,rd2 = its a register data value hence 32 bit.

-Data Memory :
inputs:A = address

  

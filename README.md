# PUnC
Microprocessor design capstone project (Verilog) with working FPGA implementation. Collaboration with Jonathan Pollock.

The PUnC (16-bit processor) implements a basic, pared-down version of the LC-3 ISA. The datapath and controller were designed by us, to accommodate a provided memory unit and register file. The datapath is sketched in a .pdf file in this directory.

Our assembly program calculates the difference of squares between the values a and b, inputted by the user. The calculation begins by verifying that a is greater than b, otherwise it exits. It then calculates the squares of both a an b, and then subtracts them, storing the final value in the output register for the user to access. Our program demonstrates the functionality of the PUnC process while also being simple for a user to understand, making it an ideal testing program. Our commented and annotated code is in this directory.

ECE382-Lab1 MSP430 Assembly Calculator
======================================

##Purpose
The purpose of this lab is to demonstrate how basic calculator functionality can be programmed into the MSP430G2553 using assembly programming. This lab requires an understanding of MSP430 Instruction Set Architecture, Memory Addressing, and Operations.

##Prelab

###Software Flowchart
![alt text](https://github.com/jniquette/ECE382-Lab1/blob/master/images/Lab1%20Software%20Flow%20Chart.png "Software Flowchart")



##Observations
Through a little bit of trial and error I observed how to properly utilize constants. I noticed that constants declared in the assembly code weren't actually being stored in memory or a register, so I came to the conclusion and verified that they are interpreted by the compiler. I also learned that in order to read a byte array from ROM, one must create a pointer to that byte array and then move through the array byte by byte because it isn't possible to change a memory address of data stored in ROM.
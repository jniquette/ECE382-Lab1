ECE382-Lab1 MSP430 Assembly Calculator
======================================

##Purpose
The purpose of this lab is to demonstrate how basic calculator functionality can be programmed into the MSP430G2553 using assembly programming. This lab requires an understanding of MSP430 Instruction Set Architecture, Memory Addressing, and Operations.

##Prelab

###Software Flowchart
![alt text](https://github.com/jniquette/ECE382-Lab1/blob/master/images/software_flowchart.png "Original Software Flowchart")

###Modifications to Original Design
While writing and modifying the code I noticed two items that I needed to change a couple items in order to get the code to meet the specifications required. The first is that I wasn't going to store just one answer (the final answer), but emulate a basic four-function calculator which shows the running total after each calculation. Therefore I needed to increment the RAM_POINTER after every operation so that the running total was displayed.

Secondly, since the CLR_OP Operation doesn't have a second operand, I moved its corresponding cmp and jeq statements before the program reads the second operand. This came after I noticed that the first operand after a CLR_OP was going missing.

The following flowchart shows the modified sequence of events.
![alt text](https://github.com/jniquette/ECE382-Lab1/blob/master/images/software_flowchart2.png "Modified Software Flowchart")

##Code
All code for this project can be found in code/main.asm.

##Testing Methodology
The INPUT Constant was set to each of the required test cases, the code was built, and the debug started. Before stepping through the debug process, the RAM was cleared from 0x0200 to 0x0300 so that it would be easy to see where the results were stored. For each test case I stepped through the program and matched my hand calculations to those that appeared in the results section of RAM.

##Test Cases
###Required Functionality
Input: 0x11, 0x11, 0x11, 0x11, 0x11, 0x44, 0x22, 0x22, 0x22, 0x11, 0xCC, 0x55

Expected Result: 0x22, 0x33, 0x00, 0x00, 0xCC

Actual Result: 0x22, 0x33, 0x00, 0x00, 0xCC

Analysis: The code worked as expected.

###B Functionality
Input: 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0xDD, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x22, 0xFD, 0x55

Expected Result: 0x22, 0x33, 0x44, 0xFF, 0x00, 0x00, 0x00, 0x02

Actual Result: 0x22, 0x33, 0x44, 0xFF, 0x00, 0x00, 0x00, 0x02

Analysis: The code worked as expected.

###A Functionality
Input: 0x22, 0x11, 0x22, 0x22, 0x33, 0x33, 0x08, 0x44, 0x08, 0x22, 0x09, 0x44, 0xff, 0x11, 0xff, 0x44, 0xcc, 0x33, 0x02, 0x33, 0x00, 0x44, 0x33, 0x33, 0x08, 0x55

Expected Result: 0x44, 0x11, 0x88, 0x00, 0x00, 0x00, 0xff, 0x00, 0xff, 0x00, 0x00, 0xff

Actual Result: 0x44, 0x11, 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0xff, 0xff, 0x00, 0xff

Analysis: The code worked only for the Add, Subtract, and Clear Operations. I believe that the issue with the multiply operation is that it is incorrectly marking all results as overflows, and thus producing an answer of 0xff.

##Observations
Through a little bit of trial and error I learned how to properly utilize constants. I noticed that constants declared in the assembly code weren't actually being stored in memory or a register, so I came to the conclusion and verified that they are interpreted by the compiler. I also learned that in order to read a byte array from ROM, one must create a pointer to that byte array and then move through the array byte by byte because it isn't possible to change a memory address of data stored in ROM.

##Documentation Statement
Nothing to report.
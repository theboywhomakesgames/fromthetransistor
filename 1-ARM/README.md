# ARM
I'm trying to come up with a step by step implementation plan to create an ARM processor in verilog. I will edit this document as I implement the processor myself to keep it accurate and make sure it works.


The most important PDF file in this directory would be ARMsoc.pdf. It's a book from Steve Furber. I'm not sure if I'm violating the copy-right by sharing it. Just let me know Steve if you don't want your book to be shared like this :D. I'll just remove it and write the essential information for this project in this readme instead.


## 1- Memory
Code a memory of any sort. It should be 32-bit addressable and little endian.


## 2- Basic Modules
These should be implemented before getting to the next part. They form the foundation for our computer.


### 1- Code the basic gates
### 2- Code the ALU
### 3- Code a clock generator


## 3- Pipeline
To implement a pipeling we need to know how many stages we have. For simplicity we'll assume 3. The following modules should be implemented for a 3-stage pipeline:

- The Register Bank
	- two read ports & one write port
	- an additional read and write port for r15(pc)

- The Barrel Shifter
- The ALU
- The Address Register & Incrementer (selecs and holds memory addresses and generates sequential addresses)
- The Data Register (data passing to/from memory)


## 4- Instruction Decoder
- Arithmetic Operations:
	ADD
	ADC
	SUB
	SBC
	RSB
	RSC


- Bitwise Logical Operations:
	AND
	ORR
	EOR
	BIC


- Multiplies
	MUL (special rules)
	MLA


- Register Movement Operations:
	MOV
	MVN


- Comparison Operations
	CMP
	CMN
	TST
	TEQ


- Shift Operations
	LSL
	LSR
	ASL
	ASR
	ROR
	RRX


- Register Indirect Addressing
	- LDR r0, [r1]
	- Adding immediate or register offset to base


- Pre-indexed Addressing [r1, #4], [r1, #4]! (auto-indexing), (post-indexing)


- Control Flow Instructions
	- B Label
	- BEQ, BNE, BPL, ... (Table 3.2, page 75, ARMsoc.pdf)


- Set Condition Operations


- Conditional Execution (page 76, ARMsoc.pdf)


- Immediate Value Handling


- Shifted Operand Handling


- Data Transfer Instructions
	- Single Register load/store -- LDRB
	- Multiple Register load/store -- LDMIA (Auto indexing available) (complex T-T)
	- Single Register Swap


- BL, return (p77)


- Block Copy Addressing (page 72 - ARMsoc.pdf)


- Supervisor Calls (p78)


- ++
	- Jump Tables (p78)


- Stack Instructions
	- STMFD, LDMFD, ...

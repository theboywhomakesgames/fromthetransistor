# ARM
I'm trying to come up with a step by step implementation plan to create an ARM processor in verilog. I will edit this document as I implement the processor myself to keep it accurate and make sure it works.


The most important PDF file in this directory would be ARMsoc.pdf. It's a book from Steve Furber. I'm not sure if I'm violating the copy-right by sharing it. Just let me know Steve if you don't want your book to be shared like this :D. I'll just remove it and write the essential information for this project in this readme instead.


## 1- Pipeline
The first step would be to create a simple pipeline as suggested by George. To do that we need to :


### 1- Code the basic gates
### 2- Code the ALU
### 3- Code a simple memory
### 4- Code a clock generator
### 5- Code the Instruction Set
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


- Set Condition Operations
- Immediate Value Handling
- Shifted Operand Handling

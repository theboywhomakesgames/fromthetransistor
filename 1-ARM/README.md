# ARM
I'm trying to come up with a step by step implementation plan to create an ARM processor in verilog. I will edit this document as I implement the processor myself to keep it accurate and make sure it works.


The most important PDF file in this directory would be ARMsoc.pdf. It's a book from Steve Furber. I'm not sure if I'm violating the copy-right by sharing it. Just let me know Steve if you don't want your book to be shared like this :D. I'll just remove it and write the essential information for this project in this readme instead.


## Warning
All page numbers mentioned in this document are pdf page numbers. The ones shown in the pdf viewer and not the ones on the actual pages as they're quite different.


## 1- Memory
Code a memory of any sort. It should be 32-bit addressable and little-endian (or not!).


## 2- Basic Modules
These should be implemented before getting to the next part. They form the foundation for our computer.


### 1- Code the basic gates
### 2- Code the ALU
- Implement the ARM6 carry-select adder (p101).
- Inverters (p102)
- Logic Functions
- Result Mux
- Zero Detect
- Make sure you have all the io signals implemented for the ALU


### 3- Code a clock generator
A 2-phase non-overlapping clock generator. This 2-phase clock is used in 2 sets of latches. Some of them are open duren phase 1 and some during phase 2. The clock is non-overlapping (we have some time between the phases in which no latches are open) so that there is no race conditions. (p97)


## 3- Pipeline Modules
To implement a pipeling we need to know how many stages we have. For simplicity we'll assume 3. The following modules should be implemented for a 3-stage pipeline:

- The Register Bank (p108)
	- two read ports & one write port
	- an additional read and write port for r15(pc)
![image](https://user-images.githubusercontent.com/25264657/173862313-d5caf317-a00f-441f-ae51-d21cc59f3b02.png)

- The Barrel Shifter (p103) (Must work without a clock | Combinational)
- The Address Register & Incrementer (selecs and holds memory addresses and generates sequential addresses)
- The Data Register (data passing to/from memory)
- High-speed Multiplier (p105)
- Datapath Layout (p109)

![image](https://user-images.githubusercontent.com/25264657/173847176-cb8f33a2-661d-4ccc-9d91-3489fc413bb2.png)
![image](https://user-images.githubusercontent.com/25264657/173847504-a6ef4371-21b8-485b-a200-d06147609e13.png)

As a ++, one can turn this into a 5-stage pipeline with data forwarding and stuff.


A 3-stage pipeline will include:
1- Fetch
2- Decode
3- Execute


Each of which should have seperate independent hardware.


## 4- Datapath Timing
### 1- Phase 1 goes high: 
- Selected registers discharge the *read buses which become valid in phase 1*.
- One operand is passed through barrel shifter and shifter's output is available shortly after
- *ALU input latches are open during phase 1*


### 2- Phase 1 goes low:
- *ALU input latches close* so that the read bus precharge doesn't go through (precharge?!)


### 3- Phase 2:
- *ALU destination latches are open in phase 2*
- ALU processes the operands. A valid output will be available towards the end of the phase


## 5- Instruction Decoder
The pipeline procedures are in page 93 of ARMsoc.pdf. PLA in p110.


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


## 6- Exceptions / Privileged mode / etc.

all: fatdrvce.bin

fatdrvce.bin: fatdrvce.asm
	fasmg fatdrvce.asm fatdrvce.bin

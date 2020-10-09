;@DOES move 9 bytes from HL to OP1
_Mov9ToOP1:
	ld de,fsOP1
	ld bc,9
	ldir
	ret

;@DOES move 8 bytes from HL to DE
_Mov8b:
	ld bc,8
	ldir
	ret

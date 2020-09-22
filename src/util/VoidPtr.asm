;@DOES Set a block of memory to zeroes
;@INPUT DE = pointer to memory
;@INPUT BC = number of bytes to zero
;@OUTPUT BC=0, DE+=BC, HL=$FF0000+BC
util_VoidPtr:
	ld hl,$FF0000
	ldir
	ret


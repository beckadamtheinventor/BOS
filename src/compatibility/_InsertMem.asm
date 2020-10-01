;@DOES insert HL bytes into userMem at address DE
;@NOTE this currently ignores DE and just moves the top of usermem forward HL bytes
_InsertMem:
	ld de,(top_of_UserMem)
	add hl,de
	ld (top_of_UserMem),hl
	ret

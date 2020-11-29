;@DOES insert HL bytes into userMem at address DE
;@INPUT hl = bytes to insert
;@OUTPUT hl = new top of UserMem
;@NOTE this currently ignores DE and just moves the top of usermem forward HL bytes
_InsertMem:
	ex hl,de
	ld hl,(remaining_free_RAM)
	or a,a
	sbc hl,de
	ld (remaining_free_RAM),hl
	ld hl,(top_of_UserMem)
	add hl,de
	ld (top_of_UserMem),hl
	ret

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
	ex hl,de
	ld de,(top_of_UserMem)
	add hl,de
	ld (top_of_UserMem),hl
	ex hl,de
	ld a,3
	sub a,e
	and a,3
	ret z
	inc de
	dec a
	jr z,.set
	inc de
	dec a
	jr z,.set
	inc de
	dec a
.set:
	ld (top_of_UserMem),de
	ret

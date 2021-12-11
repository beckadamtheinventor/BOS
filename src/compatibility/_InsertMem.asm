;@DOES insert HL bytes into userMem at address DE
;@INPUT hl = bytes to insert
;@OUTPUT hl = new top of UserMem
;@NOTE resets usermem area if de = usermem
_InsertMem:
	ex hl,de
	push bc
	ld bc,ti.userMem
	or a,a
	sbc hl,bc
	call z,.reset_usermem
	pop bc
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

.reset_usermem:
	ld (top_of_UserMem),bc
	ld bc,libload_bottom_ptr - ti.userMem
	ld (remaining_free_RAM),bc
	ret

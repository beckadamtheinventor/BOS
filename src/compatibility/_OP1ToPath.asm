;@DOES Convert a variable name from OP1 into a BOS filesystem path.
;@INPUT OP1 variable type byte, 8 byte name
;@OUTPUT hl = path
;@OUTPUT Cf set if failed
_OP1ToPath:
	ld hl,9+4
	push hl
	call sys_Malloc
	pop bc
	ret c
	push hl
	ex hl,de
	ld b,8
	ld hl,fsOP1+1
.copy_name_loop:
	ld a,(hl)
	or a,a
	jq z,.done_copying_name
	inc hl
	ld (de),a
	inc de
	djnz .copy_name_loop
.done_copying_name:
	ld c,0
	ld b,c
	ex hl,de
	ld (hl),'.'
	inc hl
	ld (hl),'v'
	inc hl
	ex hl,de
	ld a,(fsOP1)
	rrca
	rrca
	rrca
	rrca
	and a,$F
	ld hl,str_HexChars
	ld c,a
	add hl,bc
	ldi
	ld a,(fsOP1)
	ld c,0
	and a,$F
	ld c,a
	ld hl,str_HexChars
	add hl,bc
	ldi
	xor a,a
	ld (de),a
	pop hl
	ret


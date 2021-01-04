;@DOES Convert a variable name from OP1 into a BOS filesystem path.
;@INPUT OP1 variable type byte, 8 byte name
;@OUTPUT hl = path
;@OUTPUT Cf set if failed
_OP1ToPath:
	ld hl,9+4+str_tivars_dir.len
	push hl
	call sys_Malloc
	pop bc
	ret c
	push hl
	ex hl,de
	ld hl,str_tivars_dir
	ldir
	ld bc,8
	ld hl,fsOP1+1
	push de
	ldir
	pop hl
	xor a,a
	cpir
	dec hl
	ld (hl),'.'
	inc hl
	ld (hl),'v'
	inc hl
	ex hl,de
	ld bc,0
	ld a,(fsOP1)
	rrca
	rrca
	rrca
	rrca
	and a,$F
	ld hl,str_HexChars
	ld c,a
	add hl,bc
	ex hl,de
	ldi
	ex hl,de
	ld a,(fsOP1)
	ld c,a
	and a,$F
	ld hl,str_HexChars
	add hl,bc
	ex hl,de
	ldi
	ex hl,de
	ld (hl),b
	pop hl
	ret


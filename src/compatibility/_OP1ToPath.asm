;@DOES Convert a variable name from OP1 into a BOS file name.
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
	add a,'0'
	cp a,'9'+1
	jr c,.under_A
	add a,7 ; distance between '9' and 'A'
.under_A:
	ld (de),a
	inc de
	ld a,(fsOP1)
	and a,$F
	add a,'0'
	cp a,'9'+1
	jr c,.under_A_2
	add a,7 ; distance between '9' and 'A'
.under_A_2:
	ld (de),a
	inc de
	xor a,a
	ld (de),a
	pop hl
	ret


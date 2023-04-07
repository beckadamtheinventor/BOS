;@DOES run a routine in RAM.
;@INPUT ix routine to execute.
;@NOTE routine must begin with two-byte length of routine
sys_ExecuteInRAM:
	push af
	push hl
	push de
	push bc
	lea hl,ix
	mlt bc
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ex hl,de
	ld hl,$D18C7C
	or a,a
	sbc hl,bc
	ex hl,de
	push de
	ldir
	pop ix
	pop bc
	pop de
	pop hl
	pop af
	jp (ix)

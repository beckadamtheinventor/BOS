
;@DOES Raise C to E, modulus M, storing to A
;@INPUT bos_u64_t *math_u64PowMod(bos_u64_t *A, bos_u64_t *C, bos_u64_t *E, bos_u64_t *M);
math_u64PowMod:
	call ti._frameset0
	ld de,(ix+6)
	xor a,a
.set_buffer_loop:
	ld (de),a
	inc de
	djnz .set_buffer_loop
	ld hl,(ix+15)
	ld a,(hl)
	dec a
	jq nz,.M_not_one
	ld b,7
.check_M_loop:
	inc hl
	or a,(hl)
	jq nz,.M_not_one
	djnz .check_M_loop
	jq .return
.M_not_one:
	ex hl,de
	ld (hl),1
	
	
.return:
	ld hl,(ix+6)
	pop ix
	ret
	

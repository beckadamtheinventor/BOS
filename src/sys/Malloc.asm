;@DOES Allocate memory
;@INPUT void *sys_Malloc(size_t amt);
;@OUTPUT hl = malloc'd bytes. hl = -1 if failed to malloc
;@OUTPUT Cf set if failed to malloc
;@DESTROYS All
sys_Malloc:
	pop bc
	pop hl
	push hl
	push bc
	ld de,16384
	or a,a
	sbc hl,de
	jq nc,.fail
	or a,a
	adc hl,de
	jq z,.fail
	ld de,(remaining_free_RAM)
	or a,a
	ex hl,de
	sbc hl,de
	jq c,.fail
	ld (remaining_free_RAM),hl
	ld b,6
	xor a,a
.shift_loop:
	rr d
	rr e
	adc a,a
	djnz .shift_loop
	or a,a
	jq z,.exact_fit
	inc de
.exact_fit:
	push de
	ld hl,malloc_cache
	ld de,4
	ld c,e
	ld b,d
.loop:
	ld a,(hl)
	or a,a
	jq z,.found
	add hl,de
	djnz .loop
	dec c
	jq nz,.loop
	pop bc
.fail:
	scf
	sbc hl,hl
	ret
.found:
	ld (ScrapMem),hl
	add hl,de
	pop de
	push de
.len_loop:
	ld a,(hl)
	or a,a
	jq nz,.not_found
	inc hl
	inc hl
	inc hl
	inc hl
	ex hl,de
	dec hl
	or a,a
	add hl,de
	sbc hl,de
	ex hl,de
	jq nz,.len_loop
	pop bc
	ld hl,(ScrapMem)
	ld de,-malloc_cache
	add hl,de
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,bottom_of_malloc_RAM
	add hl,de
	ex hl,de
	ld hl,(ScrapMem)
	ld (hl),de
	pop bc
	push bc
	push de
	ld b,c
	ld de,$7FFFFF
.mark_loop:
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld (hl),e
	inc hl
	djnz .mark_loop
	pop hl
	ret
.not_found:
	ld hl,(ScrapMem)
	add hl,de
	jq .loop


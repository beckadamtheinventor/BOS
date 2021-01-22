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
	ld de,8192
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
	ld bc,32
	call ti._idvrmu
	ld a,l
	or a,h
	jq z,.exact_fit
	inc de
.exact_fit:
	push de
	ld hl,malloc_cache
	ld bc,32 ;b = 0, c = 32. Loop 32*256 times.
.loop:
	ld a,(hl)
	adc a,a
	jq nc,.found
.skip_block:
	inc hl
	ld a,(hl)
	cp a,$7F
	jq nz,.loop
	djnz .skip_block
	dec c
	jq nz,.skip_block
	pop bc
.fail:
	scf
	sbc hl,hl
	ret
.found:
	ld (ScrapMem),hl
	pop de
	push de
.len_loop:
	ld a,(hl)
	adc a,a
	jq c,.loop
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
	add hl,hl
	ld de,bottom_of_malloc_RAM
	add hl,de
	ex hl,de
	ld hl,(ScrapMem)
	ld (hl),$FF
	inc hl
	pop bc
	push bc
	push de
	ld b,c
	dec b
	jq c,.one_block
.mark_loop:
	ld (hl),$7F
	inc hl
	djnz .mark_loop
.one_block:
	pop hl
	ret


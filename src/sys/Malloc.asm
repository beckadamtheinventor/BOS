;@DOES Allocate memory
;@INPUT void *sys_Malloc(size_t amt);
;@OUTPUT hl = malloc'd bytes. hl = 0 if failed to malloc
;@OUTPUT Cf set if failed to malloc
;@DESTROYS All
sys_Malloc:
	pop bc
	pop hl
	push hl
	push bc
.entryhl:
	add hl,de
	or a,a
	sbc hl,de
	jq z,.fail ; can't malloc 0 bytes
	ld bc,malloc_block_size
	call ti._idvrmu ; size to malloc / 32
	ld a,l
	or a,h
	jq z,.exact_fit
	inc de
.exact_fit:
	ld hl,malloc_cache
	ld bc,malloc_cache_len
	push de
.loop:
	xor a,a
	cpir
	jq z,.checklen
	pop hl ; fail if no 0x00 (free blocks) found
.fail:
	or a,a
	sbc hl,hl
	scf
	ret
.checklen:
	dec hl
	ld (ScrapMem),hl
	pop de
	push de
	dec de
	ld a,e
	or a,d
	jq z,.found_enough
	inc hl
.len_loop:
	ld a,(hl)
	or a,a
	jq nz,.loop
	cpi
	dec de
	ld a,e
	or a,d
	jq nz,.len_loop

.found_enough:
	ld hl,(ScrapMem)
	ld de,-malloc_cache
	add hl,de ; get offset from malloc_cache
repeat malloc_block_size_bits
	add hl,hl ; multiply by malloc_block_size
end repeat
	ld de,bottom_of_malloc_ram ;index malloc ram with offset*32
	add hl,de
	ex hl,de
	ld hl,(ScrapMem)
	ld a,(running_process_id)
	ld (hl),a
	inc hl

	pop bc
	dec bc
	ld a,b
	or a,c
	ex hl,de
	ret z
	ex hl,de
.mark_loop:
	ld (hl),$FF
	inc hl
	dec bc
	ld a,b
	or a,c
	jq nz,.mark_loop
	ex hl,de
	ret


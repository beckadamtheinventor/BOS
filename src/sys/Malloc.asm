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
	ld a,l
	and a,-1-(malloc_block_size-1)
	ld l,a
	ld c,malloc_block_size_bits
	call ti._ishru ; size to malloc / malloc_block_size
	inc hl
	push hl
	ld hl,malloc_cache
	ld bc,malloc_cache_len
.loop:
	xor a,a
	cpir
	jq z,.checklen
	; fail if no 0x00 (free blocks) found
.fail:
	or a,a
	sbc hl,hl
	scf
	ret
.checklen:
	dec hl
	ld (ScrapMem),hl
	pop de ; restore number of blocks to malloc
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
.return_and_mark_cache_hl:
	ld de,-malloc_cache
	add hl,de ; get offset from malloc_cache
repeat malloc_block_size_bits
	add hl,hl ; multiply by malloc_block_size
end repeat
	ld de,bottom_of_malloc_ram ;index malloc ram with offset*malloc_block_size
	add hl,de
	ex hl,de
	ld hl,(ScrapMem)
	ld a,(running_process_id)
	ld (hl),a
	inc hl

	pop bc ; pop number of blocks to malloc off the stack
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


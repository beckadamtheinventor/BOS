;@DOES Free as block of memory malloc'd by sys_Malloc
;@INPUT void sys_Free(void *ptr);
;@OUTPUT Cf set if failed.
;@DESTROYS All
sys_Free:
	pop bc,hl
	push hl,bc
.entryhl:
	ld de,bottom_of_malloc_ram
	or a,a
	sbc hl,de ; ptr - bottom_of_malloc_RAM
	ret c
	ld bc,top_of_malloc_ram - bottom_of_malloc_ram
	sbc hl,bc
	ccf
	ret c
	add hl,bc
	ld c,malloc_block_size_bits
	call ti._sshru
	ld bc,malloc_cache ; index the malloc cache
	add hl,bc ; hl now points to 8-bit malloc cache entry
assert ~malloc_cache and $FF
	ld (hl),c
	ld bc,malloc_cache + malloc_cache_len
.loop2:
	inc hl
	ld a,(hl)
	inc a
	or a,a ; make sure the carry flag is unset
	ret nz
	ld (hl),a
	sbc hl,bc
	add hl,bc
	jr c,.loop2
	ret


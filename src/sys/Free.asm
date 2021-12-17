;@DOES Free as block of memory malloc'd by sys_Malloc
;@INPUT void sys_Free(void *ptr);
;@DESTROYS All
sys_Free:
	pop bc,hl
	push hl,bc
.entryhl:
	ld de,bottom_of_malloc_RAM
	or a,a
	sbc hl,de ;ptr - bottom_of_malloc_RAM
	ret c
	ld bc,65536
	sbc hl,bc
	ccf
	ret c
	add hl,bc
	ld bc,32
	call ti._idivu
	ld de,malloc_cache ;index the malloc cache
	add hl,de ;hl now points to 8-bit malloc cache entry
	ld bc,malloc_cache+4096
	ld (hl),c
	inc hl
	dec bc
.loop2:
	ld a,(hl)
	inc a
	ret nz
	ld (hl),a
	dec bc
	sbc hl,bc
	add hl,bc
	jq c,.loop2
	ret


;@DOES Free as block of memory malloc'd by sys_Malloc
;@INPUT void sys_Free(void *ptr);
;@DESTROYS All
sys_Free:
	pop bc,de
	push de,bc
	ld hl,-bottom_of_malloc_RAM
	add hl,de ;ptr - bottom_of_malloc_RAM
	ld bc,32
	call ti._idivu
	ld de,malloc_cache ;index the malloc cache
	add hl,de ;hl now points to 8-bit malloc cache entry
.loop2:
	ld (hl),$FF
	ret


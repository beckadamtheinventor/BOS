;@DOES Free as block of memory malloc'd by sys_Malloc
;@INPUT void sys_Free(void *ptr);
;@DESTROYS All
sys_Free:
	pop bc,de
	push de,bc
	ld hl,-bottom_of_malloc_RAM
	add hl,de ;ptr - bottom_of_malloc_RAM
	ld a,h    ;(ptr - bottom_of_malloc_RAM) >> 4
	ld b,4
.loop:
	rra
	rr l
	djnz .loop
	and a,$F
	ld h,a    ;hl = (ptr - bottom_of_malloc_RAM) >> 4
	ld a,l
	and a,$FC ;and off the last two bits
	ld l,a
	ld de,malloc_cache ;index the malloc cache
	add hl,de ;hl now points to 32-bit malloc cache entry
	ld b,4
.loop2:
	ld (hl),e
	inc hl
	djnz .loop2
	ret

;@DOES Free all memory malloc'd by sys_Malloc
;@INPUT void sys_FreeAll(void);
;@DESTROYS hl, de
sys_FreeAll:
	ld hl,top_of_RAM
	ld (free_RAM_ptr),hl
	ld hl,top_of_RAM - bottom_of_malloc_RAM
	ld (remaining_free_RAM),hl
	ld hl,malloc_cache
	ld de,malloc_cache+1
	ld bc,$1000 ;4096
	ld (hl),c
	ldir
	ld hl,argument_stack_top
	ld (argument_stack_current),hl
	ret

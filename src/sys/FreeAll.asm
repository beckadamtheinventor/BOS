;@DOES Free all memory malloc'd by sys_Malloc
;@INPUT void sys_FreeAll(void);
;@DESTROYS All
sys_FreeAll:
	ld hl,top_of_RAM
	ld (free_RAM_ptr),hl
	ret

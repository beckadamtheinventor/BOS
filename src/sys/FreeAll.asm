;@DOES Free all memory malloc'd by sys_Malloc
;@INPUT void sys_FreeAll(void);
;@DESTROYS hl
sys_FreeAll:
	ld hl,top_of_RAM
	ld (free_RAM_ptr),hl
	ld hl,argument_stack_top
	ld (argument_stack_current),hl
	ret

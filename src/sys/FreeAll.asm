;@DOES Free all memory malloc'd by sys_Malloc
;@INPUT void sys_FreeAll(void);
;@DESTROYS hl, de
sys_FreeAll:
	ld hl,malloc_cache   ;clear out the malloc cache
	ld de,malloc_cache+1
	ld bc,malloc_cache_len-1
if ~malloc_cache and $FF
	ld (hl),l
else
	ld (hl),0
end if
	ldir
	ret

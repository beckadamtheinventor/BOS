;@DOES Allocate 32 bytes of memory, 32-byte aligned.
;@INPUT void *sys_Malloc32Align32(void);
;@OUTPUT hl = malloc'd bytes. hl = 0 if failed to malloc
;@OUTPUT Cf set if failed to malloc
;@DESTROYS All
sys_Malloc32Align32:
	ld de, (32/malloc_block_size) shl 8 or (32/malloc_block_size - 1)
	jr sys_Malloc64Align256.entry

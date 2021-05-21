;@DOES Allocate 32 bytes of memory, 32-byte aligned.
;@INPUT void *sys_Malloc32Align32(void);
;@OUTPUT hl = malloc'd bytes. hl = 0 if failed to malloc
;@OUTPUT Cf set if failed to malloc
;@DESTROYS All
;@NOTE BOS's memory allocation is already 32-byte aligned
sys_Malloc32Align32:
	ld bc,32
	push bc
	call sys_Malloc
	pop bc
	ret

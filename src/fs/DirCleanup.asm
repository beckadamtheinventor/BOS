
;@DOES Re-allocate a directory, removing deleted entries
;@INPUT void fs_DirCleanup(void *fd);
fs_DirCleanup:
	pop bc,hl
	push hl,bc
	
	ret


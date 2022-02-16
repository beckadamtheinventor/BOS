
;@DOES Allocates and writes a long file name, initializing the descriptor with a pointer to the name.
;@INPUT void fs_CreateLongFileName(void *tmpfd, const char *name);
fs_CreateLongFileName:
	call ti._frameset0
	ld hl,(ix+9)
	push hl
	call ti._strlen
	push hl
	call fs_AllocSmall
	pop bc,hl
	call sys_FlashUnlock
	call sys_WriteFlash
	call sys_FlashLock
	
	ld hl,(ix+6)
	
	pop ix
	ret

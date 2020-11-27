
;@DOES delete a file given a file descriptor
;@INPUT bool fs_DeleteFile(void *fd);
;@OUTPUT true if success, otherwise fail
fs_DeleteFile:
	call ti._frameset0
	ld de,(ix+6)
	ld hl,.deleted_header
	ld bc,8+3 ;clear 8.3 file name but leave attribute byte and data position/length data
	push bc,hl,de
	call sys_WriteFlashFull
	pop bc,bc,bc
	pop ix
	ret
.deleted_header:
	db fsentry_deleted, 7+3 dup 0


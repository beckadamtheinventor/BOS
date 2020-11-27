
;@DOES update a file's header given a file descriptor
;@INPUT bool fs_UpdateFileHeader(void *fd, void *new_header);
;@OUTPUT true if success, otherwise fail
fs_UpdateFileHeader:
	call ti._frameset0
	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,8+3+1 ;update 8.3 file name and attribute byte
	push bc,hl,de
	call sys_WriteFlashFull
	pop bc,bc,bc
	pop ix
	ret


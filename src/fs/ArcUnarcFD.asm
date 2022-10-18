; swap a file between flash<->ram
; input void *fs_ArcUnarcFD(void *fd);
; return new file descriptor (copy) or -1 if failed.
fs_ArcUnarcFD:
	ld hl,str_ram_fs_device
	push hl
	call fs_OpenFile
	pop bc
	ret c
	call sys_OpenDevice.entryhl
	ret c
	
	
	ret

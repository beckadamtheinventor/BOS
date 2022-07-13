
;@DOES Create a directory given a path and return a file descriptor.
;@INPUT void *fs_CreateDir(const char *path, uint8_t flags);
;@OUTPUT file descriptor. Returns 0 if failed to create directory. 
fs_CreateDir:
	ld de,fs_directory_size ;size of directory section
;.entry_de:
	ld hl,3
	add hl,sp
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	ld l,(hl)
	push de,hl,bc
	call fs_CreateFile
	pop bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret z
	push hl
	call sys_FlashUnlock
	call fs_GetFDPtr
	ld bc,fs_directory_size - fs_file_desc_size
	add hl,bc
	ex hl,de
	ld a,$FE
	call sys_WriteFlashA
	call sys_FlashLock
	pop hl
	ret


;@DOES Create a file linking to an existing file given a path and file descriptor, returning a new file descriptor.
;@INPUT void *fs_CreateLink(const char *path, void *fd);
;@OUTPUT file descriptor. Returns 0 if failed to create link.
fs_CreateLink:
	ld hl,-19
	call ti._frameset
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq z,.fail
	cp a,' '
	jq z,.fail
	push hl
	call fs_AbsPath
	ex (sp),hl
	call fs_OpenFile
	jq nc,.fail ;fail if file exists
	call fs_ParentDir
	ld (ix-3),hl
	ex (sp),hl
	call fs_OpenFile
	jq c,.fail ;fail if parent dir doesn't exist
	ex (sp),hl
	pop iy
	bit fsbit_subdirectory,(iy+fsentry_fileattr)
	jq z,.fail ;fail if parent dir is not a dir
	lea de,ix-19
	push iy,hl,de
	call fs_StrToFileEntry
	pop bc,bc,iy
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld de,16
	add hl,de
	push iy,hl
	ld hl,flashStatusByte
	set bKeepFlashUnlocked,(hl)
	call sys_FlashUnlock
	call fs_SetSize ;resize parent directory up 16 bytes
	jq c,.fail
	ld iy,(ix+9)
	ld a,(iy+fsentry_fileattr)
	ld (ix + fsentry_fileattr - 19), a     ;setup new file descriptor contents
	ld hl,(iy+fsentry_filesector)
	ld (ix + fsentry_filesector - 19),hl
	ld hl,(iy+fsentry_filelen)
	ld (ix + fsentry_filelen - 19),l
	ld (ix + fsentry_filelen+1 - 19),h
	pop bc,iy

	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld bc,-32 ;write 32 bytes behind the new end of file, to overwrite the end of directory marker
	add hl,bc
	push hl,iy
	ld bc,16
	push bc
	ld c,1
	push bc
	pea ix-19
	call fs_Write ;write new file descriptor to parent directory
	pop bc,bc,bc,iy,bc

	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld bc,-16 ;write 16 bytes behind the new end of file to write new end of directory marker
	add hl,bc
	push hl,iy
	ld bc,16
	push bc
	ld c,1
	push bc
	ld bc,$03FFF0
	push bc
	call fs_Write ;write new file descriptor to parent directory
	pop bc,bc,bc,iy,bc

	ld hl,flashStatusByte
	res bKeepFlashUnlocked,(hl)
	call sys_FlashLock
	ld hl,(ix+6)
	push hl
	call fs_OpenFile ; get pointer to new file descriptor
	pop bc
	db $01
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret


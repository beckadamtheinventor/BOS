;@DOES Create a file given a path and return a file descriptor.
;@INPUT void *fs_CreateFile(const char *path, uint8_t flags, int len);
;@OUTPUT file descriptor. Returns 0 if failed to create file.
fs_CreateFile:
	ld hl,-19
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-3),hl
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq z,.fail
	cp a,' '
	jq z,.fail
	push hl
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
	push iy
	ld hl,(ix+6)
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	dec hl
	ld a,'/'
	cp a,(hl)
	jq nz,.doesntendwithslash
	dec hl
	dec bc
.doesntendwithslash:
	cpdr
	inc hl
	jq nz,.doesntstartwithslash
	inc hl
.doesntstartwithslash:
	push hl
	pea ix-19
	call fs_StrToFileEntry
	pop bc,bc,iy
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld de,16
	add hl,de
	push iy,hl
	call fs_SetSize ;resize parent directory up 16 bytes
	jq c,.fail
	ld hl,(ix+12)
	ld (ix + fsentry_filelen - 19),l
	ld (ix + fsentry_filelen+1 - 19),h
	push hl
	call fs_Alloc ;allocate space for new file
	jq c,.fail
	pop bc,bc,iy

	ld a, (ix+9)
	ld (ix + fsentry_fileattr - 19), a     ;setup new file descriptor contents
	ld (ix + fsentry_filesector - 19),l
	ld (ix + fsentry_filesector+1 - 19),h

	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld bc,-32 ;write 32 bytes behind the new end of file, to overwrite the end of directory marker
	add hl,bc
	push hl,iy
	ld bc,1
	push bc
	ld c,16
	push bc
	pea ix-19
	call fs_Write ;write new file descriptor to parent directory
	pop bc,bc,bc,iy,bc

	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld bc,-16 ;write 16 bytes behind the new end of file to write new end of directory marker
	add hl,bc
	push hl,iy
	ld bc,1
	push bc
	ld c,16
	push bc
	ld bc,$03FFF0
	push bc
	call fs_Write ;write new file descriptor to parent directory
	pop bc,bc,bc,iy,bc

	ld hl,(ix+6)
	push hl
	call fs_OpenFile ; get pointer to new file descriptor
	pop bc
	db $01
.fail:
	xor a,a
	sbc hl,hl
	push hl,af
	ld hl,(ix-3)
	push hl
	call sys_Free
	pop bc,af,hl
	ld sp,ix
	pop ix
	ret

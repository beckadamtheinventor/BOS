;@DOES Create a file linking to an existing file given a path and file descriptor, returning a new file descriptor.
;@INPUT void *fs_CreateLink(const char *path, const void *fd);
;@OUTPUT file descriptor. Returns 0 if failed to create link.
fs_CreateLink:
	ld hl,-16
	call ti._frameset
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	jq nc,.fail ;fail if file exists
	call fs_BaseName
	push hl
	pea ix-16
	call fs_StrToFileEntry
	pop bc
	call sys_Free ; free the memory allocated by fs_BaseName

; copy sector, length, and attribute data from file descriptor to new link descriptor
	ex (sp),iy ; save iy
	ld iy,(ix+9) ; const void *fd
	ld hl, (iy + fsentry_filesector) ; 16 bit sector and low 8 bits of length
	ld e, (iy + fsentry_filelen + 1) ; high 8 bits of length
	ld (ix + fsentry_filesector - 16), hl
	ld (ix + fsentry_filelen + 1 - 16), e
	ld a,(iy + fsentry_fileattr)
	set fd_link, a ; set file as a link file (contents of linked file are preserved when the link is deleted)
	ld (ix + fsentry_fileattr - 16), a

	ld iy,(ix+6) ; const char *path
	ex (sp),iy ; restore iy, push link file path
	call fs_ParentDir
	ex (sp),hl
	call fs_GetFilePtr
	ex (sp),hl
	push hl
	call sys_Free ; free the memory allocated by fs_ParentDir
	pop bc,hl
	call fs_AllocDescriptor.entry ; allocate a descriptor for the link file
	call sys_FlashUnlock
	ex hl,de
	lea hl,ix-16
	ld bc,fs_file_desc_size ; write the descriptor in full
	push de
	call sys_WriteFlash
	call sys_FlashLock
	pop hl ; descriptor of created link file
	db $01 ; dummify xor a,a / sbc hl,hl
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret


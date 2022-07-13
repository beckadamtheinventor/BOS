;@DOES Create a file entry (uninitialized) given a path and return a file descriptor.
;@INPUT void *fs_CreateFileEntry(const char *path, uint8_t flags);
;@OUTPUT file descriptor. Returns 0 if failed to create file.
fs_CreateFileEntry:
	ld hl,-22
	call ti._frameset
	ld (ix-22),iy
	xor a,a
	sbc hl,hl
	ld (ix-3),hl
	ld hl,(ix+6)
	or a,(hl)
	jq z,.fail
	cp a,' '
	jq z,.fail
	push hl
	call fs_OpenFile
	jq nc,.fail ; fail if file exists
.dontfail:
	call fs_ParentDir
	ld (ix-3),hl
	ex (sp),hl
	call fs_OpenFile
	jq c,.fail   ; fail if parent dir doesn't exist
	; ex (sp),hl
	; pop iy
	; bit fsbit_subdirectory,(iy+fsentry_fileattr)
	; jq z,.fail ;fail if parent dir is not a dir
	; ld hl,(ix+6)
	; push hl
	ld hl,(ix+6)
	ex (sp),hl
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
	jq c,.fail
	ld a,(ix-19)
	sub a,fsentry_longfilename
	or a,a ; make sure Cf is unset
	call z,fs_CreateLongFileName
	jq c,.fail
	pop bc,bc


	ld a, (ix+9)
	ld (ix + fsentry_fileattr - 19), a     ; setup new file descriptor flag byte

	ld hl,(ix-3)
	push hl
	call fs_GetFilePtr
	pop bc
.write_descriptor:
	call fs_AllocDescriptor.entry
	call sys_FlashUnlock
	ex hl,de
	lea hl,ix-19
	ld bc,fsentry_filesector ; only write up until and including attribute byte
	push de
	call sys_WriteFlash
	pop hl
	db $01
.fail:
	xor a,a
	sbc hl,hl
	push hl,af
	ld hl,(ix-3)
	call sys_Free.entryhl
	pop af,hl
	call sys_FlashLock
	ld iy,(ix-22)
	ld sp,ix
	pop ix
	ret


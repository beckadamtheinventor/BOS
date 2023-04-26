;@DOES Create a file entry (uninitialized) given a path and return a file descriptor.
;@INPUT void *fs_CreateFileEntry(const char *path, uint8_t flags);
;@OUTPUT file descriptor. Returns 0 if failed to create file.
fs_CreateFileEntry:
	ld hl,-28
	call ti._frameset
	ld (ix-22),iy
	xor a,a
	sbc hl,hl
	ld (ix-3),hl
	ld hl,(ix+6)
	; or a,(hl)
	; jq z,.fail
	; cp a,' '
	; jq z,.fail
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
	ld (ix-25),hl
	push hl
	pea ix-19
	call fs_StrToFileEntry
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
	ld (ix-28),hl
	call sys_FlashUnlock
	ex hl,de
	lea hl,ix-19
	ld bc,fsentry_fileattr + 1 ; only write up until and including attribute byte
	push de
	call sys_WriteFlash

	ld a,(ix-19)
	cp a,fsentry_longfilename
	jr nz,.dont_write_long_file_name

	ld a,(ix+1-19) ; first byte of first long file name entry is the number of extra entries needed to store the file name
	or a,a
	jr z,.dont_write_long_file_name
	ld hl,(ix-25)
	ld bc,9
	add hl,bc
	ld (ix-25),hl
.write_long_file_name_loop:
	push af
	ld hl,(ix-28)
	call fs_AllocDescriptor.entry
	jr c,.fail
	ld (ix-28),hl
	ex hl,de
	ld a,fsentry_longfilename_entry
	call sys_WriteFlashA
	ld bc,15
	ld hl,(ix-25)
	add hl,bc
	ld (ix-25),hl
	or a,a
	sbc hl,bc
	call sys_WriteFlash
	pop af
	dec a
	jr nz,.write_long_file_name_loop

.dont_write_long_file_name:
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


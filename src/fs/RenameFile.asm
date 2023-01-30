;@DOES rename a file
;@INPUT void *fs_RenameFile(const char *directory, const char *old_name, const char *new_name);
;@OUTPUT file descriptor. returns zero if failed
fs_RenameFile:
	ld hl,-22
	call ti._frameset
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	jq c,.fail
	ld (ix-22),hl ; save parent directory descriptor
	ld hl,(ix+9)
	ex (sp),hl
	call fs_OpenFileInDir
	jq c,.fail
	ld hl,(ix+12)
	ex (sp),hl
._entry: ; make sure to enter with (sp) = new file name
	lea de,ix+fsentry_fileattr-19
	ld hl,(ix-3) ; old file descriptor
	ld bc,fsentry_fileattr ; copy old file descriptor attribute byte, sector address, and length
	add hl,bc
	ld c,5
	ldir
	pea ix-19
	call fs_StrToFileEntry
	call sys_FlashUnlock
	pop hl,bc
	ld hl,(ix-22) ; parent dir descriptor
	call fs_GetFDPtr.entry
	call fs_AllocDescriptor.entry
	ex hl,de
	lea hl,ix-19
	ld bc,16
	push de
	call sys_WriteFlash
	ld de,(ix-3)
	xor a,a
	call sys_WriteFlashA
	call sys_FlashLock
	pop hl
	db $01 ; dummify xor a / sbc hl
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret


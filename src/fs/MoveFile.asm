;@DOES Move a file given paths and return a file descriptor.
;@INPUT void *fs_MoveFile(const char *src, const char *dest);
;@OUTPUT file descriptor of destination file. Returns 0 if failed.
fs_MoveFile:
	ld hl,-26
	call ti._frameset
	ld (ix-26),iy
	ld hl,(ix+9)
	push hl
	call fs_OpenFile
	jq c,.fail
	call fs_ParentDir
	ex (sp),hl
	call fs_OpenFile
	jq nc,.fail
	ld (ix-3),hl ; save parent dir file descriptor
	ex (sp),hl
	pop iy
	bit fsbit_subdirectory,(iy+fsentry_fileattr)
	jq z,.fail ;fail if parent dir is not a dir
	ld hl,(ix+9)
	push hl
	call fs_BaseName
	jq c,.fail
	ex (sp),hl
	pea ix-20
	call fs_StrToFileEntry
	jq c,.fail
	pop bc
	call sys_Free
	ld hl,(ix+6)
	ex (sp),hl
	call fs_OpenFile
	jq c,.fail
	ld (ix-23),hl ; save pointer to source file descriptor
	ld bc,fsentry_fileattr
	add hl,bc
	ld bc,(hl) ; copy last 5 bytes from source fd to dest fd
	inc hl
	inc hl
	ld hl,(hl)
	ld (ix+fsentry_fileattr-20),bc
	ld (ix+fsentry_fileattr+2-20),hl
	call fs_ParentDir
	jq c,.fail
	ex (sp),hl
	call fs_GetFilePtr ; get source parent directory pointer and length
	jq c,.fail
	push bc ; push old length
; overwrite the old file descriptor
	add hl,bc
	ld bc,(ix-23)  ;get offset of file's descriptor to delete from end of parent directory file
	or a,a
	sbc hl,bc ;hl is end of directory - file descriptor
	push hl ;hl is number of bytes to copy down
	ld bc,(ix-23)
	ld hl,16
	add hl,bc ;copy down from next file descriptor to delete this one
	push hl,bc
	call sys_FlashUnlock
	call sys_WriteFlashFullRam
	call sys_FlashLock
	pop bc,bc,bc
	call fs_SetSize ; resize source parent dir down 16 bytes
	pop hl,bc

	ld iy,(ix-3) ; destination parent dir file descriptor
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld bc,-32 ;write 32 bytes behind the new end of parent directory file, appending the new entry
	add hl,bc
	push hl,iy
	ld bc,1
	push bc
	ld c,16
	push bc
	pea ix-20
	call fs_Write ;write new file descriptor to parent directory
	pop bc,bc,bc,bc,bc

	db $01
.fail:
	or a,a
	sbc hl,hl
	ld iy,(ix-26)
	ld sp,ix
	pop ix
	ret

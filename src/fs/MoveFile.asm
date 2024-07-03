;@DOES Move a file given paths and return a file descriptor.
;@INPUT void *fs_MoveFile(const char *src, const char *dest);
;@OUTPUT file descriptor of new file. Returns 0 if failed.
fs_MoveFile:
	ld hl,-9
	call ti._frameset
	ld (ix-3),iy
	ld (ix-7),0
	ld hl,(ix+9) ; dest file
	push hl
	; call fs_BaseName.entryhl
	; ld a,(hl)
	; cp a,'/'
	; jr nz,.different_dest_name
	; ld hl,(ix+6) ; source file
	; call fs_BaseName.entryhl
	; ex (sp),hl ; save source file base name, restore dest file path
	; push hl
	; call fs_JoinPath
	; pop bc
	; ld (ix-9),hl ; save dest file path joined with source base name
	; ex (sp),hl ; then pass it on as the new dest file path
; .different_dest_name:
	call fs_OpenFile
	jr nc,.fail ; fail if it exists
	ld hl,(ix+6) ; source file
	ex (sp),hl
	call fs_OpenFile
	jq c,.fail
	ld (ix-6),hl ; save source file descriptor
	ld bc,fsentry_fileattr
	add hl,bc
	ld l,(hl)
	ex (sp),hl
	ld hl,(ix+9)
	push hl
	call fs_CreateFileEntry
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail
	ld bc,fsentry_filesector
	add hl,bc
	ex hl,de
	ld hl,(ix-6)
	add hl,bc
	ld c,4
	call sys_FlashUnlock
	call sys_WriteFlash ; copy over the file size and length data
	ld de,(ix-6)
	xor a,a
	call sys_WriteFlashA ; delete the old file descriptor
	call sys_FlashLock
	db $01
.fail:
	or a,a
	sbc hl,hl
	push hl
	ld hl,(ix-9)
	call sys_Free.entryhl
	pop hl
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret

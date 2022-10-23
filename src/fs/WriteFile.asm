
;@DOES Overwrite all data stored in a file from a given data pointer.
;@INPUT int WriteFile(void *data, int len, void *fd);
;@OUTPUT New file descriptor. -1 if failed to write
fs_WriteFile:
	ld hl,-9
	call ti._frameset
	ld (ix-3),iy
	ld iy,(ix+12) ;void *fd
	bit fd_link,(iy+fsentry_fileattr)
	jq nz,.fail
	; push iy
	; call fs_CheckWritableFD
	; dec a
	; pop iy
	; jq nz,.fail
	ld hl,(ix+9)
	ld bc,65535
	or a,a
	sbc hl,bc
	jq nc,.fail
	ld hl,(ix+12)
	call fs_AllocDescriptor.entry ; allocate new file descriptor
	ld (ix-9),hl
	jq c,.fail
	ld bc,(ix+9)
	push bc
	call fs_Alloc
	jq c,.fail
	ld (ix-6),hl
	pop bc
	call sys_FlashUnlock
	ld hl,(ix+12)
	ld de,(ix-9)
	ld bc,fsentry_filesector ; copy up until file sector pointer
	call sys_WriteFlash
	ld a,(ix-6) ; low byte of file sector
	call sys_WriteFlashA
	ld a,(ix-5) ; high byte of file sector
	call sys_WriteFlashA
	ld a,(ix+9) ; low byte of file size
	call sys_WriteFlashA
	ld a,(ix+10) ; high byte of file size
	call sys_WriteFlashA
	ld hl,(ix+12)
	push hl
	call fs_DeleteFileFD ; delete and free old file descriptor and data section
	ld hl,(ix-9)
	ex (sp),hl
	call fs_GetFDPtr ; get pointer to new file data section
	pop bc
	ex hl,de
	ld hl,(ix+6) ; void *data
	ld bc,(ix+9) ; int len
	call sys_WriteFlash
	call sys_FlashLock
	ld hl,(ix-9) ; return new file descriptor
	db $01
.fail:
	scf
	sbc hl,hl
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret



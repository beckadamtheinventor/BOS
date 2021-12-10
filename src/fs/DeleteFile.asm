
;@DOES delete a file given a file name
;@INPUT bool fs_DeleteFile(const char *name);
;@OUTPUT true/nz if success, false/zf if fail
fs_DeleteFile:
	call ti._frameset0

; open the file to be deleted and check if it's writable
	ld hl,(ix+6)
	push hl
	call fs_CheckWritable
	dec a
	jq nz,.fail
	call fs_OpenFile
	push hl
	ld bc,fsentry_fileattr
	add hl,bc
	bit fd_link,(hl)
; free the file's data if it's not a link file
	call z,fs_Free
	pop de,bc
; mark the file descriptor as deleted
	call sys_FlashUnlock
	xor a,a
	call sys_WriteFlashA
	call sys_FlashLock

	db $3E ;ld a,...
.fail:
	xor a,a
	or a,a
	ld sp,ix
	pop ix
	ret


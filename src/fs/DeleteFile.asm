
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
	ex (sp),hl
;	jq c,.fail

;free the file's data
	call fs_Free
	pop de
; mark the file descriptor as deleted
	xor a,a
	call sys_WriteFlashA

	db $3E ;ld a,...
.fail:
	xor a,a
	or a,a
	pop ix
	ret



;@DOES delete a file given a file name
;@INPUT bool fs_DeleteFile(const char *name);
;@OUTPUT true if success, otherwise fail
fs_DeleteFile:
	call ti._frameset0
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	pop bc
	jq c,.fail
	ld bc,fsentry_fileattr
	add hl,bc
	bit fsbit_readonly,(hl)
	jq nz,.fail
	ld de,(ix+6)
	ld hl,.deleted_header
	ld bc,8+3 ;clear 8.3 file name but leave attribute byte and data position/length data
	push bc,hl,de
	call sys_WriteFlashFull
	pop bc,bc,bc
	db $3E ;ld a,...
.fail:
	xor a,a
	or a,a
	pop ix
	ret
.deleted_header:
	db fsentry_deleted, 7+3 dup 0



;@DOES delete a file given a file name
;@INPUT bool fs_DeleteFile(const char *name);
;@OUTPUT true if success, otherwise fail
fs_DeleteFile:
	pop bc,hl
	push hl,bc
	push hl
	call fs_OpenFile
	pop bc
	jq c,.fail
	push hl
	ld bc,fsentry_fileattr
	add hl,bc
	bit fsbit_readonly,(hl)
	pop de
	jq nz,.fail
	ld c,fsentry_deleted ;mark file as deleted
	push bc,de
	call sys_WriteFlashByteFull
	pop bc,bc
	db $3E ;ld a,...
.fail:
	xor a,a
	or a,a
	ret


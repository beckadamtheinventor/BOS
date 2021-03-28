
;@DOES Clears the read-only flag of a given file
;@INPUT int fs_ClearReadOnlyFlag(const char *path);
;@NOTE Used to update read-only files and directories on OS update
;@OUTPUT hl = -1 and Cf set if failed
fs_ClearReadOnlyFlag:
	pop bc,hl
	push hl,bc
	push hl
	call fs_OpenFile
	pop bc
	ret c
	ld bc,fsentry_fileattr
	add hl,bc
	ld a,(hl)
	bit fsbit_readonly,a
	ret z
	res fsbit_readonly,a
	ex hl,de
	jp sys_WriteFlashA



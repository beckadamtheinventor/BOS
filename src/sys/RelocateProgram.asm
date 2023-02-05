
;@DOES Relocate an RFX format executable into flash
;@INPUT void *sys_RelocateProgram(const char *path);
;@OUTPUT file descriptor of relocated program, -1 and Cf set if failed.
sys_RelocateProgram:
	pop bc,hl
	push hl,bc
	push hl
	call fs_OpenFile
	call c,sys_OpenFileInPath
	pop bc
	ret c
	jq sys_RelocateProgramFD.entryhl


;@DOES execute a file given a pointer to it's data section
;@INPUT int sys_ExecuteFileFromPtr(void *ptr, char *args);
;@OUTPUT -1 if file is not a valid executable format
;@DESTROYS All, OP6.
sys_ExecuteFileFromPtr:
	pop bc
	pop hl
	pop de
	push de
	push hl
	push bc
.entryhlde:
	ld (fsOP6),de
	ld (fsOP6+3),hl
	jq sys_ExecuteFile.exec_check_loop

;@DOES Print a string to stdout
;@INPUT void gui_PrintStdout(const char* str);
;@NOTE Writes to stdout, which can be the default text printer or a file.
gui_PrintStdout:
	pop bc,hl
	push hl,bc
.entryhl:
	ex hl,de
	ld hl,(stdout_fd_ptr)
	add hl,de
	or a,a
	sbc hl,de
	ex hl,de
	jq z,gui_PrintString
	push hl,de
	call fsd_WriteStr
	pop bc,bc
	ret


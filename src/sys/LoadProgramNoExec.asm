
;@DOES Load a program without running it.
;@INPUT sys_LoadProgramNoExec(const char *path);
;@OUTPUT HL = pointer to loaded program executable code.
;@DESTROYS All, OP5, OP6.
sys_LoadProgramNoExec:
	ld a,1
	ld (fsOP5+10),a
	jq sys_ExecuteFile.__entry


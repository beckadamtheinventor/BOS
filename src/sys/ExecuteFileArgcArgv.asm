
;@DOES execute a file given a file path, passing arguments via argc/argv.
;@INPUT int sys_ExecuteFileArgcArgv(const char *path, int argc, char *argv[]);
;@DESTROYS All, OP6.
sys_ExecuteFileArgcArgv:
	ld hl,9
	ld a,l
	add hl,sp
	ld (fsOP5+10),a
	ld de,(hl)
	ld (fsOP5),de
	inc hl
	inc hl
	inc hl
	ld de,(hl)
	ld (fsOP6),de
	jq sys_ExecuteFile.__entry


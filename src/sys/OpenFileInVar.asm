
;@DOES open a file, looking in directories from var variable if file not found
;@INPUT void *sys_OpenFileInVar(const char *path, const char *var);
;@OUTPUT pointer to file descriptor
sys_OpenFileInVar:
	ld hl,-15
	call ti._frameset
	ld hl,(ix+9)
	jq sys_OpenFileInPath.entryhl

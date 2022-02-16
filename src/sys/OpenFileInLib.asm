
;@DOES open a file, looking in directories listed in /var/LIB.
;@INPUT void *sys_OpenFileInLib(const char *path);
;@OUTPUT pointer to file descriptor
sys_OpenFileInLib:
	ld hl,-15
	call ti._frameset
	ld hl,string_lib_var
	jq sys_OpenFileInPath.entryhl

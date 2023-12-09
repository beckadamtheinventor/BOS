
;@DOES open a file, looking in directories listed in /var/LIB.
;@INPUT void *sys_OpenFileInLib(const char *path);
;@OUTPUT pointer to file descriptor
sys_OpenFileInLib:
	ld hl,-12
	call ti._frameset
	ld hl,string_lib_var
	push hl
	call fs_GetFilePtr
	pop de
	jr nc,.not_default
; if we failed to locate file "/var/LIB", use the default lib data
	ld hl,str_DefaultLibVarData
	ld bc,str_DefaultLibVarData.len
.not_default:
	jq sys_OpenFileInPath.entry_hlbc

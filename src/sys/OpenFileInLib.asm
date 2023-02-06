
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
	jq nc,sys_OpenFileInPath.entry_hlbc
; if we failed to locate file "/var/LIB", use the default lib directory "/lib"
	ld bc,(ix+6)
	ld de,str_lib_dir
	push bc,de
	call fs_JoinPath
	pop bc
	ex (sp),hl
	call fs_OpenFile
	ex (sp),hl
	push af
	call sys_Free.entryhl
	pop af,hl
	ret

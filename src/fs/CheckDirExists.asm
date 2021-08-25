;@DOES check if a directory exists.
;@INPUT bool fs_CheckDirExists(char *path);
;@OUTPUT true if path exists, else false
fs_CheckDirExists:
	pop bc
	pop hl
	push hl
	push bc
	push hl
	call fs_OpenFile
	pop bc
	ccf
	sbc a,a
	ret

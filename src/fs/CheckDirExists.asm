;@DOES check if a directory exists.
;@INPUT bool fs_CheckDirExists(char *path);
;@OUTPUT true if path exists, else false
;@NOTE uses InputBuffer and fsOP6
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


;@DOES execute a file from a given entry point
;@INPUT int sys_ExecuteFileEntryPoint(char *path, char *args);
;@OUTPUT -1 if file does not exist or is not a valid executable format
;@NOTE entry point is essentially "file.whatever/entry.point/whatever"
sys_ExecuteFileEntryPoint:
	scf
	sbc hl,hl
	ret

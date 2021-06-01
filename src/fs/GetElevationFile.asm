
;@DOES open and return a pointer to OS elevation file.
;@NOTE returns Cf and HL = -1 if it doesn't exist. Returns elevation file path in DE
fs_GetElevationFile:
	ld hl,string_os_elevation_file
	push hl
	call fs_GetFilePtr
	pop de
	ret

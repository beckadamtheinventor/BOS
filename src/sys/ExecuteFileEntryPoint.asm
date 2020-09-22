
;@DOES execute a file from a given entry point
;@INPUT hl = file path appended with path of entry point.
;@NOTE entry point is essentially "file.whatever/entry.point/whatever"
sys_ExecuteFileEntryPoint:
	call fs_OpenFile
	
	ret

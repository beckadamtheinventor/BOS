
;@DOES execute an executable file from a path.
;@INPUT hl = path
sys_ExecuteFile:
	call fs_OpenFile
	
	ret

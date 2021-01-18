;@DOES delete a file in the /usr/tivars/ directory
;@INPUT OP1 = type byte, 8 byte name of var to delete
;@OUTPUT Cf set if failed
;DESTROYS All
_DelVar:
	call _OP1ToPath
	ret c
	push hl
	call fs_DeleteFile
	ex (sp),hl
	push af,hl
	call sys_Free
	pop bc,af,hl
	ret




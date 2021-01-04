;@DOES delete a file in the /dev/tivars/ directory
;@INPUT OP1 = type byte, 8 byte name of var to delete
;@OUTPUT Cf set if failed
;DESTROYS All
_DelVar:
	call _OP1ToPath
	ret c
	push hl
	call fs_DeleteFile
	pop bc
	ret




;@DOES create a file in the /dev/tivars/ directory
;@INPUT OP1 = type byte, 8 byte name of var to create
;@INPUT hl = length to allocate for file
;@OUTPUT Cf set if failed
;DESTROYS All
_CreateVar:
	push hl
	call _OP1ToPath
	pop bc
	ret c
	push bc,hl
	call fs_OpenFile
	pop hl,bc
	ccf
	ret c
	ld e,0
	push bc,de,hl
	call fs_CreateFile
	ex (sp),hl
	pop hl,de,bc
	ret c
	push hl,bc
	call fs_SetSize
	pop bc,hl
	ret




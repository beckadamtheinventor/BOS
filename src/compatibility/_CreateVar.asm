;@DOES create a file in the /usr/tivars/ directory
;@INPUT OP1+1 = 8 byte name of var to create
;@INPUT A = var type
;@INPUT hl = length to allocate for file
;@OUTPUT Cf set if failed
;DESTROYS All
_CreateVar:
	push hl
	ld (fsOP1),a
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
	push hl
	call sys_Free
	pop bc,hl,de,bc
	ret




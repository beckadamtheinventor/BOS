;@DOES Search for a TI variable in the "/usr/tivars/" directory
;@INPUT OP1 1 byte var type, 8 byte file name
;@OUTPUT HL = pointer to 2 byte file length
;@OUTPUT DE = pointer to file data
;@OUTPUT Cf set if file not found or otherwise cannot be opened.
;@DESTROYS OP4,OP5
_ChkFindSym:
	call _OP1ToPath
	push hl
	call fs_OpenFile
	pop bc
	push af,hl,bc
	call sys_Free
	pop bc,hl,af
	ret c

	ld bc,fsentry_filesector ;file pointer
	add hl,bc
	ld bc,(hl)
	push hl,bc
	call fs_GetSectorAddress
	ex hl,de
	pop bc,hl
	inc hl
	inc hl
	or a,a
	ret


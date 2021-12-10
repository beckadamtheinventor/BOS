_CreateString:
	ld a,ti.StrngObj
	jq _CreateVar
_CreateProg:
	ld a,ti.ProgObj
	jq _CreateVar
_CreateProtProg:
	ld a,ti.ProtProgObj
	jq _CreateVar
_CreateAppVar:
	ld a,ti.AppVarObj
	jq _CreateVar





;@DOES create a file in the /usr/tivars/ directory
;@INPUT OP1+1 = 8 byte name of var to create
;@INPUT A = var type
;@INPUT hl = length to allocate for file
;@OUTPUT hl = pointer to 2 byte file length, de = pointer to file data section
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
	pop bc,de,bc,bc
	ld hl,fsentry_filelen
	add hl,de
	push hl,de
	call fs_GetFDPtr
	ex hl,de
	pop bc,hl
	or a,a
	ret




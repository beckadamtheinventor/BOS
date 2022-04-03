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





;@DOES create a ram file in the /tivars/ directory
;@INPUT OP1+1 = 8 byte name of var to create
;@INPUT A = var type
;@INPUT hl = length to allocate for file
;@OUTPUT hl = pointer to 2 byte file length, de = pointer to file data
;@OUTPUT Cf set and HL = -1 if failed
;DESTROYS All
_CreateVar:
	ld (fsOP1),a
	call fs_AllocVar
	ret c
	push bc,hl
	call _OP1ToAbsPath
	ld c,0
	push bc,hl
	call fs_CreateRamFile
	pop hl
	push af,hl
	call sys_Free
	pop bc,af,bc,hl,bc
	push hl
	pop de
	ret nc
	sbc hl,hl
	ret

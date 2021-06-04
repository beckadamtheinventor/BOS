
	jr _writeinto
	db "FEX",0
_writeinto:
	ld hl,(bos.LastCommandResult)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail ;fail if 0
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail ;fail if -1
	pop bc,hl
	push hl,bc,hl
	call bos.fs_OpenFile
	pop de
	ld bc,0
	jq nc,.overwritefile
	ld hl,(bos.LastCommandResult)
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push bc,hl
	ld c,0
	push bc,de
	call bos.fs_WriteNewFile
	pop bc,bc,bc
	push af,bc
	call bos.sys_Free
	pop bc,af,bc
	sbc hl,hl
	ret ;previous routine returns what we want to return
.overwritefile:
	ex hl,de
	ld hl,(bos.LastCommandResult)
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push hl,de,bc
	call bos.fs_SetSize
	pop bc,de,hl
	push de,bc,hl
	call bos.fs_WriteFile
	add hl,bc
	or a,a
	sbc hl,bc
	pop hl
	push af,hl
	call bos.sys_Free
	pop hl,af,bc,de
	jq z,.fail
	xor a,a
	db $3E ;dummify following scf
.fail:
	scf
	sbc hl,hl
	ret


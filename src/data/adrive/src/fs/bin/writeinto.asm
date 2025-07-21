
	jr _writeinto
	db "FEX",0
_writeinto:
	call ti._frameset0
	ld hl,(bos.LastCommandResult)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail ;fail if 0
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail ;fail if -1
	syscall _argv_1
	push hl
	call bos.fs_OpenFile
	call nc,bos.fs_DeleteFile
	pop de
	mlt bc
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
	db $3E ; ld a,...
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret


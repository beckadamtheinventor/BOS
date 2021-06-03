
	jr _echo_exe
	db "FEX",0
_echo_exe:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	or a,a
	jq z,.fail
	push hl
	call bos.sys_VarString
	pop bc
	ret c
	push hl
	call bos.gui_PrintLine
	call ti._strlen
	inc hl
	inc hl
	push hl
	call bos.sys_Malloc
	pop bc,de
	ret c
	push hl
	dec bc
	dec bc
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ex hl,de
	push hl
	ld a,c
	or a,b
	jq z,.dontcopy
	ldir
.dontcopy:
	call bos.sys_Free
	pop bc
	pop hl
	ret
.fail:
	scf
	sbc hl,hl
	ret


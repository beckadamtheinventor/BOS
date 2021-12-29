
	jr _echo_exe
	db "FEX",0
_echo_exe:
	call ti._frameset0
	ld hl,bos.return_code_flags
	set bos.bSilentReturn,(hl)
	call osrt.argv_1
	ld a,(hl)
	or a,a
	jr z,.fail
	push hl
	call bos.sys_VarString
	pop bc
	jr c,.fail
	push hl
	call bos.gui_PrintLine
	call ti._strlen
	inc hl
	inc hl
	push hl
	call bos.sys_Malloc
	pop bc,de
	jr c,.fail
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
	db $01
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret


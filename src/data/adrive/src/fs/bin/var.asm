	jq var_main
	db "FEX",0
var_main:
	ld hl,-9
	call ti._frameset
	
	ld hl,(ix+6)
	call osrt.grab_var_name
	ld (ix-3),hl
	ld de,(ix+6)
	or a,a
	sbc hl,de
	inc hl
	push hl
	call bos.sys_Malloc
	jq c,.fail
	pop bc
	dec bc
	ex hl,de
	ld hl,(ix+6)
	xor a,a
	ldir
	ld (de),a
	
	or a,a
.fail:
	sbc hl,hl
	ld sp,ix
	pop ix
	ret


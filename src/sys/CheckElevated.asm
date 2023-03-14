; returns z if not currently in elevated mode
sys_CheckElevated:
	push hl,bc
	ld hl,$3F0000
	ld c,l
	mlt bc
.loop:
	ld a,(hl)
	inc a
	jr z,.fail
	inc a
	jr z,.success
	dec bc
	inc hl
	djnz .loop
.success:
	db $F6 ; dummify and a,0 opcode byte. argument byte is a nop
.fail:
	and a,0
	pop bc,hl
	ret


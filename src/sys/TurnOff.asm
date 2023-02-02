
;@DOES turns off the calculator until the on key is pressed.
sys_TurnOff:
	im 1 ; jump to $000038 upon an interrupt
	ld a,(ti.mpLcdCtrl)
	cp a,ti.lcdBpp16
	push af
	di
	call ti.boot.TurnOffHardware
	di
	ld bc,$5005
	in a,(bc)
	push af
	res 5,a
	out (bc),a
	ld bc,$3114
	in a,(bc)
	set 0,a
	out (bc),a
	di
	in0 a,($01)
	push af
	call ti.boot.Set6MHzMode
	ld bc,$3030
	xor a,a
	out (bc),a
	ld bc,$3114
	inc a
	out (bc),a
	ld bc,ti.pKeyRange
assert ~ti.pKeyRange and $FF
	out (bc),c
	out0 ($2C),c
	out0 ($05),c
	out0 ($06),c
	ld b,$FC
	in0 a,($0F)
	add a,a ; check bit 7 is zero
	jr nc,.case1
	add a,a ; check bit 6 is non-zero
	jr c,.case1
	inc b
	ld c,$05
.case1:
	out0 ($0C),c
	out0 ($0A),b
	ld b,$0D
	out0 ($0D),b
	ld b,a
	djnz $

	call .routine1
	ld c,a
	in a,(bc)
.wait3:
	in e,(bc)
	cp a,e
	jr nz,.wait3

	ld c,$04
	in d,(bc)
	ld c,$08
	in a,(bc)
	inc a
	cp a,$18
	jr c,.case2
	; ld hl,ti.apdTimer
	; set 7,(hl)
	xor a,a
.case2:
	ld c,$10
	out (bc),e
	ld c,$14
	out (bc),d
	ld c,$18
	out (bc),a

	call .routine1
	ld c,$20
	in a,(bc)
	res 2,a
	or a, 1 shl 3 or 1 shl 5
	out (bc),a
	ld c,$34
	ld a,$FF
	out (bc),a
	
	in0 a,($09)
	res 0,a
	or a,$E6
	out0 ($09),a
	ld a,$FF
	out0 ($07),a
	
	ld bc,$500E
	in a,(bc)
	set 3,a
	out (bc),a
	ld c,$04
	xor a,a
	out (bc),a
	inc c
	out (bc),a
	inc c
	ld a,$08
	out (bc),a
	inc c
	xor a,a
	out (bc),a
	ld c,$08
	dec a
	out (bc),a
	inc c
	out (bc),a
	inc c
	out (bc),a
	inc c
	out (bc),a

	exx
	ld a,$C0
	out0 ($00),a
	ex af,af'
	ei
	halt
	nop
	; in0 a,($02)
	; bit 3,a
	ld a,$0F
	out0 ($0D),a
.wait4:
	in0 a,($0D)
	inc a
	jr nz,.wait4
	ld b,a
	ld a,$76
	out0 ($05),a
	ld a,$03
	out0 ($06),a
	djnz $

	ld bc,$3114
	inc a
	out (bc),a
	ld bc,$5008
	out (bc),a
	ld c,$04
	set 0,a
	out (bc),a
	ld a,b
	call ti.boot.InitializeHardware
	pop af
	out0 ($01),a
	pop af
	ld bc,$5005
	out (bc),a
	pop af
	jp z,gfx_Set16bpp
	jp gfx_Set8bpp

.routine1:
	ld bc,$8040
.wait1:
	in a,(bc)
	jr nz,.wait1
	inc c
.wait2:
	in a,(bc)
	jr nz,.wait2
	ret

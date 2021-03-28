
	jq turn_off_main
	db "FEX",0
turn_off_main:
	call ti.boot.TurnOffHardware
	ld hl,ti.mpIntMask
	set ti.bIntOn,(hl)
	ld l,ti.intAck
	set ti.bIntOn,(hl)
	in0 a,($00)
	set 6,a
	out0 ($00),a
	ld hl,(bos.on_interrupt_handler)
	ld (bos.fsOP6),hl
	ld hl,.boot
	ld (bos.on_interrupt_handler),hl
	ei
	halt
	nop
	xor a,a
	sbc hl,hl
	ret
.boot:
	ld hl,(bos.fsOP6)
	ld (bos.on_interrupt_handler),hl
	call ti.boot.InitializeHardware
	ld iy,$D00080
	res 6,(iy+$1B)
	pop hl
	pop iy,ix
	exx
	db $08 ;ex af,af'
	ei
	reti


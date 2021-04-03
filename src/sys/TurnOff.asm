
;@DOES turns off the calculator until the on key is pressed.
sys_TurnOff:
	di
	call ti.boot.TurnOffHardware
	ld hl,(on_interrupt_handler)
	ld (fsOP6),hl
	ld hl,.boot
	ld (on_interrupt_handler),hl
	in0 a,($00)
	set 6,a
	out0 ($00),a
	ei
	nop
	nop
	ld hl,ti.mpIntMask
	set ti.bIntOn,(hl)
	ei
	halt
	nop
	ld hl,(fsOP6)
	ld (on_interrupt_handler),hl
	xor a,a
	sbc hl,hl
	ret
.boot:
	call ti.boot.InitializeHardware
	ld hl,return_from_interrupt
	ld (on_interrupt_handler),hl
	jq return_from_interrupt

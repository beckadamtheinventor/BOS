
	jq turn_off_main
	db "FEX",0
turn_off_main:
	call ti.boot.TurnOffHardware
	call .wait
	call .wait
	jp ti.boot.InitializeHardware
.wait:
	di
	ld hl,ti.mpIntMask
	set ti.bIntOn,(hl)
	ld l,ti.intAck
	set ti.bIntOn,(hl)
	ei
	halt
	nop
	ret


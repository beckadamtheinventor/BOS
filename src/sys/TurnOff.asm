
;@DOES turns off the calculator until the on key is pressed.
sys_TurnOff:
	di
	call ti.boot.TurnOffHardware
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
	rst 0

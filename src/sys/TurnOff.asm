
;@DOES turns off the calculator until the on key is pressed.
sys_TurnOff:
	ld a,(ti.mpLcdCtrl)
	cp a,ti.lcdBpp16
	push af
	di
	call ti.boot.TurnOffHardware
	in0 a,($00)
	set 6,a
	out0 ($00),a
	ld bc,(ti.mpIntMask)
	push bc
	ld a,ti.intOn
	ld (ti.mpIntMask),a
	ei
	halt
	nop
	pop bc
	ld (ti.mpIntMask),bc
	in0 a,($00)
	res 6,a
	out0 ($00),a
	; rst 0
	call ti.boot.InitializeHardware
	pop af
	jp z,gfx_Set16bpp
	jp gfx_Set8bpp

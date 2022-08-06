
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
	ld a,ti.intOn
	ld (ti.mpIntMask),a
	ei
	halt
	nop
	; rst 0
	call ti.boot.InitializeHardware
	pop af
	jp z,gfx_Set16bpp
	jp gfx_Set8bpp

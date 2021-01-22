;@DOES Setup an error handler for an interrupt caused by the [On] key.
;@INPUT HL = user error handler
;@NOTE user error handler is called after the interrupt is handled.
sys_SetupOnInterruptHandler:
	ld (on_interrupt_handler+1),hl
	ld hl,ti.mpIntMask
	set ti.bIntOn,(hl)
	ret


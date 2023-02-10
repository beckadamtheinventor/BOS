;@DOES Set an error handler for an interrupt caused by the [On] key.
;@INPUT void *sys_SetOnInterruptHandler(void (*handler)(void));
;@OUTPUT Returns previous error handler.
;@NOTE user error handler is called after the interrupt is handled.
sys_SetOnInterruptHandler:
	pop bc,de
	push de,bc
.entryhl:
	ld de,(on_interrupt_handler)
	ld (on_interrupt_handler),hl
	ld hl,ti.mpIntMask
	set ti.bIntOn,(hl)
	ex hl,de
	ret


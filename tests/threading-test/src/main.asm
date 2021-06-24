include "include/ez80.inc"
include "include/ti84pceg.inc"
include "include/bos.inc"
include "include/threading.inc"

org 0

	jr init
	db "TFX",0
	db 0 ;the program should only need 32 bytes of stack
init:
	ld de,.strings
	add hl,de
	push hl
	pop ix
.loop:
	ld hl,(ix)
	lea ix,ix+3
	call bos.gui_PrintLine
	HandleNextThread

	ld a,(ix)
	or a,a
	jq nz,.loop
	ret
.strings:
	dl .s1, .s2, .s3, .s4, .s5
	db 0
.s1:
	db "Hello from the thread!",0
.s2:
	db "Again!",0
.s3:
	db "And Again!",0
.s4:
	db "4th time!",0
.s5:
	db "Final line...",0


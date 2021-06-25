include "include/ez80.inc"
include "include/ti84pceg.inc"
include "include/bos.inc"
include "include/threading.inc"

	jr init
	db "TFX",0
	db 0
init:
	ld bc,3
	push bc
	call bos.sys_Malloc
	ex (sp),hl
	pop ix
	ret c
	xor a,a
	ld (bos.last_keypress),a
	sbc hl,hl
	ld (ix),hl
.loop:
	ld hl,(ti.mpLcdUpbase)
	ld de,270
	add hl,de
	ld de,(ix)
	add hl,de
	inc de
	ld a,e
	cp a,20
	jr nz,.indexunder20
	ld e,d
.indexunder20:
	ld (ix),de
	dec hl
	ld a,(hl)
	inc hl
	ld b,9
	ld de,319
.innerloop:
	ld (hl),a
	inc hl
	ld (hl),$FF
	add hl,de
	djnz .innerloop
	HandleNextThread
	ld a,(bos.last_keypress)
	cp a,ti.skClear
	jr nz,.loop
	ret


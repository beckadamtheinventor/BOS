include "include/ez80.inc"
include "include/ti84pceg.inc"
include "include/bos.inc"
include "include/threading.inc"

org ti.userMem

	jr init
	db "REX",0
init:
	call bos.sys_NextProcessId
	ld bc,32
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	ld (.threadsp),hl
	ld bc,.thread_len
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	push hl,bc
	ld c,.threadstart - .thread
	add hl,bc
	ld (.threadpc),hl
	; ld c,.strings - .threadstart
	; add hl,bc
	; ld (.loadix),hl
	pop bc,de
	push de
	ld hl,.thread
	ldir
	jp bos.sys_PrevProcessId
.thread:
	SpawnThread 0, 0
.threadsp := $-6
.threadpc := $-3
	ret
.threadstart:
	ld bc,3
	push bc
	call bos.sys_Malloc
	ex (sp),hl
	pop ix
	jr nc,.dontendthread
	EndThread
.dontendthread:
	xor a,a
	ld (bos.last_keypress),a
	sbc hl,hl
	ld (ix),hl
.loop:
	ld hl,(ti.mpLcdUpbase)
	ld de,300
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
	call bos.sys_FreeRunningProcessId
	EndThread
.thread_len := $ - .thread

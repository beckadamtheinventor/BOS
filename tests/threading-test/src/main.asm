include "include/ez80.inc"
include "include/ti84pceg.inc"
include "include/bos.inc"
include "include/threading.inc"

org ti.userMem

	jr init
	db "REX",0
init:
	ld bc,32
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	ld (thread_a_stackbot),hl
	ld bc,32
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	ld (thread_b_stackbot),hl
	ld bc,32
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	ld (thread_c_stackbot),hl

	SpawnThread thread_a, 0
thread_a_stackbot:=$-6

	SpawnThread thread_b, 0
thread_b_stackbot:=$-6

	SpawnThread thread_c, 0
thread_c_stackbot:=$-6

	SetExitThread main_exit ;do this so we have somewhere to return after all other threads have completed
	HandleNextThread

main_exit:
	or a,a
	sbc hl,hl
	ret

thread_c:
	HandleNextThread

	call bos.sys_GetKey
	jq z,thread_c
	EndThread

thread_a:
	ld ix,.strings
.loop:
	ld hl,(ix)
	lea ix,ix+3
	call bos.gui_PrintLine
	HandleNextThread

	ld a,(ix)
	or a,a
	jq nz,.loop
	EndThread
.strings:
	dl .s1, .s2, .s3, .s4, .s5
	db 0
.s1:
	db "Hello from thread A!",0
.s2:
	db "Again from A!",0
.s3:
	db "And Again from A",0
.s4:
	db "4th time from A",0
.s5:
	db "Final line from A",0

thread_b:
	ld ix,.strings
.loop:
	ld hl,(ix)
	lea ix,ix+3
	call bos.gui_PrintLine
	HandleNextThread

	ld a,(ix)
	or a,a
	jq nz,.loop
	EndThread
.strings:
	dl .s1, .s2, .s3, .s4, .s5
	db 0
.s1:
	db "Hello from thread B!",0
.s2:
	db "Again from B!",0
.s3:
	db "And Again from B",0
.s4:
	db "4th time from B",0
.s5:
	db "Final line from B",0


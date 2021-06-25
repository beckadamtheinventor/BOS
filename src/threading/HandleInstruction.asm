
HandleInstruction:
	pop hl
	ld a,(hl)
	inc hl
	push hl
	; or a,a
	; jq z,_DisableThreading
	; cp a,$F7
	; jq z,_EnableThreading
	cp a,$C5
	jq z,_HandleThreadSpawn
	cp a,$C9
	jq z,th_EndThread
	cp a,$C1
	jq z,th_HandleNextThread
	ret

; _EnableThreading:
	; ld bc,64 ;setup gpt2
	; xor a,a
	; ld (ti.mpTmr2Load),bc
	; ld (ti.mpTmr2Load+3),a
	; ld (ti.mpTmr2Counter),bc
	; ld (ti.mpTmr2Counter+3),a
	; ld hl,ti.mpTmrCtrl
	; res ti.bTmr2Enable,(hl)
	; set ti.bTmr2Crystal,(hl)
	; set ti.bTmr2Overflow,(hl)
	; inc hl
	; res ti.bTmr2CountUp-8,(hl)
	; dec hl
	; ex hl,de
	; ld hl,thread_control      ;enable threading
	; ld (hl),l
	; ld bc,ti.pIntMask
	; in a,(bc)
	; or a,1 shl ti.bIntTmr2
	; out (bc),a
	; im 1
	; ex hl,de
	; set ti.bTmr2Enable,(hl)
	; ei
	; ret

; _DisableThreading:
	; xor a,a
	; ld (thread_control),a      ;disable threading
	; ld bc,$5004
	; in a,(bc)
	; and a,-(1 shl 2)
	; out (bc),a
	; ret

_StopAllThreads:
	ld hl,thread_map+1
	xor a,a
	ld b,$FF
.loop:
	res 7,(hl)
	inc hl
	djnz .loop
	pop hl
	dec hl
	jp (hl)

_HandleThreadSpawn:
	pop hl
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	push hl,de,bc
	call th_CreateThread
	pop bc,bc
	ret


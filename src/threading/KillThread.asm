;@DOES Kill a thread by ID, not including child threads.
;@INPUT uint8_t th_KillThread(uint8_t id);
;@OUTPUT thread ID killed if successful, 0 if failed.
;@NOTE Cannot kill thread ID 0.
th_KillThread:
	ld hl,3
	add hl,sp
	ld a,(hl)
	ld hl,thread_map
	ld l,a
	xor a,a
	cp a,l
	ret z
	; bit bThreadPersistent,(hl)
	; ret nz
	; res bThreadAlive,(hl)
	; ld a,l
	; ld l,thread_parents and $FF
; .child_loop:
	; cp a,(hl)
	; jr z,.not_child_thread
	; dec h
	; res bThreadAlive,(hl)
	; inc h
; .not_child_thread:
	; inc l
	; jr nz,.child_loop
	; or a,a
	ret



;@DOES spawn a thread
;@INPUT uint8_t th_CreateThread(void *pc, void *sp);
;@OUTPUT thread id. 0 if failed
th_CreateThread:
	db $3E ;ld a,...
.noparent:
	xor a,a
	ld e,a
	call th_FindFreeThread
	or a,a
	ret z
	ld c,a
	set bThreadAlive,(hl)
	ld a,e
	or a,a
	jr z,._dontsetparent
	ld h,$FF and (thread_parents shr 8)
	ld a,(current_thread)
	ld (hl),a
._dontsetparent:
	sbc hl,hl
	ld l,c
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,thread_temp_save
	add hl,bc
	pop iy,de,bc
	push bc,de
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld (hl),bc
	ld bc,12 - 3
	add hl,bc
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld a,(running_process_id)
	ld (hl),a
	jp (iy)


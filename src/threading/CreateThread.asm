;@DOES spawn a thread
;@INPUT uint8_t th_CreateThread(void *pc, void *sp);
;@OUTPUT thread id. 0 if failed
th_CreateThread:
	call th_FindFreeThread
	or a,a
	ret z
	set 7,(hl)
	sbc hl,hl
	ld l,a
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
	jp (iy)


;@DOES spawn a thread with a given resource access
;@INPUT uint8_t th_CreateThread(uint8_t resource_flags);
th_CreateThread:
	ld hl,thread_map
	xor a,a
	ld b,64
.loop:
	cp a,(hl)
	jq z,.spawn
	inc hl
	inc hl
	djnz .loop
	scf
	ret
.spawn:
	pop de,bc
	push bc,de
	ld (hl),$F7
	inc hl
	ld (hl),c
	ret


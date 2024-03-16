;@DOES Get the status byte of a given thread ID
;@INPUT uint8_t th_GetThreadStatus(uint8_t id);
th_GetThreadStatus:
	pop bc,hl
	push hl,bc
.entryhl:
	ld a,l
.entrya:
assert ~thread_map and $FF
	ld hl,thread_map
	ld l,a
	ld a,(hl)
	ret

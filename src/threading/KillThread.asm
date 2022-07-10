;@DOES Kill a thread by ID
;@INPUT uint8_t th_KillThread(uint8_t id);
;@OUTPUT thread ID killed if successful, 0 if failed.
th_KillThread:
	ld hl,3
	add hl,sp
	xor a,a
	ld de,thread_map
	ld e,(hl)
	bit bThreadAlive,(hl)
	ret z
	bit bThreadPersistent,(hl)
	ret nz
	res bThreadAlive,(hl)
	or a,e
	ret


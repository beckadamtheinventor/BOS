
;@DOES end all running threads and wait for there to be no more thread IDs above 1.
;@NOTE will kill all remaining threads if recovery key pressed
;@DESTROYS All, IY
th_EndAllThreads:
	ld iy,(last_keypress)
	xor a,a
	ld (last_keypress),a
	ld hl,thread_map+2
	ld b,$FE
.end_threads_loop:
	bit 7,(hl)
	jr z,.next
	set 6,(hl)
.next:
	inc l
	djnz .end_threads_loop
.wait_for_threads:
	call sys_GetKey
	cp a,53
	jq z,th_ResetThreadMemory
	HandleNextThread
	ld hl,thread_map+2
	ld b,$FE
.check_threads_loop:
	bit 7,(hl)
	jq nz,.wait_for_threads
	inc l
	djnz .check_threads_loop
	ld a,iyl
	ld (last_keypress),a
	ret

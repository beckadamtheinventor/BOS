;@DOES Return the next unused process ID, setting the malloc ID.
;@INPUT uint8_t sys_NextProcessId(void);
;@OUTPUT new process ID, or 0 if failed.
;@NOTE Used for categorizing malloc'd memory and threads.
;@DESTROYS Assume All
sys_NextProcessId:
	ld a,(threading_enabled)
	or a,a
	jr z,.no_threading
	call th_FindFreeThread
	ret z
	ld (running_process_id),a
	ret
.no_threading:
	ld a,(running_process_id)
	inc a
	inc a
	ret z ; don't allow using PID 255
	dec a
	ret z ; don't allow using PID 0
	ld (running_process_id),a
	ret

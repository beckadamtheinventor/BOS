;@DOES Decrement PID and return it if threading disabled. Does nothing if threading enabled.
;@INPUT uint8_t sys_PrevProcessId(void);
;@OUTPUT process ID.
;@DESTROYS AF
sys_PrevProcessId:
	ld a,(threading_enabled)
	or a,a
	ret nz
	ld a,(running_process_id)
	dec a
	ret z ; don't allow using PID 0
	ld (running_process_id),a
	ret
	

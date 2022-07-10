
;@DOES Decrement the process ID.
;@INPUT void sys_PrevProcessId(void);
;@NOTE Used for categorizing malloc'd memory
sys_PrevProcessId:
	ld a,(running_process_id)
	dec a
	ret z
	ld (running_process_id),a
	ret

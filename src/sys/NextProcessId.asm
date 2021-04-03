
;@DOES Increment the process ID.
;@INPUT void sys_NextProcessId(void);
;@NOTE Used for categorizing malloc'd memory
sys_NextProcessId:
	ld hl,running_process_id
	ld a,(hl)
	inc a
	ld (hl),a
	ret p
	ld a,1
	ld (hl),a
	ret

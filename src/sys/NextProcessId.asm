
;@DOES Increment the process ID.
;@INPUT void sys_NextProcessId(void);
;@NOTE Used for categorizing malloc'd memory
sys_NextProcessId:
	ld hl,running_process_id
	ld a,(hl)
	inc a
	bit 7,a
	ret nz
	ld (hl),a
	ret

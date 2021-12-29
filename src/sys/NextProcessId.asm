
;@DOES Increment the process ID.
;@INPUT void sys_NextProcessId(void);
;@NOTE Used for categorizing malloc'd memory
sys_NextProcessId:
	ld hl,running_process_id
	ld a,(hl)
	inc a
	ld (hl),a
	inc a
	ret nz
	inc a
	ld (hl),a
	ret

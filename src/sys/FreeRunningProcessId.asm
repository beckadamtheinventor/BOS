
;@DOES Free all memory allocated by the current process ID
;@INPUT void sys_FreeProcessId(void);
;@NOTE Automatically called after program runs
sys_FreeRunningProcessId:
	ld de,(running_process_id) ;only e is used but this saves space
.entry:
	ld hl,malloc_cache
	ld bc,4096
	ld d,c
.loop:
	ld a,e
	cpir
	ret po
	dec hl
	ld (hl),d
	inc hl
	ld e,a
.clear_loop:
	ld a,$FF
	cpi
	ret po
	jq nz,.loop
	dec hl
	ld (hl),d
	inc hl
	jq .clear_loop
	ret


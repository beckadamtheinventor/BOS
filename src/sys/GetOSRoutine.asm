
;@DOES Find an OS routine by name.
;@INPUT void *sys_GetOSRoutine(const char *name);
;@OUTPUT pointer to routine, or 0 if routine not found.
sys_GetOSRoutine:
	call ti._frameset0
	ld hl,(ix+6)
	ld a,'@'
	cp a,(hl)
	jq z,.load_by_number
	
	pop ix
	ret

.load_by_number:
	inc hl
	push hl
	call osrt.hexstr_to_int
	pop bc


;@DOES Allocate memory
;@INPUT void *sys_Malloc(size_t amt);
;@OUTPUT hl = malloc'd bytes. hl = -1 if failed to malloc
;@OUTPUT Cf set if failed to malloc
;@DESTROYS All
sys_Malloc:
	pop bc
	pop hl
	push hl
	push bc
	ld de,65536
	or a,a
	sbc hl,de
	jq nc,.fail
	or a,a
	adc hl,de
	jq z,.fail
	ld de,(remaining_free_RAM)
	or a,a
	ex hl,de
	sbc hl,de
	jq c,.fail
	ld (remaining_free_RAM),hl
	ld hl,(free_RAM_ptr)
	or a,a
	sbc hl,de
	dec hl
	dec hl
	ld (hl),de
	ld (free_RAM_ptr),hl
	inc hl
	inc hl
	or a,a
	ret
.fail:
	scf
	sbc hl,hl
	ret

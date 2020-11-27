;@DOES Malloc memory that is invalidated the next time sys_Malloc or sys_TempMalloc are called.
;@INPUT void *sys_TempMalloc(int len);
;@OUTPUT pointer to memory. Returns zero if not enough memory is avalible
sys_TempMalloc:
	pop bc,de
	push de,bc
	ld hl,(remaining_free_RAM)
	or a,a
	sbc hl,de
	jq c,.fail
	ld hl,(free_RAM_ptr)
	or a,a
	sbc hl,de ;Cf shouldn't be set here
	ret
.fail:
	xor a,a
	sbc hl,hl
	ret



threading_GetThreadID:
	pop hl,bc
	push bc,hl
	ld hl,thread_address_pool
	xor a,a
.loop:
	ld de,(hl)
	ex hl,de
	or a,a
	sbc hl,de
	add hl,de
	ex hl,de
	jq c,.next
	ex hl,de
	
	
	
.next:
	dec a
	jq nz,.loop
	
	ret


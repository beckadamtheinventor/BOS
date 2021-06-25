
;@DOES Starts a thread that does nothing until a key is pressed and unpressed, passes the keypress to the caller via a callback function, then stops.
;@INPUT int th_WaitKeyCycle(void (*callback)(uint8_t key));
;@OUTPUT returns 0 and Cf unset on success, -1 and Cf set on fail.
;@NOTE Starts a thread, which won't do anything until handled.
th_WaitKeyCycle:
	ld bc,32
	push bc
	call sys_Malloc
	pop bc
	ret c
	pop bc,de
	push de,bc
	dec hl
	dec hl
	dec hl
	ld (hl),de ;push callback address onto the stack
	ld bc,.thread
	push hl,bc
	call th_CreateThread
	pop bc,bc
	or a,a
	jq nz,.success
	scf
.success:
	sbc hl,hl
	ret
.loop:
	HandleNextThread
.thread:
	call sys_GetKey
	or a,a
	jr z,.loop
	ld c,a
	push bc
.loop2:
	HandleNextThread
	call sys_AnyKey
	jq nz,.loop2
	pop hl ;pop keypress
	ex (sp),hl ;push keypress, pop callback address
	ld bc,.end
	push bc ;push address to return from after callback
	jp (hl) ;jump to callback
.end:
	or a,a
	sbc hl,hl
	add hl,sp
	push hl
	call sys_Free
	EndThread


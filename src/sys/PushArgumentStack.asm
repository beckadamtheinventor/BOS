
;@DOES push an argument list to the argument stack
;@INPUT char *sys_PushArgumentStack(char *args);
;@DESTROYS All
sys_PushArgumentStack:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jr z,.push_null
	push hl
	call ti._strlen
	inc hl
	push hl
	call sys_Malloc
	ex hl,de
	pop bc,hl
	ret c
	push de
	ldir
	xor a,a
	ld (de),a
	pop de
	jr .push
.push_null:
	ld de,$FF0000
.push:
	ld hl,(argument_stack_current)
	dec hl
	dec hl
	dec hl
	ld (hl),de
	ld (argument_stack_current),hl
	ex hl,de
	or a,a
	ret


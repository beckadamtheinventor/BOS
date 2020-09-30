
;@DOES push an argument list to the argument stack
;@INPUT char *sys_PushArgumentStack(char *args);
;@DESTROYS All
sys_PushArgumentStack:
	pop bc
	pop hl
	push hl
	push bc
	push hl
	call ti._strlen
	inc hl
	push hl
	call sys_Malloc
	ex hl,de
	pop bc,hl
	push de
	ldir
	xor a,a
	ld (de),a
	pop de
	ld hl,(argument_stack_current)
	dec hl
	dec hl
	dec hl
	ld (hl),de
	ld (argument_stack_current),hl
	ex hl,de
	ret


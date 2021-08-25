;@DOES pop an argument list from the argument stack
;@INPUT void sys_PopArgumentStack(void);
;@DESTROYS All
sys_PopArgumentStack:
	ld hl,(argument_stack_current)
	ld de,(hl)
	push hl,de
	call sys_Free
	pop de,hl
	inc hl
	inc hl
	inc hl
	ld (argument_stack_current),hl
	ret

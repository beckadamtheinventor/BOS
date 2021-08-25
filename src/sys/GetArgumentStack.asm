;@DOES Get the current argument list from the argument stack
;@INPUT char *sys_GetArgumentStack(void);
sys_GetArgumentStack:
	ld hl,(argument_stack_current)
	ld hl,(hl)
	ret

;@DOES Pop OP1 from the OP stack
_PopOP1:
	ld hl,fsOP1
	jp sys_PopOPStack

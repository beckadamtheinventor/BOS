;@DOES Push OP1 to the OP stack
_PushOP1:
	ld hl,fsOP1
	jp sys_PushOPStack

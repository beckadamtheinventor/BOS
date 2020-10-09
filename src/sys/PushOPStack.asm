;@DOES push 16 bytes from HL onto the OP stack
sys_PushOPStack:
	ld bc,16
	ld de,(op_stack_ptr)
	dec de
	lddr
	inc de
	ld (op_stack_ptr),de
	ret

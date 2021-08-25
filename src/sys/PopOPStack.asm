;@DOES pop 16 bytes from the OP stack into HL
sys_PopOPStack:
	ex hl,de
	ld bc,16
	ld hl,(op_stack_ptr)
	ldir
	ld (op_stack_ptr),hl
	ret

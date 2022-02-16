iterate num, 1, 2, 3, 4, 5, 6
	_PushOP#num:
		ld hl,fsOP#num + 10
		jr _PushOPStack
end iterate

_PushOPStack:
	ld bc,11
	ld de,(op_stack_ptr)
	dec de
	lddr
	inc de
	ld (op_stack_ptr),de
	ret

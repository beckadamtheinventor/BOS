
iterate num, 1, 2, 3, 4, 5, 6
	_PopOP#num:
		ld hl,fsOP#num
	if $ <> _PushOPStack
		jr _PopOPStack
	end if
end iterate

;@DOES pop 11 bytes from the OP stack into HL
_PopOPStack:
	ex hl,de
	ld bc,11
	ld hl,(op_stack_ptr)
	ldir
	ld (op_stack_ptr),hl
	ret

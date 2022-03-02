
;@DOES pop beg/cur/endPC from the OP stack.
;@DESTROYS All, OP4
sys_PopExecutableText:
	call _PopOP4
	ld hl,(ti.OP4)
	ld de,(ti.OP4+3)
	ld bc,(ti.OP4+6)
	ld (ti.begPC),hl
	ld (ti.curPC),de
	ld (ti.endPC),bc
	ret

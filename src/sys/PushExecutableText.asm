
;@DOES push beg/cur/endPC then load them with the program pointed to in HL with length BC.
;@DESTROYS All, OP4
;@NOTE Uses the OP stack to save beg/cur/endPC.
sys_PushExecutableText:
	push hl,bc
	ld hl,(ti.begPC)
	ld de,(ti.curPC)
	ld bc,(ti.endPC)
	ld (ti.OP4),hl
	ld (ti.OP4+3),de
	ld (ti.OP4+6),bc
	call _PushOP4
	pop bc,hl
	ld (ti.begPC),hl
	ld (ti.curPC),hl
	add hl,bc
	ld (ti.endPC),hl
	ret

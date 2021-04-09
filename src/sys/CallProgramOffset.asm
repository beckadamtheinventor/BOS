
;@DOES Call the currently running program at a given offset
;@INPUT program offset in HL
sys_CallProgramOffset:
	push bc
	ld bc,(running_program_ptr)
	add hl,bc
	pop bc
	jp (hl)

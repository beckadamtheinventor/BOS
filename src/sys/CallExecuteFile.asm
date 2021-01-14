;@DOES Jump execution to an executable file and return to caller
;@INPUT hl = file to execute
;@INPUT de = arguments
;@INPUT bc = file to return to
sys_CallExecuteFile:
	push hl,de,bc
	call ti._strlen
	push hl
	call sys_Malloc
	ex hl,de
	pop bc
	pop hl
	jq c,.fail
	push de
	ldir
	pop bc,de,hl
	push bc,de,hl
	call sys_ExecuteFile
	pop hl,de,bc
	ld de,$FF0000
	push de,bc
	call sys_ExecuteFile
	call sys_Free
	pop bc,bc
	ret
.fail:
	pop bc,bc
	ret


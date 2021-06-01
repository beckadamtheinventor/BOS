;@DOES Jump execution to an executable file and return to caller afterwards
;@INPUT hl = file to execute
;@INPUT de = arguments
;@INPUT bc = file to return to
sys_CallExecuteFile:
	push hl,de,bc
	call sys_FreeRunningProcessId
	ld a,(running_process_id)
	ld (fsOP6+15),a
	ld a,1
	ld (running_process_id),a
	call ti._strlen
	inc hl
	push hl
	call sys_Malloc
	ex hl,de
	pop bc,hl
	jq c,.fail
	push de
	ldir
	xor a,a
	ld (de),a
	pop bc,de,hl
	push bc,de,hl
	ld a,(fsOP6+15)
	ld (running_process_id),a
	call sys_ExecuteFile
	call sys_PrevProcessId
	pop bc,bc,hl
	jq sys_ExecuteFileHL
.fail:
	pop bc,bc
	jq sys_ExecuteFileHL


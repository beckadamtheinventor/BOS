;@DOES Jump execution to an executable file and return to caller afterwards
;@INPUT hl = program file to execute
;@INPUT de = arguments
;@INPUT bc = program file to return to
sys_CallExecuteFile:
	push hl,de,bc
	call ti._strlen
	inc hl
	push hl
	call sys_MallocPersistent
	ex hl,de
	pop bc,hl
	jq c,.fail
	push de
	ldir
	pop bc,de,hl
	push bc,de,hl
	call sys_ExecuteFile
	pop bc,bc,hl
	ld a,1
	db $01 ; dummify next 3 bytes
.fail:
	pop bc,bc
	xor a,a
.return:
	push af,hl
	call sys_LoadProgramNoExec
	jp c,os_return ; reboot if loading the caller failed
	pop bc,af
	push hl,bc
	or a,a
	call nz,sys_Free ; free malloc'd caller name if it was malloc'd
	pop bc
	ret ; return to program address returned from sys_LoadProgramNoExec


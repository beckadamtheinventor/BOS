;@DOES Jump execution to an executable file
;@INPUT hl = file to execute
;@INPUT de = arguments
sys_JumpExecuteFile:
	push de,hl
	call sys_FreeProcessId
	call sys_PrevProcessId
	pop hl,de
	pop bc,bc ; pop old argc/argv
	jq sys_ExecuteFileHLDE


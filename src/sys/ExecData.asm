;@DOES Execute a command string given its length.
;@INPUT int32_t sys_ExecData(const char *str, size_t len);
;@OUTPUT process exit code.
;@OUTPUT exit code also stored in bos.LastCommandResult
sys_ExecData:
	pop de,hl,bc
	push bc,hl,de
.entry_hl_bc:
	ld (ti.begPC),hl
	add hl,bc
	ld (ti.endPC),hl
	jq sys_ExecBegin

;@DOES Execute a null-terminated command string.
;@INPUT int32_t sys_Exec(const char *str);
;@OUTPUT process exit code.
;@OUTPUT exit code also stored in bos.LastCommandResult
sys_Exec:
	pop bc,hl
	push hl,bc
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	jr sys_ExecData.entry_hl_bc

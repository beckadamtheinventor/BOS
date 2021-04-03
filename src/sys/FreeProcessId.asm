
;@DOES Free all memory allocated by a given process ID
;@INPUT void sys_FreeProcessId(uint8_t id);
sys_FreeProcessId:
	pop hl,de
	push de,hl
	jq sys_FreeRunningProcessId.entry


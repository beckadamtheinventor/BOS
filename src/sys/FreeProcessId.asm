;@DOES Free all memory allocated by a given process ID
;@INPUT void sys_FreeProcessId(uint8_t id);
;@NOTE DO NOT free process ID 1 since it is used by the OS and should be preserved.
sys_FreeProcessId:
	pop hl,de
	push de,hl
	jq sys_FreeRunningProcessId.entry


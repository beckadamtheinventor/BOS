
;@DOES Check the executable type of a given file descriptor
;@INPUT const char *sys_GetExecType(void *fd);
;@OUTPUT pointer to executable magic bytes, or -1 and Cf set if failed.
sys_GetExecTypeFD:
	pop bc,hl
	push hl,bc
.entry:
	push hl
	call fs_GetFDLen.entry
	ex (sp),hl
	call fs_GetFDPtr.entry
	pop bc
	jq sys_GetExecType.entryhlbc

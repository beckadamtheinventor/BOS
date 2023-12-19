
;@DOES Check the executable type of a given file descriptor
;@INPUT const char *sys_GetExecType(void *fd);
;@OUTPUT pointer to executable magic bytes, or -1 and Cf set if failed.
;@NOTE returns pointer to executable code in de and length of executable code in bc if hl != -1
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

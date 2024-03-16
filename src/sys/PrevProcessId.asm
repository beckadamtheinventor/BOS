;@DOES Return the next open process ID.
;@INPUT uint8_t sys_PrevProcessId(void);
;@OUTPUT process ID.
;@DESTROYS AF
sys_PrevProcessId:=th_FindNextThread
	

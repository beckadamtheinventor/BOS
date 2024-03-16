;@DOES Return the next unused process ID.
;@INPUT uint8_t sys_NextProcessId(void);
;@OUTPUT new process ID, or 0 if failed.
;@NOTE Used for categorizing malloc'd memory and threads.
;@DESTROYS AF
sys_NextProcessId:
	call th_FindFreeThread
	ret z
	ld (running_process_id),a
	ret

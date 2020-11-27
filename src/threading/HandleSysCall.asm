
threading_HandleSysCall:
	push hl
	ld hl,threads_all_flags
	set bthreads_temp_disabled,(hl)
	ex (sp),hl
	call thread_save_registers
	
	
	call thread_restore_registers
	ex (sp),hl
	res bthreads_temp_disabled,(hl)
	ret



;@DOES Opens CEmu debugger, and can be used as an on-calc breakpoint in a user program.
util_OpenDebugger:
	call util_BackupRegisters
	call .check_emu
	or a,a
	jq	nz,.cemu
	ld iy,fsOP2
.loop:
	call sys_WaitKeyCycle
	cp a,9
	jr nz,.loop
	jp util_RestoreRegisters
.cemu:
	scf
	sbc hl,hl
	ld (hl),2
	ret
.check_emu:
	xor	a,a
	ld	hl,$FD0000 ;CEmu dbgext
	ld	(hl),2     ;check command
	ret

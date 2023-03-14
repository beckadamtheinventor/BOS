
HandleSysCall:
	push iy
	ld iy,0
	add iy,sp
	push hl
	ld hl,(iy+3) ; return address
	push hl
	xor a,a
	ld bc,$FFFFFF
	ld (fsOP6),bc
	inc bc
	cpir
	ld (iy+3),hl ; advance return address
	ld hl,str_SysCallsVar
	ex (sp),hl
	push hl
	call sys_OpenFileInVar
	pop de,bc
	jr c,.fail
	call sys_ExecuteFileFD
.done:
	pop hl
	pop iy
	ret
.fail:
	push de
	ld hl,str_UnimplementedSysCall
	call gui_DrawConsoleWindow
	pop hl
	call gui_PrintLine
	call sys_WaitKeyCycle
	jr .done

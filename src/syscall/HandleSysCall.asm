
sc_HandleSysCall:
	push hl,ix,iy
	ld iy,0
	add iy,sp
	ld hl,(iy+9) ; return address
	xor a,a
	ld bc,$FFFFFF
	ld (fsOP6),bc
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld bc,(iy+9)
	ld (iy+9),hl ; advance return address
	ld hl,str_SysCallsVar
	push bc,hl,de
	call sc_LoadSysCall
	pop bc,bc,de
	pop iy,ix
	jr c,.fail
	ex (sp),hl
	ret
.fail:
	pop hl
	push de
	ld hl,str_UnimplementedSysCall
	call gui_DrawConsoleWindow
	pop hl
	call gui_PrintLine
	jp sys_WaitKeyCycle


sc_HandleSysCall:
	push ix,iy
	ld iy,0
	add iy,sp
	ld hl,(iy+6) ; return address
	xor a,a
	ld bc,$FFFFFF
	ld (fsOP6),bc
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld (iy+6),hl ; advance return address
	ld hl,str_SysCallsVar
	push hl,de
	call sc_LoadSysCall
	pop de,bc
	pop iy,ix
	jr c,.fail
	jp (hl)
.fail:
	push de
	ld hl,str_UnimplementedSysCall
	call gui_DrawConsoleWindow
	pop hl
	call gui_PrintLine
	jp sys_WaitKeyCycle

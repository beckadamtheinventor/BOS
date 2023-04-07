
sc_HandleSysCall:
	push hl,af,de,bc,ix,iy
	ld iy,0
	add iy,sp
	ld hl,(iy+18) ; return address
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld (iy+18),hl ; advance return address
	push de
	call sc_LoadSysCall
	pop de
	pop iy,ix,bc
	jr c,.fail
	pop de,af
	ex (sp),hl
	ret
.fail:
	pop hl,af,hl
	push de
	ld hl,str_UnimplementedSysCall
	call gui_DrawConsoleWindow
	pop hl
	call gui_PrintLine
	jp sys_WaitKeyCycle

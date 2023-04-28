
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
	push de,de
	call sc_LoadSysCall
	pop de
	jr c,.fail
	ld a,(iy+18+2)
	cp a,$D0
	jr c,.dont_smc
	; cp a,$E4
	; jr nc,.dont_smc
	ex hl,de
	ld hl,(iy+18)
	dec hl
	dec hl
	dec hl
	ld (hl),de ; smc the syscall address
	dec hl
	ld (hl),$CD ; call opcode
	ex hl,de
.dont_smc:
	or a,a
	pop de
	pop iy,ix,bc
	jr c,.fail
	pop de,af
	ex (sp),hl
	ret
.fail:
	pop de
	pop iy,ix,bc
	pop hl,af,hl
	push de
	ld hl,str_UnimplementedSysCall
	call gui_DrawConsoleWindow
	pop hl
	call gui_PrintLine
	jp sys_WaitKeyCycle

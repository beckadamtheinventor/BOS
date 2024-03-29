
sc_HandleSysCall:
	push hl,af,de,bc,ix,iy
	ld ix,0
	add ix,sp
	ld hl,(ix+18) ; return address
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld (ix+18),hl ; advance return address
	add hl,de
	push hl,hl
	call sc_LoadSysCall
	pop de
	jr c,.fail
	cp a,3
	jr z,.return_data
	ld a,(ix+18+2)
	cp a,$D0
	jr c,.dont_smc ; don't smc the syscall if not executing from RAM
	; cp a,$E4
	; jr nc,.dont_smc
	ex hl,de
	ld hl,(ix+18)
	dec hl
	dec hl
	dec hl
	ld (hl),de ; smc the syscall address
	dec hl
	ld (hl),$CD ; call opcode
	ex hl,de
	db $01 ; ld bc,... dummify next 3 bytes. High byte of the following load opcode is a nop.
.return_data:
	ld hl,$F8
.dont_smc:
	pop de
	pop iy,ix,bc
	pop de,af
	ex (sp),hl
	ret
.fail:
	pop de
	push de
	ld hl,str_UnimplementedSysCall
	call gui_DrawConsoleWindow
	pop hl
	call gui_PrintLine
	ld hl,str_TerminateOrContinue
	call gui_PrintLine
	call sys_WaitKeyCycle
.waitloop:
	cp a,ti.skClear
	jr z,.return_data
	cp a,ti.skEnter
	jr nz,.waitloop
	jp os_return

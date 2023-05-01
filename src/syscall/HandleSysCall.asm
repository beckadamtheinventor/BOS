
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
	cp a,3
	jr z,.return_data
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
	; pop iy,ix,bc
	; pop hl,af,hl
	ld hl,3*6
	add hl,sp
	ld sp,hl ; pop 6 unused values off the stack
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
	ret z
	cp a,ti.skEnter
	jr nz,.waitloop
	jp os_return

    jr ramexec_main
    db "FEX",0
ramexec_main:
	call ti._frameset0
    ld a,(ix+6)
    cp a,3
    jr c,.show_info
	syscall _argv_1
	ld a,(hl)
.address:
	push hl
	call bos.str_IntStrToInt
    add hl,bc
    or a,a
    sbc hl,bc
    jr z,.exit ; exit if address is zero
    ex (sp),hl ; save address
    syscall _argv_2
    push hl
    call bos.str_IntStrToInt
    add hl,bc
    or a,a
    sbc hl,bc
    jr z,.exit ; exit if length is zero
    pop bc
    ex (sp),hl ; save length, restore address
    pop bc ; length
    ld de,ti.userMem
    push de
    ldir
    pop hl
.jump:
	ld sp,ix
	pop ix
	jp (hl)

.show_info:
    ld hl,.info_str
    call bos.gui_PrintLine
.exit:
    or a,a
    sbc hl,hl
    ld sp,ix
    pop ix
    ret

.info_str:
    db "ramexec addr len",$A
    db "Execute len bytes from addr in ram at usermem",0

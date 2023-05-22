
	jr mem_cpy_exe_main
	db "FEX",0
mem_cpy_exe_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,4
	jr z,.correctnumberofarguments
	ld hl,.helpstr
	call bos.gui_PrintLine
	jr .return0
.correctnumberofarguments:
	call osrt.argv_1
	push hl
	call osrt.intstr_to_int
	pop bc
	ld bc,$D00000
	or a,a
	sbc hl,bc
	jr c,.failcopytorom
	add hl,bc
	ld bc,$D65800
	sbc hl,bc
	jr nc,.failcopybeyondram
	add hl,bc
	push hl
	call osrt.argv_3
	push hl
	call osrt.intstr_to_int
	pop bc
	pop de
	push hl,de
	add hl,de
	ld bc,$D00000
	or a,a
	sbc hl,bc
	jr c,.failcopytorom
	add hl,bc
	ld bc,$D65800
	sbc hl,bc
	jr nc,.failcopybeyondram
	call osrt.argv_2
	push hl
	call osrt.intstr_to_int
	pop bc,de,bc
	ldir
.return0:
	or a,a
	sbc hl,hl
	jr .done
.failcopybeyondram:
	ld hl,.str_fail_copy_beyond_ram
	jr .failprint
.failcopytorom:
	ld hl,.str_fail_copy_to_rom
.failprint:
	call bos.gui_PrintLine
	ld hl,1
.done:
	ld sp,ix
	pop ix
	ret

.helpstr:
	db "memcpy dest src len", $A
	db "numbers decimal or $hex", 0
.str_fail_copy_to_rom:
	db "Cannot copy to flash.",0
.str_fail_copy_beyond_ram:
	db "Cannot copy beyond ram.",0

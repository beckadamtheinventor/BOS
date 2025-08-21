
	jq sleep_main
	db "FEX",0
sleep_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,2
	jr nz,.info
	syscall _argv_1
	push hl
	call bos.str_IntStrToInt
	pop bc
	ld bc,250
	or a,a
.loop:
	ld a,l
	sbc hl,bc
	jr c,.final_delay_a_ms
	ld a,24
	call ti.DelayTenTimesAms
	jr .loop
.final_delay_a_ms:
	; a/10 ~= ((a * 26) >> 8)
	ld c,a
	ld b,26
	mlt bc
	ld a,b
	call ti.DelayTenTimesAms
.exit:
	or a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
	jr .exit
.infostr:
	db "sleep ms",0


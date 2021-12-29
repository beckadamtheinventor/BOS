
	jq sleep_main
	db "FEX",0
sleep_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,2
	jr nz,.info
	call osrt.argv_1
	call osrt.str_to_int
	ld bc,0
.delay_loop:
	; assumes 48MHz mode. (50331648cc/s, ~50332cc/ms)
	; this routine waits 50329cc
	; inner loop takes 16cc and runs 256 times. The final run takes 2cc less.
	; outer loop runs inner loop 12 times. The first run takes an extra 2cc. The final run takes 2cc less.
	; inner() = 3+1+2+16*256-2 = 4100; outer() = inner()*12 + 1130;
	; 50329 = (3+1+2+16*256-2)*12 + -1 + 140*8 + 4 + 6
.delay:
	ld d,12
.outer:
	ld c,0
.inner2:
	ld b,0
.inner:
repeat 12
	nop
end repeat
	djnz .inner
	dec c
	jr nz,.inner2
	dec d
	jr nz,.outer
	ld b,142
.inner3:
repeat 6
	nop
end repeat
	djnz .inner3
	scf
	sbc hl,bc
	jr nz,.delay_loop
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



	jq if_main
	db "FEX",0
if_main:
	ld hl,-9
	call ti._frameset
	ld a,(ix+6)
	cp a,2
	jq c,.info
	call osrt.argv_1
	ld a,(hl)
	or a,a
	jq z,.info
	
	
	
	
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.exit_0:
	or a,a
	sbc hl,hl
.exit_hl:
	ld sp,ix
	pop ix
	ret
.infostr:
	
	db 0


	jq if_main
	db "FEX",0
if_main:
	ld hl,-9
	call ti._frameset
	ld hl,(ix+6)
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

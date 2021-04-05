
	jr mv_main
	db "FEX",0
mv_main:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	or a,a
	jq z,.info
	
	ret
.info:
	ld hl,.infostring
	call bos.gui_PrintLine
.done:
	or a,a
	sbc hl,hl
	ret
.infostring:
	db 

	jq cls_main
	db "FEX",0
cls_main:
	ld hl,bos.current_working_dir
	call bos.gui_DrawConsoleWindow
	xor a,a
	sbc hl,hl
	ret


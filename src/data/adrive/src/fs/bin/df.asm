
	jr df_main
	db "FEX",0
df_main:
	ld hl,.checking_used
	call bos.gui_PrintLine
	call bos.fs_GetFreeSpace
	push hl,hl
	ex hl,de
	ld hl,$3B0000 - $050000
	or a,a
	sbc hl,de
	call bos.gui_PrintUInt
	ld hl,.str_bytes_used
	call bos.gui_PrintLine
	pop hl
	call bos.gui_PrintUInt
	ld hl,.str_bytes_free
	call bos.gui_PrintLine
	pop hl
	ld c,10
	call ti._ishru
	call bos.gui_PrintUInt
	ld hl,.str_kb_free
	call bos.gui_PrintLine
	or a,a
	sbc hl,hl
	ret
.checking_used:
	db "Checking used memory...",0
.str_bytes_free:
	db " bytes free,",0
.str_bytes_used:
	db " bytes used,",0
.str_kb_free:
	db "KB free of 3456KB total.",0

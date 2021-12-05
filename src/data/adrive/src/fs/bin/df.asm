
	jr df_main
	db "FEX",0
df_main:
	ld hl,.checking_used
	call bos.gui_PrintLine
	call bos.fs_GetFreeSpace
	push hl,hl
	call bos.gui_PrintUInt
	ld hl,.str_bytes_free
	call bos.gui_Print
	pop de
	ld hl,$3B0000 - $050000
	or a,a
	sbc hl,de
	call bos.gui_PrintUInt
	ld hl,.str_bytes_used
	call bos.gui_Print
	pop hl
	ld c,10
	call ti._ishru
	call bos.gui_PrintUInt
	ld hl,.str_kb_free
	call bos.gui_Print
	or a,a
	sbc hl,hl
	ret
.cmap_file:
	db "/dev/cmap.dat",0
.checking_used:
	db "Checking for used memory...",$A,0
.memfree:
	db "Free memory:",$9,0
.str_bytes_free:
	db " bytes free,",$A,0
.str_bytes_used:
	db " bytes used,",$A,0
.str_kb_free:
	db " KB free of 3456 KB total.",$A,0


	jr df_main
	db "FEX",0
df_main:
	ld hl,.checking_used
	call bos.gui_PrintLine
	ld hl,.cmap_file
	push hl
	call bos.fs_OpenFile
	pop bc
	ret c
	ld bc,$C
	add hl,bc
	ld de,(hl)
	push de
	call bos.fs_GetSectorAddress
	pop bc
	ld bc,7040
	ld de,0
.loop:
	ld a,(hl)
	inc hl
	inc a
	jq nz,.next
	inc de
.next:
	dec bc
	ld a,b
	or a,c
	jq nz,.loop
	ex hl,de
	call bos.fs_MultByBytesPerSector
	push hl
	call bos.gui_PrintUInt
	ld hl,.str_bytes_free
	call bos.gui_Print
	pop de
	ld hl,3604480
	or a,a
	sbc hl,de
	call bos.gui_PrintUInt
	ld hl,.str_bytes_used
	call bos.gui_Print
	ld hl,3604480
	call bos.gui_PrintUInt
	ld hl,.str_bytes_total
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
	db " bytes free",$A,0
.str_bytes_used:
	db " bytes used",$A,0
.str_bytes_total:
	db " bytes total",$A,0

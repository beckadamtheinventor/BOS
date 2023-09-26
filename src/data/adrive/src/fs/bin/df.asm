
	jr df_main
	db "FEX",0
df_main:
	call bos.fs_GetFreeSpace
	push hl,hl
	ex hl,de
	ld hl,bos.end_of_user_archive - bos.start_of_user_archive
	or a,a
	sbc hl,de
	call bos.gui_PrintUInt
	ld hl,.str_bytes_used
	call bos.gui_PrintLine
	pop hl
	call bos.gui_PrintUInt
	ld hl,.str_bytes_free
	call bos.gui_PrintLine

	ld hl,bos.fs_cluster_map
	ld bc,bos.fs_cluster_map.len
	ld de,0
if bos.fscluster_freed
	ld a,bos.fscluster_freed
else
	xor a,a
end if
.loop:
	cpi
	jr nz,.notfreed
	inc de
.notfreed:
	jp pe,.loop
	ex hl,de
	ld c,bos.fs_sector_size_bits
	call ti._ishl
	call bos.gui_PrintUInt
	ld hl,.str_bytes_dirty
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
.str_bytes_free:
	db " bytes free",0
.str_bytes_used:
	db " bytes used",0
.str_bytes_dirty:
	db " bytes dirty",0
.str_kb_free:
	db "KB free of 3520KB total",0

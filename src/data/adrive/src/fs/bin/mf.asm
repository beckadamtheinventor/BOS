
	jr mf_main
	db "FEX",0
mf_main:
	ld hl,.str_usermem_bytes
	call bos.gui_PrintLine
	ld hl,(bos.top_of_UserMem)
	ld de,-ti.userMem
	add hl,de
	push hl
	call bos.gui_PrintUInt
	ld hl,.str_bytes_used
	call bos.gui_PrintLine
	pop de
	ld hl,bos.end_of_usermem-ti.userMem
	or a,a
	sbc hl,de
	call bos.gui_PrintUInt
	ld hl,.str_bytes_free
	call bos.gui_PrintLine

	ld hl,.str_malloc_bytes
	call bos.gui_PrintLine
	ld hl,bos.malloc_cache
	ld bc,bos.malloc_cache_len
	ld de,-1
	xor a,a
.check_malloc_loop:
	inc de
	cpir
	jp pe,.check_malloc_loop
	ex hl,de
	ld c,bos.malloc_block_size_bits
	call ti._ishl
	push hl
	ex hl,de
	ld hl,bos.malloc_cache_len * bos.malloc_block_size
	or a,a
	sbc hl,de
	call bos.gui_PrintUInt
	ld hl,.str_bytes_used
	call bos.gui_PrintLine
	pop hl
	call bos.gui_PrintUInt
	ld hl,.str_bytes_free
	call bos.gui_PrintLine
	or a,a
	sbc hl,hl
	ret
.str_usermem_bytes:
	db "Usermem bytes:",0
.str_malloc_bytes:
	db "Malloc bytes:",0
.str_bytes_used:
	db " bytes used,",0
.str_bytes_free:
	db " bytes free,",$A,0

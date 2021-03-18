	jq info_exe_main
	db "FEX",0
info_exe_main:
	pop bc,hl
	push hl,bc,hl
	call bos.fs_OpenFile
	pop bc
	ret c
	push hl
	ld hl,.string_filesize
	call bos.gui_Print
	call bos.fs_GetSectorAddress
	ex (sp),hl
	ld bc,$E
	add hl,bc
	ld de,(hl)
	ex.s hl,de
	call bos.sys_HLToString
	ex hl,de
	call bos.gfx_PrintString
	pop hl
	ld a,(hl)
	cp a,$18
	jq z,.skip2
	cp a,$C3
	jq z,.skip4
	cp a,$80
	jq nc,.binary
	cp a,$20
	jr nc,.text
.binary:
	ld hl,.string_bin
	jq .print_type
.text:
	ld hl,.string_text
	jq .print_type
.fex:
	ld hl,.string_fex
	jq .print_type
.rex:
	ld hl,.string_rex
	jq .print_type
.skip4:
	inc hl
	inc hl
.skip2:
	inc hl
	inc hl
	ld de,(hl)
	db $21, "FEX"
	or a,a
	sbc hl,de
	jq z,.fex
	db $21, "REX"
	or a,a
	sbc hl,de
	jq z,.rex
	jq .binary
.print_type:
	push hl
	call bos.gui_NewLine
	pop hl
	call bos.gui_Print
	call bos.gui_NewLine
	or a,a
	sbc hl,hl
	ret
.string_filesize:
	db "File Size: ",0
.string_bin:
	db "Binary file",0
.string_text:
	db "Text file",0
.string_fex:
	db "Flash EXecutable",0
.string_rex:
	db "RAM EXecutable",0


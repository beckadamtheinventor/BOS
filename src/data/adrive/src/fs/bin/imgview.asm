	jr imgview_main
	db "FEX", 0
imgview_main:
	ld hl,-18
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-3),hl
	ld (ix-6),hl
	ld (ix-9),hl
	ld a,(ix+6)
	cp a,2
	jr nc,.has_enough_args
	ld hl,.infostr
	call bos.gui_PrintLine
	jq .exit
.has_enough_args:
	call osrt.argv_1
	ld (ix-12),hl ; file name
	push hl
	call bos.fs_GetFilePtr
	jr nc,.file_found
	push hl
	ld hl,.str_file_not_found
	call bos.gui_PrintLine
	pop hl
	jr .exit_no_clear
.file_found:
	ld (ix-15),hl ; file data pointer
	dec bc
	dec bc
	dec bc
	dec bc
	ld (ix-18),bc ; file size-4
	pop bc
	ld bc,._waitexit
	push bc
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	db $21, "FSI" ; ld hl,...
	or a,a
	sbc hl,de
	jr z,.view_fsi
	db $21, "SPT" ; ld hl,...
	or a,a
	sbc hl,de
	jr z,.view_spt

	pop bc
.formaterror:
	ld hl,.str_formaterror
	call bos.gui_DrawConsoleWindow
	ld hl,3
	jr .exit_no_clear
.exit:
	call cls_main
	or a,a
	sbc hl,hl
.exit_no_clear:
	ld sp,ix
	pop ix
	ret

._waitexit:
	call .waitexit
	jr .exit

.waitexit:
	call bos.sys_WaitKeyCycle
	cp a,ti.skEnter
	ret z
	cp a,ti.sk2nd
	ret z
	cp a,ti.skClear
	ret z
	jr .waitexit

.view_fsi:
	ld hl,(ix-15)
	inc hl
	inc hl
	inc hl
	inc hl
	push hl
	ld hl,bos.LCD_BUFFER
	push hl
	cp a,'7'
	jr z,.view_fsi7
	cp a,'0'
	jr z,.view_fsi0
	or a,a
	jr nz,.formaterror

	pop bc,bc

.view_fsi_no_compression:
	ld hl,(ix-15)
	ld de,bos.LCD_VRAM
	ld bc,(ix-18)
	ldir
	jr .draw_vram
.draw_vram_from_buffer:
	call bos.gfx_BlitBuffer
.draw_vram:
	ld hl,bos.LCD_VRAM
	ld (ti.mpLcdUpbase),hl
	ret

.view_fsi7:
	call bos.util_Zx7Decompress
	jr .view_fsi7_0_common

.view_fsi0:
	call bos.util_Zx0Decompress
.view_fsi7_0_common:
	pop bc,bc
	ld de,bos.LCD_BUFFER
	or a,a
	sbc hl,de
	ld (ix-18),hl ; decompressed size
	jr .draw_vram_from_buffer

.view_spt:
	xor a,a
	call bos.gfx_SetDraw
	ld hl,(ix-18) ; file length
	ld bc,7 ; min size
	or a,a
	sbc hl,bc
	jp c,.formaterror ; not enough file data
	ld hl,(ix-15) ; file pointer
	ld e,(hl)
	inc hl
	ld a,(hl)
	ld d,a
	ex hl,de
	mlt hl
	add hl,bc
	or a,a
	sbc hl,bc
	jp z,.formaterror ; zero width/height image
	ex hl,de
	dec hl
	dec hl
	ld bc,0
	cp a,bos.LCD_WIDTH/2
	jr nc,.view_spt_1x
	ld a,(hl)
	cp a,bos.LCD_HEIGHT/2
	jr nc,.view_spt_1x
.view_spt_2x:
	call bos.gfx_Sprite2x
	jr .draw_vram_from_buffer
.view_spt_1x:
	call bos.gfx_Sprite
	jr .draw_vram_from_buffer

.infostr:
	db "imgview (file)",0

.str_formaterror:
	db "Invalid image file format",0

.str_file_not_found:
	db "File not found",0

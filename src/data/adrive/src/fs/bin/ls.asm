	jq ls_main
	db "FEX",0
ls_main:
	ld hl,-11
	call ti._frameset
	ld a,(bos.lcd_text_bg)
	ld (ix-10),a
	ld a,(bos.lcd_text_fg)
	ld (ix-11),a
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	ld a,(ix+6)
	dec a
	jr z,.no_arguments
	call osrt.argv_1
	ld a,(hl)
	or a,a
	jq nz,.non_null_dir
.no_arguments:
	ld hl,bos.current_working_dir
.non_null_dir:
	ld (ix-9),hl
	push hl
	call bos.gui_PrintLine
	pop bc
	ld hl,96
	push hl
	call bos.sys_Malloc
	pop bc
	ld (ix-6),hl
	or a,a
	sbc hl,hl
	ld (ix-3),hl

.dirlist_loop:
	ld hl,(ix-3)
	push hl
	ld bc,32
	add hl,bc
	ld (ix-3),hl
	ld hl,(ix-6)
	ld de,(ix-9)
	push bc,de,hl
	call bos.fs_DirList
	pop hl,bc,bc,bc
	jq c,.exit

	ld b,32
.inner_loop:
	ld de,(hl)
	ld a,(de)
	or a,a
	jq z,.exit
	inc a
	jq z,.exit
	ld a,e
	or a,d
	inc hl
	inc hl
	or a,(hl)
	jq z,.exit
	inc hl
	push hl,bc
	push de
	pop iy
	ld bc,(bos.lcd_text_bg)
	cp a,'.'+1
	jq z,.hidden
	bit bos.fd_hidden,(iy+$B) ;check if file is hidden
	jq nz,.hidden
	bit bos.fd_subdir,(iy+$B)
	jq nz,.subdir
	bit bos.fd_device,(iy+$B)
	jq nz,.device
	ld a,$FF
	jq .set_colors
.subdir:
	ld a,$3F
	ld c,$1A
	jq .set_colors
.device:
	ld a,$B5
	jq .set_colors
.hidden:
	ld a,$1F
.set_colors:
	ld (bos.lcd_text_fg),a
	ld a,c
	ld (bos.lcd_text_bg),a
.draw_file_name:
	ld hl,bos.curcol
	inc (hl)
	inc (hl)
	push iy
	call bos.fs_CopyFileName
	pop bc
	push hl
	call bos.gui_Print
	call bos.sys_Free ;free the buffer allocated by fs_CopyFileName
	pop bc
	ld a,(ix-10)
	ld (bos.lcd_text_bg),a
	call bos.gui_NewLine
.next:
	pop bc,hl
	djnz .inner_loop
	jq .dirlist_loop
.exit:
.exit_nopop:
	xor a,a
	sbc hl,hl
	db $01
.fail:
	scf
	sbc hl,hl
	ld a,(ix-10)
	ld (bos.lcd_text_bg),a
	ld a,(ix-11)
	ld (bos.lcd_text_fg),a
	ld sp,ix
	pop ix
	ret
.tab_str:
	db $9
str_TabString:
	db $9,0

	jq ls_main
	db "FEX",0
ls_main:
	ld hl,-9
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq nz,.non_null_dir
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
	pop bc,bc,bc,bc
	jq c,.exit

	ld b,32
.inner_loop:
	ld de,(hl)
	ld a,(de)
	or a,a
	jq z,.exit
	ex hl,de
	add hl,de
	sbc hl,de
	jq z,.exit
	ex hl,de
	inc a
	jq z,.exit
	inc hl
	inc hl
	inc hl
	push hl,bc
	push de
	pop iy
	cp a,'.'+1
	jq z,.hidden
	bit bos.fd_hidden,(iy+$B) ;check if file is hidden
	jq nz,.hidden
	bit bos.fd_subdir,(iy+$B)
	jq nz,.subdir
	bit bos.fd_device,(iy+$B)
	jq nz,.device
	bit bos.fd_readonly,(iy+$B)
	jq nz,.readonly
	ld a,$FF
	ld c,0
	jq .set_colors
.readonly:
	ld a,$A0
	ld c,$20
	jq .set_colors
.subdir:
	ld a,$3F
	ld c,$1A
	jq .set_colors
.device:
	ld a,$B5
	ld c,0
	jq .set_colors
.hidden:
	ld a,$1F
	ld c,0
.set_colors:
	ld (bos.lcd_text_fg),a
	ld a,c
	ld (bos.lcd_text_bg),a
.draw_file_name:
	ld hl,bos.fsOP6+1
	push iy,hl
	call bos.fs_CopyFileName
	pop hl,iy
	dec hl
	ld (hl),$9
	call bos.gui_PrintLine
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
	ld sp,ix
	pop ix
	ret
.tab_str:
	db $9,$9,0


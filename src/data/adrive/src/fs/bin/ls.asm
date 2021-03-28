	jq ls_main
	db "FEX",0
ls_main:
	call ti._frameset0
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq nz,.non_null_dir
	ld hl,bos.current_working_dir
.non_null_dir:
	push hl
	call bos.gui_Print
	call bos.gui_NewLine
	pop hl
	push hl
	ld a,(hl)
	cp a,'/'
	jq nz,.open
	inc hl
	ld a,(hl)
	or a,a
	ld hl,$040200
.open:
	call nz,bos.fs_OpenFile
	jq c,.fail
	pop bc
	ld bc,$C
	add hl,bc
	ld hl,(hl)
	push hl
	call bos.fs_GetSectorAddress
	ex (sp),hl
	pop iy
.loop:
	ld a,(iy)
	or a,a
	jq z,.exit
	inc a
	jq z,.exit
	cp a,bos.fsentry_deleted+1
	jq z,.next
	cp a,'.'+1
	jq z,.hidden
	bit bos.fd_hidden,(iy+$B) ;check if file is hidden
	jq z,.not_hidden
.hidden:
	ld a,$1F
	jq .set_cursor_color
.not_hidden:
	bit bos.fd_subdir,(iy+$B)
	jq z,.not_dir
	ld a,$07
	jq .set_cursor_color
.not_dir:
	ld a,$FF
.set_cursor_color:
	ld (bos.lcd_text_fg),a
	bit bos.fd_readonly,(iy+$B)
	jq z,.not_readonly
	db $3E ;ld a,... (0xAF happens to be a good color for this)
.not_readonly:
	xor a,a
	ld (bos.lcd_text_bg),a
	ld hl,bos.fsOP6+1
	push iy,hl
	call bos.fs_CopyFileName
	pop hl,iy
	dec hl
	ld (hl),$9
	call bos.gui_Print
	call bos.gui_NewLine
.next:
	lea iy,iy+16
	jq .loop
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


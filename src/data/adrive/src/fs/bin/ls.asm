	jq ls_main
	db "FEX",0
ls_main:
	ld hl,-18
	call ti._frameset
	ld a,(bos.lcd_text_bg)
	ld (ix-10),a
	ld a,(bos.lcd_text_fg)
	ld (ix-11),a
	xor a,a
	sbc hl,hl
	ld (ix-12),a
	ld (ix-6),hl
	ld a,(ix+6)
	dec a
	jr z,.no_dir_argument
	syscall _argv_1
	ld a,(hl)
	cp a,'-'
	jr nz,.check_non_null_dir_arg
	inc hl
	ld a,(hl)
	cp a,'o'
	jr z,.output_to_file
.show_help_info:
	ld hl,.str_HelpInfo
	call bos.gui_PrintLine
	jq .exit
.output_to_file:
	ld (ix-12),1
	ld a,(ix+6)
	cp a,3
	jr c,.show_help_info
	syscall _argv_2
	ld (ix-15),hl
	ld hl,ti.pixelShadow
	ld (ix-18),hl
	ld a,(ix+6)
	cp a,4
	jr c,.no_dir_argument
	syscall _argv_3
	ld a,(hl)
.check_non_null_dir_arg:
	or a,a
	jq nz,.non_null_dir
.no_dir_argument:
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
	jq c,.done

	ld b,32
.inner_loop:
	ld de,(hl)
	ld a,(de)
	or a,a
	jq z,.done
	inc a
	jq z,.done
	ld a,e
	or a,d
	inc hl
	inc hl
	or a,(hl)
	jq z,.done
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
	call bos.gui_PrintLine
	pop hl
	ld a,(ix-12)
	or a,a
	push hl
	call nz,.write_string_to_buffer
	call bos.sys_Free ;free the buffer allocated by fs_CopyFileName
	pop bc
	ld a,(ix-10)
	ld (bos.lcd_text_bg),a
.next:
	pop bc,hl
	djnz .inner_loop
	jq .dirlist_loop
.done:
	ld a,(ix-10)
	ld (bos.lcd_text_bg),a
	ld a,(ix-11)
	ld (bos.lcd_text_fg),a
	ld a,(ix-12)
	or a,a
	jr z,.exit
	ld de,ti.pixelShadow
	ld hl,(ix-18)
	sbc hl,de
	jr .exit
	; push hl,de
	; ld c,0
	; push bc
	; ld bc,(ix-15)
	; push bc
	; call bos.fs_DeleteFile
	; call bos.fs_WriteNewFile
	; pop bc,bc,bc,bc
	; jr nc,.exit
	; ld hl,.str_FailedToWrite
	; call bos.gui_PrintLine
	; jr .fail
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

.write_string_to_buffer:
	push iy,hl
	ld hl,(ix-18)
	push hl
	call ti._strcpy
	pop bc,hl,iy
	dec de
	bit bos.fd_subdir,(iy+$B)
	jr z,.write_string_not_a_dir
	ld a,'/'
	ld (de),a
	inc de
.write_string_not_a_dir:
	ld a,$A
	ld (de),a
	inc de
	ld (ix-18),de
	ret

; .str_FailedToWrite:
	; db "Failed to write output file.", 0
.str_HelpInfo:
	db "ls [dir]", 0

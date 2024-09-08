explorer_configure_theme:
	call .main
	ret po
	ld a,(hl)
	inc hl
	and a,(hl)
	inc hl
	and a,(hl)
	inc hl
	and a,(hl)
	dec hl
	dec hl
	dec hl
	inc a
	ret z
	ld a,(hl)
	call explorer_load_config.setbgcolor
	inc hl
	ld a,(hl)
	ld (explorer_statusbar_color),a
	inc hl
	ld a,(hl)
	call explorer_load_config.setfgcolor
	inc hl
	ld a,(hl)
	ld (explorer_foreground2_color),a
	ld (bos.lcd_text_fg2),a
	jq explorer_write_config
.main:
	ld bc,display_items_num_x*display_items_num_y*3  ; clear out the dir listing so we don't draw it
	ld hl,explorer_dirlist_buffer
	ld (hl),b
	push hl
	pop de
	inc de
	ldir
	inc bc
	ld (.max_selection),bc
	call draw_background
	ld hl,explorer_themes_file
	push hl
	call bos.fs_OpenFile
	call c,.create_theme_dat
	call bos.fs_GetFilePtr
	pop de
	ld (.smc_themes_ptr),hl
	ld (.smc_themes_len),bc
	ld a,c
	or a,b
	jq z,.done_displaying_themes
	ld de,display_margin_top
	ld (.smc_y),de
.display_themes_loop:
	push bc,hl
	ex hl,de
	ld hl,0
.smc_y:=$-3
	push hl
	ld c,9
	add hl,bc
	ld (.smc_y),hl
	ld hl,0
.max_selection:=$-3
	inc hl
	ld (.max_selection),hl
	ld bc,display_margin_left+11
	push bc,de
	call gfx_PrintStringXY
	pop bc,bc,bc,hl,bc
.nextline:
	xor a,a
	cpir
	jp po,.done_displaying_themes
	ld a,4
.display_theme_loop_skip_4b_loop:
	cpi
	jp po,.done_displaying_themes
	dec a
	jq nz,.display_theme_loop_skip_4b_loop
	jq .display_themes_loop
.done_displaying_themes:
	ld hl,themes_option_strings
	push hl
	call draw_taskbar
	pop bc
	; ld hl,(.smc_y)
	; ld de,display_margin_left+11
	; ld bc,str_CustomTheme
	; push hl,de,bc
	; call gfx_PrintStringXY
	; pop bc,bc,bc
	or a,a
	sbc hl,hl
	ld (.smc_selection),hl
	push hl
	call gfx_SetDraw
	pop hl
.menu_loop:
	call gfx_BlitBuffer
	ld bc,(explorer_foreground2_color)
	push bc
	call gfx_SetColor
	pop bc
	ld bc,7
	push bc,bc
	ld hl,0
.smc_selection:=$-3
	push hl
	pop de
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,de
	ld de,display_margin_top
	add hl,de
	push hl
	ld e,display_margin_left
	push de
	call gfx_FillRectangle
	pop bc,bc,bc,bc
.input_loop:
	call bos.sys_WaitKeyCycle
	cp a,ti.skClear
	ret z
	cp a,ti.skYequ
	jq z,.custom
	cp a,ti.skWindow
	jq z,.background_image
	cp a,ti.skEnter
	jq z,.select
	cp a,ti.skUp
	jq z,.cursor_up
	cp a,ti.skDown
	jq z,.cursor_down
	cp a,ti.sk2nd
	jq nz,.input_loop
.select:
	ld hl,0
.smc_themes_ptr:=$-3
	ld bc,0
.smc_themes_len:=$-3
	ld de,(.smc_selection)
.get_theme_loop:
	xor a,a
	cpir
	ret po
	ld a,d
	or a,e
	ret z
	dec de
	ld a,4
.next_theme_loop_skip_4b_loop:
	cpi
	ret po
	dec a
	jr nz,.next_theme_loop_skip_4b_loop
	jr .get_theme_loop
.cursor_down:
	ld hl,(.smc_selection)
	inc hl
	ld de,(.max_selection)
	or a,a
	sbc hl,de
	add hl,de
	jq nc,.menu_loop
	jq .set_cursor
.cursor_up:
	ld hl,(.smc_selection)
	add hl,de
	or a,a
	sbc hl,de
	jq z,.menu_loop
	dec hl
.set_cursor:
	ld (.smc_selection),hl
	jq .menu_loop

.create_theme_dat:
	ld hl,explorer_themes_file
	ld de,explorer_themes_default
	ld bc,explorer_themes_default.len
	push bc,de
	ld c,0
	push bc,hl
	call bos.fs_WriteNewFile
	pop bc,bc,bc,bc
	ret

.background_image:
	ld hl,$FF0000
	ld de,str_ImageFilePrompt
	call explorer_input_file_name
	jp explorer_load_config.setbackgroundimage_entryhl

.colors:
	db 4 dup 0
.exit:
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc,bc ; pop caller of explorer_configure_theme.main
	ret
.custom:
	ld a,(explorer_background_color)
	ld (.colors+0),a
	ld a,(explorer_statusbar_color)
	ld (.colors+1),a
	ld a,(explorer_foreground_color)
	ld (.colors+2),a
	ld a,(explorer_foreground2_color)
	ld (.colors+3),a
	ld hl,.colors
.customloop:
	push hl
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
	ld bc,10
	ld (.drawbox_x_smc),bc
	ld a,(.colors+0)
	ld (explorer_background_color),a
	ld a,(.colors+1)
	ld (explorer_statusbar_color),a
	ld a,(.colors+2)
	ld (explorer_foreground_color),a
	ld a,(.colors+3)
	ld (explorer_foreground2_color),a

	call draw_background
	ld a,(explorer_background_color)
	call .drawbox
	ld a,(explorer_statusbar_color)
	call .drawbox
	ld a,(explorer_foreground_color)
	call .drawbox
	ld a,(explorer_foreground2_color)
	call .drawbox
	ld c,0
	push bc
	call gfx_SetColor
	pop bc
	ld bc,16
	push bc
	ld c,60
	push bc
	ld bc,0
.custom_selected_x:=$-3
	push bc
	call gfx_HorizLine
	pop bc,bc,bc
	call gfx_BlitBuffer
	ld a,20
	call ti.DelayTenTimesAms
	call bos.sys_WaitKey
	pop hl
	cp a,ti.skRight
	jq nz,.dontprevcolor
	dec hl
.dontprevcolor:
	cp a,ti.skLeft
	jq nz,.dontnextcolor
	inc hl
.dontnextcolor:
	ld c,a
	ld a,l
	cp a, (.colors-1) and $FF
	jq nz,.notunder
	ld l, (.colors+3) and $FF
.notunder:
	cp a, (.colors+4) and $FF
	jq nz,.notover
	ld l, .colors and $FF
.notover:
	ld a,c
	cp a,ti.skUp
	jq nz,.dontdecrementcolor
	dec (hl)
.dontdecrementcolor:
	cp a,ti.skDown
	jq nz,.dontincrementcolor
	inc (hl)
.dontincrementcolor:
	cp a,ti.skClear
	jq z,.exit
	cp a,ti.skEnter
	jq nz,.customloop
	call explorer_write_config
	pop hl
	ret c ; return to caller of explorer_configure_theme if malloc failed
	jp (hl) ; otherwise return to caller of explorer_configure_theme.main

.drawbox:
	ld c,a
	push bc
	call gfx_SetColor
	pop bc
	ld bc,16
	push bc,bc
	ld bc,40
	push bc
	ld bc,0
.drawbox_x_smc:=$-3
	push bc
	call gfx_FillRectangle
	pop bc,bc,bc,de
	ld hl,(.drawbox_x_smc)
	add hl,bc
	inc hl
	ld (.drawbox_x_smc),hl
	ret


explorer_write_config:
	ld de,512
	push de
	call bos.sys_Malloc
	pop bc
	ret c
	push hl
	ex (sp),iy
	push iy
	db $11,"BGC"
	ld a,(explorer_background_color)
	call .write_entry_byte
	db $11,"SBC"
	ld a,(explorer_statusbar_color)
	call .write_entry_byte
	db $11,"FGC"
	ld a,(explorer_foreground_color)
	call .write_entry_byte
	db $11,"FG2"
	ld a,(explorer_foreground2_color)
	call .write_entry_byte
	ld hl,32
	ld (.file_size_smc),hl
	ld hl,0
explorer_background_file:=$-3
	add hl,de
	or a,a
	sbc hl,de
	jq z,.no_background_loaded
	db $11,"IMG"
	ld (iy),de
	ld (iy+3),"="
	ld (iy+4),'"'
	push hl,hl
	pea iy+5
	call ti._strcpy ; copy the path
	ld a,$A
	ld (de),a ; write the newline
	dec de
	ld a,'"'  ; write the end quote
	ld (de),a
	pop bc,bc
	call ti._strlen
	ld bc,(.file_size_smc)
	add hl,bc
	ld c,7 ; (.file_size_smc) should always be less than 256 initially
	add hl,bc
	ld (.file_size_smc),hl
	pop bc
.no_background_loaded:
	ld hl,explorer_config_file
	push hl
	call bos.fs_OpenFile
	call nc,bos.fs_DeleteFile
	pop hl,bc
	ld de,0
.file_size_smc := $-3
	push de,bc
	ld e,0
	push de,hl
	call bos.fs_WriteNewFile
	pop bc,bc,bc,bc,iy
	ret

; input iy pointer to output
; input de entry key string
; input a byte to write
.write_entry_byte:
	ld c,a
	ld (iy),de
	ld (iy+3),'='
	ld (iy+4),'x'
	rrca
	rrca
	rrca
	rrca
	and a,$F
	add a,'0'
	cp a,'9'+1
	jq c,.under_10
	add a,'A'-1-'9'
.under_10:
	ld (iy+5),a
	ld a,c
	and a,$F
	add a,'0'
	cp a,'9'+1
	jq c,.under_10_2
	add a,'A'-1-'9'
.under_10_2:
	ld (iy+6),a
	ld (iy+7),$A
	lea iy,iy+8
	ret

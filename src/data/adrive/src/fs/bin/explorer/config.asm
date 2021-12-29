explorer_configure_theme:
	call .main
	ld a,(de)
	ld (explorer_background_color),a
	inc de
	ld a,(de)
	ld (explorer_statusbar_color),a
	inc de
	ld a,(de)
	ld (explorer_foreground_color),a
	inc de
	ld a,(de)
	ld (explorer_foreground2_color),a
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
	ld hl,(.smc_y)
	ld de,display_margin_left+11
	ld bc,str_CustomTheme
	push hl,de,bc
	call gfx_PrintStringXY
	pop bc,bc,bc
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
	ld a,$A
	cpir
	dec de
	ld a,d
	or a,e
	ret z
	ld a,4
.next_theme_loop_skip_4b_loop:
	cpi
	ret po
	dec a
	jq nz,.next_theme_loop_skip_4b_loop
	jq .custom
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

.colors:
	db 4 dup 0
.exit:
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc,bc ; pop caller of explorer_configure_theme.main
	ret
.custom:
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
	call draw_background
	call gfx_BlitBuffer
	ld hl,.colors
	ld a,(explorer_background_color)
	ld (hl),a
	ld a,(explorer_statusbar_color)
	ld (.colors+1),a
	ld a,(explorer_foreground_color)
	ld (.colors+2),a
	ld a,(explorer_foreground2_color)
	ld (.colors+3),a
.custom_menu:
	push hl
	call bos.sys_WaitKey
	pop hl
	cp a,ti.skUp
	jq nz,.dontprevcolor
	dec hl
.dontprevcolor:
	cp a,ti.skDown
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
	cp a,ti.skLeft
	jq nz,.dontdecrementcolor
	dec (hl)
.dontdecrementcolor:
	cp a,ti.skRight
	jq nz,.dontincrementcolor
	inc (hl)
.dontincrementcolor:
	cp a,ti.skClear
	jq z,.exit
	cp a,ti.skEnter
	jq nz,.custom
	call explorer_write_config
	pop hl
	ret c ; return to caller of explorer_configure_theme if malloc failed
	jp (hl) ; return to caller of explorer_configure_theme.main

explorer_write_config:
	ld de,512
	push de
	call bos.sys_Malloc
	pop bc
	ret c
	push hl,hl
	ex (sp),iy
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
	ld hl,0
explorer_background_file:=$-3
	add hl,de
	or a,a
	sbc hl,de
	jq z,.no_background_loaded
	db $11,"IMG"
	ld (iy),de
	ld a,'"'
	ld (iy+3),a
	push hl
	pea iy+4
	call ti._strcpy ; copy the path
	ld a,$A
	ld (de),a ; write the newline (which follows the end quote)
	dec de
	ld a,'"'  ; write the end quote
	ld (de),a
	pop bc,bc
.no_background_loaded:
	ld hl,explorer_config_file
	push hl
	call bos.fs_OpenFile
	call c,bos.fs_DeleteFile
	pop hl
	ld de,512 ; low byte is 0 so we can also use this as the flags argument
	push iy,de,de,hl
	call bos.fs_WriteNewFile
	pop bc,bc,bc,bc,iy
	ret

; input iy pointer to output
; input de entry key string
; input a byte to write
.write_entry_byte:
	ld c,a
	ld (iy),de
	ld a,'x'
	ld (iy+3),a
	ld a,c
	rrca
	rrca
	rrca
	rrca
	and a,$F
	add a,'0'
	cp a,'9'+1
	jq c,.under_10
	add a,'A'-'9'+1
.under_10:
	ld (iy+4),a
	ld a,c
	and a,$F
	add a,'0'
	cp a,'9'+1
	jq c,.under_10_2
	add a,'A'-'9'+1
.under_10_2:
	ld (iy+5),a
	ld a,$A
	ld (iy+6),a
	lea iy,iy+6
	ret

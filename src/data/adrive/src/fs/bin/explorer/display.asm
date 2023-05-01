
explorer_taskbar_menu:
	push hl
	call draw_background
	call draw_taskbar
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	pop hl
	sub a,ti.skGraph
	cp a,5
	ret nc
	add a,a
	add a,a
	add a,3
	ld bc,0
	ld c,a
	add hl,bc
	jp (hl)

draw_background:
	ld c,0
	push bc
	call gfx_SetTransparentColor
	ld l,1
	ex (sp),hl
	call gfx_SetDraw
;draw background
	ld l,$08
explorer_background_color:=$-1
	ex (sp),hl
	call gfx_FillScreen
	call gfx_SetTextTransparentColor
	call gfx_SetTextBGColor
	ld l,$FF
explorer_foreground_color:=$-1
	ex (sp),hl
	call gfx_SetTextFGColor
	pop hl
	ld hl,$FF0000
explorer_background_image_full:=$-3
	ld a,(hl)
	or a,a
	jq z,.dont_draw_background_image
	inc hl
	ld de,ti.vRam + ti.lcdWidth*ti.lcdHeight + ti.lcdWidth*20
	ld bc,ti.lcdWidth*220
	ldir
	jq .dont_draw_background_image_sprite
.dont_draw_background_image:
	ld hl,$FF0000
explorer_background_image_sprite:=$-3
	ld a,(hl)
	or a,a
	jq z,.dont_draw_background_image_sprite
	ld bc,20
	push bc
	ld c,32
	push bc,hl
	call gfx_TransparentSprite
	pop bc,bc
.dont_draw_background_image_sprite:
;draw status bar
	ld l,$11
explorer_statusbar_color:=$-1
	push hl
	call gfx_SetColor
	ld hl,statusbar_height
	ex (sp),hl
	ld bc,320
	push bc
	or a,a
	sbc hl,hl
if statusbar_y = 0
	push hl,hl
else
	ld bc,statusbar_y
	push bc,hl
end if
	call gfx_FillRectangle
	pop bc,bc,bc,bc

	ld bc,1
	push bc,bc
	call gfx_SetTextXY
	pop bc,bc

	ld hl,(current_working_dir)
	ld bc,20
	call explorer_display_bc_chars

	call ti.usb_IsBusPowered
	push af
	; jr z,.not_charging
	; ld c,$E4
	; push bc
	; call gfx_SetTextFGColor
	; pop bc
	; ld hl,_charging_icon
	; jq .print_icon
; .not_charging:
	ld a,0
explorer_battery_status:=$-1
	ld l,$C0
	inc a
	jr z,.draw_battery
	ld l,$C2
	dec a
	jr z,.draw_battery
	ld l,$E7
	dec a
	jr z,.draw_battery
	ld l,$87
	dec a
	jr z,.draw_battery
	ld l,$47
	dec a
	jr z,.draw_battery
	ld l,$07
.draw_battery:
	push hl
	call gfx_SetTextFGColor
	pop bc
	pop af
	ld hl,_battery_icon
	jr z,.print_icon
	ld hl,_charging_icon
.print_icon:
	ld bc,1
	push hl,bc
	ld b,c
	ld c,300-256
	push bc
	call gfx_SetTextXY
	pop bc,bc
	ld a,2
	call explorer_set_text_scale
	pop hl
	call explorer_print_icon
	ld a,1
	call explorer_set_text_scale
	ld bc,(explorer_foreground_color)
	push bc
	call gfx_SetTextFGColor
	pop bc
;	jq explorer_display_diritems

explorer_display_diritems:
	push ix
	ld hl,display_margin_top+2
	ld (.y_pos),hl
	ld ix,explorer_dirlist_buffer
	ld c,display_items_num_y
.outer_loop:
	ld b,display_items_num_x
	ld hl,display_margin_left+1
	ld (.x_pos),hl
.inner_loop:
	push bc
	ld hl,(.x_pos)
	ld de,(.y_pos)
	push de,hl
	call gfx_SetTextXY
	pop bc,bc
	ld bc,(ix)
	ld a,(ix+2)
	or a,c
	or a,b
	jq z,.skip
	call .main
	lea ix,ix+3
.skip:
	ld bc,0
.x_pos:=$-3
	ld hl,display_item_width
	add hl,bc
	ld (.x_pos),hl
	pop bc
	djnz .inner_loop
	ld hl,0
.y_pos:=$-3
	ld de,display_item_height
	add hl,de
	ld (.y_pos),hl
	dec c
	jq nz,.outer_loop
	pop ix
	ret
.main:
	ld bc,(.y_pos)
	push bc
	ld bc,(.x_pos)
	push bc
	call gfx_SetTextXY
	pop bc,bc
	ld hl,(ix)
	push hl
	call bos.fs_CopyFileName
	pop bc
	ld a,(hl)
	cp a,'.'
	jr nz,.main_draw_regular_file_name
	push hl
	call gfx_PrintString
	call bos.sys_Free
	pop hl
	jq .dont_draw_extension
.main_draw_regular_file_name:
	ld b,8
.main_draw_file_name_loop:
	ld a,(hl)
	or a,a
	jq z,.main_done_drawing_file_name
	cp a,'.'
	jq z,.main_done_drawing_file_name
	ld c,a
	inc hl
	push hl,bc
	call gfx_PrintChar
	pop bc,hl
	djnz .main_draw_file_name_loop
.main_done_drawing_file_name:
	push hl
	call bos.sys_Free ; free the memory allocated by fs_CopyFileName
	pop hl
	ld a,(hl)
	cp a,'.'
	jq nz,.dont_draw_extension ; dont draw the file extension if there isn't one
	inc hl
	push hl
	push hl
	call ti._strlen
	ld bc,8
	or a,a
	sbc hl,bc
	pop hl
	jr c,.main_draw_file_ext_under_8_chars
; cap extension draw size to 8 characters
	add hl,bc
	xor a,a
	ld (hl),a
.main_draw_file_ext_under_8_chars:
	ld hl,(.y_pos)
	ld bc,9
	add hl,bc
	push hl
	ld hl,(.x_pos)
	push hl
	call gfx_SetTextXY
	pop bc
	ld l,'.'
	ex (sp),hl
	call gfx_PrintChar
	pop bc
	call gfx_PrintString
	pop bc
.dont_draw_extension:
	ld hl,(.y_pos)
	ld bc,26
	add hl,bc
	push hl
	ld hl,(.x_pos)
	push hl
	call gfx_SetTextXY
	pop bc,bc
	ld hl,(ix)
	ld bc,bos.fsentry_fileattr
	add hl,bc
	ld a,(hl)
	inc hl
	ld de,(hl)
	push de
	bit bos.fd_system,a
	call nz,.system
	bit bos.fd_device,a
	call nz,.device
	bit bos.fd_subdir,a
	call nz,.subdir
	call bos.fs_GetSectorAddress
	pop bc
	ld a,(hl)
	inc hl
	cp a,$EF
	jq nz,.notEF7B
	ld a,(hl)
	dec hl
	cp a,$7B
	jq nz,.notEF7B
	inc hl
	inc hl
	ld a,(hl)
	dec hl
	dec hl
	dec hl
	cp a,$18 ;jr opcode
	jq z,.skip2
	cp a,$C3 ;jp opcode
	ret nz
	jq .skip4
.notEF7B:
	cp a,$18 ;jr opcode
	jq z,.skip2
	cp a,$C3 ;jp opcode
	ret nz
.skip4:
	inc hl
	inc hl
.skip2:
	inc hl
	inc hl ;bypass 4-byte header
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	cp a,7 ;denotes external icon
	jq z,.external_icon
	dec a
	ret nz ;don't display an icon if there isn't one
.display_icon:
	ld bc,0
explorer_sprite_temp:=$-3
	push bc,hl
	call gfx_ScaleSprite
	pop bc,bc
	ld hl,(.y_pos)
	ld bc,display_item_height-19
	add hl,bc
	push hl
	ld hl,(.x_pos)
	ld bc,display_item_width-19
	add hl,bc
	ld de,(explorer_sprite_temp)
	push hl,de
	call gfx_TransparentSprite
	pop bc,bc,bc
	ret
.external_icon:
	push hl
	call bos.fs_GetFilePtr
	pop de
	jq c,.display_missing_icon
.load_icon_file:
	ld a,c
	or a,b
	ret z
	ld bc,(hl)
	ex hl,de
	db $21,"SPT"
	xor a,a
	sbc hl,de
	ret nz
	ex hl,de
	inc hl
	inc hl
	inc hl
	or a,(hl)
	ret nz
	inc hl
	or a,(hl)
	inc hl
	ret z
	ld a,(hl)
	or a,a
	ret z
	dec hl
	jq .display_icon
.display_missing_icon:
	ld hl,str_MissingIconFile
	push hl
	call bos.fs_GetFilePtr
	pop de
	ret c
	jq .display_icon
.subdir:
	ld hl,_subdir_icon
	jq explorer_print_icon
.system:
	ld hl,_system_icon
	jq explorer_print_icon
.device:
	ld hl,_device_icon
explorer_print_icon:
	ld c,$80
	push af,hl,bc
	call gfx_SetCharData
	ld l,$80
	ex (sp),hl
	call gfx_PrintChar
	pop bc,bc,af
	ret
; ****|    |
; ** *| *  |
; *** |* * |
; ** *|* * |
; ** *| *  |
; _readonly_icon:
	; db $00,$00,$F0,$D4,$EA,$DA,$D4
; *** |* * |
; *   |* * |
;  *  | *  |
;   * | *  |
; *** | *  |
_system_icon:
	db $00,$00,$EA,$8A,$44,$24,$E4
; **  |* * |
; * * |* * |
; * * |* * |
; * * |* * |
; **  | *  |
_device_icon:
	db $00,$00,$CA,$AA,$AA,$AA,$C4
; *** |    |
; *  *|    |
; ****|*** |
; *   |  * |
; *   |  * |
; ****|**  |
_subdir_icon:
	db $00,$E0,$90,$FE,$82,$82,$FC,$00
;     |    |
;     |    |
;     |    |
;     |    |
; *  *| *  |
;     |    |
_dotdot_icon:
	db $00,$00,$00,$00,$00,$00,$54,$00
;    |*** |
;   *|* **|
;   *|   *|
;   *|   *|
;   *|   *|
;   *|****|
_battery_icon:
	db $00,$0E,$1B,$11,$11,$11,$11,$1F
;    |*** |
;   *|* **|
;   *|  **|
;   *| ***|
;   *| * *|
;   *|****|
_charging_icon:
	db $00,$0E,$1B,$13,$17,$15,$11,$1F


draw_taskbar:
	push ix
	ld hl,6
	add hl,sp
	ld hl,(hl)
	ld ix,(hl)
	ld hl,taskbar_height
	push hl
	ld hl,320
	push hl
	or a,a
	sbc hl,hl
	ld bc,taskbar_y
	push bc,hl
	call gfx_FillRectangle
	call gfx_HorizLine
	pop bc,bc,bc,bc

;draw taskbar items
	ld b,5
	ld hl,taskbar_item_x
	ld (.taskbar_item_x),hl
.draw_taskbar_loop:
	push bc
	ld hl,taskbar_item_y
	push hl
	ld bc,(ix)
	push bc
	call gfx_GetStringWidth
	pop bc
	srl l ;divide by 2, hl should always be less than 256 here
	ex hl,de
	ld hl,0
.taskbar_item_x:=$-3
	or a,a
	sbc hl,de
	push hl,bc
	add hl,de
	ld e,taskbar_item_width
	add hl,de
	ld (.taskbar_item_x),hl
	call gfx_PrintStringXY
	pop bc,bc,bc,bc
	lea ix,ix+3
	djnz .draw_taskbar_loop
	pop ix
	ret

explorer_display_bc_chars:
	ld a,(hl)
	or a,a
	ret z
	push bc,hl
	call ti._strlen
	pop bc,de
	or a,a
	sbc hl,de
	add hl,de
	jq nc,.loop_entry
	push bc
	pop hl
	jq .loop
.loop_entry:
	add hl,bc
	or a,a
	sbc hl,de
	push hl
	ld hl,_dotdot_icon
	call explorer_print_icon
	pop hl
.loop:
	ld a,(hl)
	inc hl
	or a,a
	ret z
	ld c,a
	push hl,bc
	call gfx_PrintChar
	pop bc,hl
	jq .loop

explorer_set_text_scale:
	ld c,a
	push bc,bc
	call gfx_SetTextScale
	pop bc,bc
	ret


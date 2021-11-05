
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'
include 'include/threading.inc'

display_items_num_x   := 4
display_items_num_y   := 5
display_item_width    := 310/display_items_num_x
display_item_height   := 190/display_items_num_y
display_margin_top    := 25
display_margin_bottom := 20
display_margin_left   := 5
display_margin_right  := 5

statusbar_height      := 18
statusbar_y           := 0

taskbar_height        := 18
taskbar_y             := 240-taskbar_height
taskbar_item_x        := 33
taskbar_item_y        := 241-taskbar_height
taskbar_item_width    := 64

assert taskbar_height < 231

org ti.userMem
	jr explorer_init
	db "REX",0
explorer_init:
	;pop bc
	;pop hl
	;push hl
	;push bc
	;ld (explorer_args),hl

	di
	ld (_SaveIX),ix
	ld (_SaveSP),sp
	call load_libload
	jq z,explorer_init_2
.fail:
	scf
	sbc hl,hl
	ret
explorer_init_2:
	EnableOSThreading
	ld bc,258
	push bc
	call bos.sys_Malloc
	pop bc
	jq c,explorer_init.fail
	ld (explorer_sprite_temp),hl
	ld bc,$1010
	ld (hl),bc
	ld hl,bos.current_working_dir
	ld (current_working_dir),hl

	ld hl,explorer_config_dir
	ld c,1 shl bos.fd_subdir
	push bc,hl
	call bos.fs_CreateDir
	pop bc,bc

	ld de,explorer_config_file
	push de
	call bos.fs_GetFilePtr
	pop de
	jq c,.dontloadconfig
	ld a,b
	or a,c
	jq z,.dontloadconfig
	push bc,hl
	call explorer_load_config
	pop bc,bc
.dontloadconfig:
	ld a,(explorer_foreground_color)
	ld (bos.lcd_text_fg),a
	ld a,(explorer_background_color)
	ld (bos.lcd_text_bg),a
	ld a,7
explorer_foreground2_color:=$-1
	ld (bos.lcd_text_fg2),a
	xor a,a
	ld (explorer_cursor_x),a
	ld (explorer_cursor_y),a
	; call ti.GetBatteryStatus
	; ld (battery_status),a
	ld hl,bos.thread_map + 2
	bit 7,(hl)
	jq nz,explorer_dont_run_preload
	ld hl,explorer_preload_file
	push hl
	call bos.fs_OpenFile
	ld hl,explorer_preload_cmd
	ex (sp),hl
	ld hl,str_CmdExecutable
	push hl
	call nc,bos.sys_ExecuteFile
	pop bc,bc
explorer_dont_run_preload:
; explorer_load_extensions:
	; ld hl,2
	; push hl
	; ld bc,display_items_num_x * display_items_num_y
	; push bc
	; ld bc,explorer_extensions_dir
	; push bc
	; ld hl,explorer_dirlist_buffer
	; add hl,bc
	; or a,a
	; sbc hl,bc
	; push hl
	; call nz,bos.fs_DirList
	; pop bc,bc,bc,bc
	; add hl,bc
	; or a,a
	; sbc hl,bc
	; jq z,explorer_dirlist
explorer_dirlist:
	ld hl,0
explorer_files_skip:=$-3
	push hl
	ld bc,display_items_num_x * display_items_num_y
	push bc
	ld bc,0
current_working_dir:=$-3
	push bc
	ld hl,explorer_dirlist_buffer
	push hl
	call bos.fs_DirList
	pop bc,bc,bc,bc
	ld (explorer_max_selection),hl
explorer_main:

; load the file descriptor and file name of the file selected by the cursor
	ld a,(explorer_cursor_y)
assert display_items_num_x = 4
	add a,a ;multiply y by 4
	add a,a
	sbc hl,hl
	ld l,a
	ld a,(explorer_cursor_x)
	add a,l ;add x
	ld l,a
	ld bc,0
explorer_max_selection:=$-3
	or a,a
	sbc hl,bc
	jq nc,.no_file_selected
	add hl,bc
	add a,a ;multiply result by 3
	add a,l
	ld l,a
	ld bc,explorer_dirlist_buffer
	add hl,bc ;index directory list buffer
	ld hl,(hl)
	ld (explorer_selected_file_desc),hl
	push hl
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.sys_Free
	pop bc
	call bos.fs_CopyFileName
	ld (explorer_dirname_buffer),hl
	pop bc
	jq .draw_background
.no_file_selected:
	scf
	sbc hl,hl
	ld (explorer_dirname_buffer),hl
	ld (explorer_selected_file_desc),hl
.draw_background:
	call draw_background

;draw taskbar
	ld hl,taskbar_item_strings
	push hl
	call draw_taskbar
	pop bc

	; ld a,(battery_status)
	; ld l,$07
	; cp a,2
	; jq nc,.battery_good
	; ld l,$E4
; .battery_good:
	; ex (sp),hl
	; call gfx_SetColor
	; ld hl,14
	; ex (sp),hl
	; ld hl,0
; battery_status:=$-3
	; add hl,hl
	; add hl,hl
	; add hl,hl
	; push hl
	; ld bc,2
	; push bc
	; ld bc,280
	; push bc
	; call gfx_FillRectangle
	; pop bc,bc,bc

	ld hl,(explorer_foreground2_color)
	push hl
	call gfx_SetColor
	ld hl,display_item_height+1
	ex (sp),hl
	ld bc,display_item_width+1
	push bc
	ld hl,0
explorer_cursor_y:=$-3
	ld h,display_item_height
	mlt hl
	ld bc,display_margin_top-1
	add hl,bc
	push hl
	ld hl,0
explorer_cursor_x:=$-3
	ld h,display_item_width
	mlt hl
	ld bc,display_margin_left-1
	add hl,bc
	push hl
	call gfx_Rectangle
	pop bc,bc,bc,bc
	call gfx_BlitBuffer
.key_loop:
	call bos.sys_WaitKeyCycle
	dec a
	jq z,explorer_cursor_down
	dec a
	jq z,explorer_cursor_left
	dec a
	jq z,explorer_cursor_right
	dec a
	jq z,explorer_cursor_up
	cp a,ti.skYequ - 4
	jq z,_exit
	cp a,ti.skClear - 4
	jq z,explorer_main
	cp a,ti.skDel - 4
	jq z,explorer_delete_file
	cp a,ti.skWindow - 4
	jq z,.callpathout
	cp a,ti.skAlpha - 4
	jq z,.callpathout
	cp a,ti.skZoom - 4
	jq z,.quickmenu
	cp a,ti.skTrace - 4
	jq z,.optionsmenu
	cp a,ti.skGraph - 4
	jq z,open_terminal
	cp a,ti.skEnter - 4
	jq z,.click
	cp a,ti.sk2nd - 4
	jq nz,.key_loop
.click:
	xor a,a
	ld (.force_editing_file),a
.open_file_entry:
	ld a,(.force_editing_file)
	or a,a
	jq nz,.open_file
	ld iy,0
explorer_selected_file_desc:=$-3
	bit bos.fd_subdir,(iy+bos.fsentry_fileattr)
	jq z,.open_file
	call .path_into
	jq explorer_dirlist
.callpathout:
	call .pathout
	jq explorer_dirlist
.open_file:
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.fs_GetFilePtr
	pop de
	ld a,0
.force_editing_file:=$-1
	or a,a
	jq nz,.edit_file
	ld a,c
	or a,b
	jq z,.edit_file_run_cedit
	ld a,(hl)
	inc hl
	cp a,$18 ;jr
	jq z,.skip1
	cp a,$C3 ;jp
	jq z,.skip3
	cp a,$EF
	jq nz,.edit_file
	ld a,(hl)
	inc hl
	cp a,$7B
	jq z,.exec_file
.edit_file:
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.fs_GetFilePtr
	pop de
	jq .checkfileloop_entry
.checkfileloop: ; check whether the file contains only text characters (range 0x01 to 0x7F)
	ld a,(hl)
	or a,a
	jq z,.edit_file_run_memedit
	adc a,a
	jq c,.edit_file_run_memedit
.checkfileloop_nextbyte:
	dec bc
.checkfileloop_entry:
	ld a,c
	or a,b
	jq nz,.checkfileloop
.edit_file_run_cedit:
	ld hl,str_ceditexe
	jq .edit_file_run_hl
.edit_file_run_memedit:
	ld hl,str_memeditexe
.edit_file_run_hl:
	ld de,$FF0000
explorer_dirname_buffer:=$-3
	ld a,(de)
	or a,a
	jq z,explorer_call_file
	push hl,de
	ld hl,bos.reservedRAM
	push hl
	call ti._strcpy
	pop bc,de,hl
	jq explorer_call_file
.skip3:
	inc hl
	inc hl
.skip1:
	inc hl
	ld de,(hl)
	db $21 ;ld hl,...
	db 'FEX' ;Flash EXecutable
	or a,a
	sbc hl,de
	jq z,.exec_file
	db $21 ;ld hl,...
	db 'REX' ;Ram EXecutable
	or a,a
	sbc hl,de
	jq z,.exec_file
	db $21 ;ld hl,...
	db 'CRX' ;Compressed Ram Executable
	or a,a
	sbc hl,de
	jq z,.exec_file
	db $21 ;ld hl,...
	db 'TRX' ;Threaded Ram Executable
	or a,a
	sbc hl,de
	jq z,.exec_file
	db $21 ;ld hl,...
	db 'TFX' ;Threaded Flash Executable
	or a,a
	sbc hl,de
	jq nz,.edit_file ;if it's neither a Flash Executable nor a Ram Executable, edit it
.exec_file:
	ld hl,(explorer_dirname_buffer)
	jq explorer_call_file_noargs
.quickmenu:
	ld hl,quickmenu_item_strings
	jq .drawmenu
.optionsmenu:
	ld hl,options_item_strings
.drawmenu:
	push hl
	call draw_background
	call draw_taskbar
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	pop hl
	sub a,ti.skGraph
	cp a,5
	jq nc,explorer_main
	ld bc,explorer_dirlist
	push bc
	add a,a
	add a,a
	add a,3
	ld bc,0
	ld c,a
	add hl,bc
	jp (hl)

.pathout:
	ld hl,(current_working_dir) ; path into '..' entry
	push hl
	call bos.fs_ParentDir ; get parent directory of working directory
	pop bc
	ret c ; if failed to malloc within fs_ParentDir
	jq .path_into_setcurdir
.path_into:
	ld hl,(explorer_dirname_buffer)
	add hl,de
	or a,a
	sbc hl,de
	ret z
	ld a,(hl)
	or a,a
	ret z
.path_into_dir:
	; ld hl,(explorer_dirname_buffer)
	ld de,(current_working_dir)
	push hl,de
	call bos.fs_JoinPath ; join(cwd, fname)
	ex (sp),hl
	push hl
	call bos.sys_Free ; free old cwd
	pop bc,hl,bc
.path_into_setcurdir:
	ld (current_working_dir),hl
	xor a,a
	ld (explorer_cursor_x),a
	ld (explorer_cursor_y),a
	ld de,bos.current_working_dir
	ld bc,255
	ldir
	ld (de),a
	ret

explorer_delete_file:
	ld hl,str_ConfirmDelete
	ld bc,display_margin_bottom-9
	ld de,display_margin_left+11
	push bc,de,hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	cp a,ti.skEnter
	jq nz,explorer_main
	ld hl,(explorer_dirname_buffer)
	ld de,(current_working_dir)
	push hl,de
	call bos.fs_JoinPath
	ex (sp),hl
	call bos.fs_DeleteFile
	call bos.sys_Free ; free file path allocated by fs_JoinPath
	pop bc,bc
	jq explorer_dirlist

_exit:
	call bos._HomeUp
	xor a,a
	sbc hl,hl
.loadix:
	ld ix,0
_SaveIX:=$-3
	ld sp,0
_SaveSP:=$-3
	jp bos.gfx_SetDefaultFont

open_terminal:
	ld hl,str_CmdExecutable
explorer_call_file_noargs:
	ld de,$FF0000
explorer_call_file:
	ld sp,(_SaveSP)
	ld ix,(_SaveIX)
	push de,hl
	call bos.gfx_SetDefaultFont
	pop hl,de
	ld bc,str_ExplorerExecutable
	jp bos.sys_CallExecuteFile

;gfx_PrintStrings:
;	ld bc,30
;	ld (.y_pos),bc
;.loop:
;	push hl
;	ld hl,(hl)
;	ld a,(hl)
;	or a,a
;	jq z,.exit
;	ld bc,10
;.y_pos:=$-3
;	push bc
;	ld c,0
;	push bc,hl
;	call gfx_PrintStringXY
;	pop bc,bc,bc
;	ld hl,(.y_pos)
;	ld bc,10
;	add hl,bc
;	ld (.y_pos),hl
;	pop hl
;	inc hl
;	inc hl
;	inc hl
;	jq .loop
;.exit:
;	pop hl
;	ret

explorer_load_config:
	ld hl,-6
	call ti._frameset
	ld hl,(ix+6)
	ld bc,(ix+9)
.loop:
	ld a,(hl)
	cp a,'#'
	jq z,.nextline
.check:
	push hl,bc
	ld bc,.next ; push this so we can conditionally "return" to .next instead of using many conditional jumps
	push bc
	ld bc,(hl)
	ld (ix-3),bc
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	cp a,'='
	ret nz ;fail if invalid statement
	ld a,(hl)
	inc hl
	cp a,'x'
	jq z,.hexbytearg
	cp a,'"'
	jq z,.stringargument
	ld d,'0'
	sub a,d
	ret c
	cp a,10
	ret nc
; decimal number argument
	ld e,a
; check next two digits are valid
	ld a,(hl)
	inc hl
	sub a,d
	cp a,10
	ret nc
	ld a,(hl)
	sub a,d
	cp a,10
	ret nc
	dec hl

	ld a,e
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	add a,(hl) ; add next character offset from '0'
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	add a,(hl) ; add next character offset from '0'
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	jq .setnumvalue
.stringargument:
	pop bc
	push bc
	ld (ix-6),hl
.readstringloop:
	cpir ;find end of string
	dec hl
	ld a,(hl)
	cp a,$5C
	jq nz,.foundendofstring
	inc hl
	inc hl
	ld a,'"'
	jq .readstringloop
.foundendofstring:
	ld de,(ix-6)
	or a,a
	sbc hl,de
	inc hl
	push de,hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	ret c ;go to next line if failed to malloc
	dec bc
	ld (ix-6),de
	ldir
	xor a,a
	ld (de),a
	ld bc,(ix-3)
	db $21,"DIR"
str_dir:=$-3
	or a,a
	sbc hl,bc
	jq z,.setcurdir
	db $21,"IMG"
str_img:=$-3
	or a,a
	sbc hl,bc
	jq z,.setbackgroundimage
	db $21,"FNT"
str_fnt:=$-3
	or a,a
	sbc hl,bc
	ret nz
.setfont:
	ld hl,(ix-6)
	push hl
	call bos.fs_GetFilePtr
	pop de
	ret c
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	db $21,"FNT"
	or a,a
	sbc hl,bc
	ret nz
	push de
	call bos.gfx_SetFont
	ld hl,(bos.font_spacing)
	ex (sp),hl
	call gfx_SetFontSpacing
	ld hl,(bos.font_data)
	ex (sp),hl
	call gfx_SetFontData
	pop bc
	ret
.setcurdir:
	ld (current_working_dir),de
	ret
.hexbytearg:
	ld a,(hl)
	inc hl
	call .nibble
	inc a
	ret z ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,a
	add a,a
	add a,a
	add a,a
	ld e,a
	ld a,(hl)
	inc hl
	call .nibble
	inc a
	ret z ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,e
.setnumvalue:
	db $21, "BGC"
str_bgc:=$-3
	or a,a
	sbc hl,bc
	jq z,.setbgcolor
	db $21, "FGC"
str_fgc:=$-3
	or a,a
	sbc hl,bc
	jq z,.setfgcolor
	db $21, "SBC"
str_sbc:=$-3
	or a,a
	sbc hl,bc
	jq z,.setstatusbarcolor
	db $21, "FG2"
str_fg2:=$-3
	or a,a
	sbc hl,bc
	ret nz
	ld (explorer_foreground2_color),a
	ret
.next:
	pop bc,hl
.nextline:
	ld a,$A
	cpir
	jp pe,.loop
.done:
	ld sp,ix
	pop ix
	ret

.setbgcolor:
	ld (explorer_background_color),a
	ret

.setfgcolor:
	ld (explorer_foreground_color),a
	ret

.setstatusbarcolor:
	ld (explorer_statusbar_color),a
	ret

.setbackgroundimage:
	ld hl,(ix-6)
	push hl
	call bos.fs_GetFilePtr
	pop de
	ret c
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	db $21,"IMG"
	or a,a
	sbc hl,bc
	jq z,.setbackgroundimg
	db $21,"SPT"
	sbc hl,bc
	ret nz ; return if unsupported image format
	ex hl,de
	ld a,(hl)
	inc hl
	or a,a
	jq z,.setimagesprite ; non-compressed image
; compressed image
	cp a,'7'
	ret nz ; return if unsupported image format
; decompress into the back buffer so we can scale into safeRAM
	ld de,ti.vRam + ti.lcdHeight*ti.lcdWidth
	push de,hl,de
	call bos.util_Zx7Decompress
	pop bc,bc,hl
	jq .setimagesprite
.setbackgroundimagespt:
	ex hl,de
.setimagesprite:
	ld b,(hl)
	inc hl
	ld a,(hl)
	dec hl
	ex hl,de
	ld hl,bos.safeRAM
	push hl,de
	ld (explorer_background_image_sprite),hl
	ld d,255
	ld e,b
	ld (hl),d
	inc hl
	ex hl,de
	mlt hl
	ld bc,0
	ld c,a
	call ti._idivu
	ex hl,de
	ld (hl),e
	call gfx_ScaleSprite
	pop bc,bc
	jq .set_background_file
.setbackgroundimg:
	ld a,(de)
	cp a,'7'
	ret nz ; dont load if the image is not compressed
	ex hl,de
	ld de,bos.safeRAM
	ld (explorer_background_image_full),de
	ldi
	push hl,de
	call bos.util_Zx7Decompress
	pop bc,bc
.set_background_file:
	ld hl,(ix-6)
	ld (explorer_background_file),hl
	ret


.nibble:
	sub a,'0'
	jq c,.invalid
	cp a,10
	ret c
	sub a,7 ;subtract this from 'A'-'0' to get 10
	cp a,16 ;check if in range 'A'-'F'
	ret c ;return if in range
	sub a,$20 ;subtract 'a'-'A' to interpret lowercase
	cp a,16
	ret c ;return if within range 'a'-'f'
	ccf
.invalid:
	sbc a,a
	ret


explorer_cursor_rightoverflow:
	xor a,a
	ld (explorer_cursor_x),a
explorer_cursor_down:
	ld a,(explorer_cursor_y)
	cp a,display_items_num_y-1
	jq nc,explorer_page_down
	inc a
	ld (explorer_cursor_y),a
	jq explorer_main
explorer_cursor_leftoverflow:
	ld a,display_items_num_x-1
	ld (explorer_cursor_x),a
explorer_cursor_up:
	ld a,(explorer_cursor_y)
	or a,a
	jq z,explorer_page_up
	dec a
	ld (explorer_cursor_y),a
	jq explorer_main
explorer_cursor_left:
	ld a,(explorer_cursor_x)
	or a,a
	jq z,explorer_cursor_leftoverflow
	dec a
	ld (explorer_cursor_x),a
	jq explorer_main
explorer_cursor_right:
	ld a,(explorer_cursor_x)
	cp a,display_items_num_x-1
	jq nc,explorer_cursor_rightoverflow
	inc a
	ld (explorer_cursor_x),a
	jq explorer_main
explorer_page_down:
	ld hl,(explorer_files_skip)
	ld bc,display_items_num_x
	add hl,bc
	ld (explorer_files_skip),hl
	jq explorer_dirlist
explorer_page_up:
	ld hl,(explorer_files_skip)
	ld bc,display_items_num_x
	sbc hl,bc
	jq c,explorer_main
	ld (explorer_files_skip),hl
	jq explorer_dirlist


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
	ld bc,ti.lcdWidth*200
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
	jq nz,.main_draw_regular_file_name
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
	ld hl,(.y_pos)
	ld bc,9
	add hl,bc
	push hl
	ld hl,(.x_pos)
	ld c,display_item_width-30
	add hl,bc
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
	bit bos.fd_readonly,a
	call nz,.readonly
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
	jq explorer_print_icon
.readonly:
	ld hl,_readonly_icon
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
_readonly_icon:
	db $00,$00,$F0,$D4,$EA,$DA,$D4
; *** |*** |
; *   |*   |
;  *  | *  |
;   * |  * |
; *** |*** |
_system_icon:
	db $00,$00,$EE,$88,$44,$22,$EE
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
; *  *| *  |
_dotdot_icon:
	db $00,$00,$00,$00,$00,$00,$54,$54


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
	srl l ;divide by 2, hl should be less than 256 in this use case
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

explorer_create_new_file:
	ld hl,$FF0000
	ld de,str_NewFileNamePrompt
	call explorer_input_file_name
	ld bc,0
	push bc,bc,hl
	call bos.fs_CreateFile
	pop bc,bc,bc
	ret

explorer_cut_file:
	db $3E
explorer_copy_file:
	xor a,a
	ld (explorer_cut_file_indicator),a
	ld hl,(explorer_dirname_buffer)
	push hl
	call ti._strlen
	inc hl
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	ret c
	ld (bos.copy_buffer),de
	ldir
	ret

explorer_paste_file:
	ld hl,(bos.copy_buffer)
	add hl,bc
	xor a,a
	sbc hl,bc
	ret z
	or a,(hl)
	ret z

	push hl
	call bos.fs_BaseName
	push hl
	ld de,str_DestinationFilePrompt
	call explorer_input_file_name
	or a,a
	jq z,.cancel
	ex (sp),hl
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.fs_ParentDir
	ex (sp),hl
	call bos.fs_JoinPath ; join(dirname(dest), basename(src))
	ld (.destfile),hl
	call bos.sys_Free ; free memory allocated by parentdir
	pop bc
	call bos.sys_Free ; free memory allocated by basename
	pop bc,bc

	ld hl,0
.destfile:=$-3
	add hl,bc
	or a,a
	sbc hl,bc
	ret z ; return if failed to get destination file name
	ld a,0
explorer_cut_file_indicator:=$-1
	or a,a
	jq z,.copy
	push hl,bc
	call bos.fs_MoveFile
	scf
	sbc hl,hl
	ld (bos.copy_buffer),hl
.cancel:
	pop bc,bc
	ret
.copy:
	push hl,bc
	call bos.fs_GetFilePtr ; returns bc=len, hl=ptr, a=attr
	pop de,de
	push bc,hl
	ld c,a
	push bc,de
	call bos.fs_WriteNewFile ; copy file in copy buffer to the current working directory
	pop bc,bc,bc,bc
	ret

explorer_input_file_name:
	xor a,a
	ld b,a
	mlt bc
	ld (bos.curcol),a
	ld a,23
	ld (bos.currow),a
	push de
	ld de,explorer_temp_name_input_buffer
	ld c,14
	ldir
	pop hl
	call bos.gui_PrintString
	ld hl,explorer_temp_name_input_buffer
	ld bc,14
	push bc,hl
.paste_wait_input:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.paste_wait_input
	pop hl,bc
	ret

explorer_temp_name_input_buffer:
	db 14 dup 0

; --------------------------------------------------------------

load_libload:
	ld hl,libload_name
	push hl
	call bos.fs_GetFilePtr
	pop bc
	jq c,.notfound
	ld   de,.relocations
	ld   bc,.notfound
	push   bc
	jp   (hl)

.notfound:
	xor   a,a
	inc   a
	ret

.relocations:
	db	$C0, "GRAPHX", $00, 11
gfx_SetColor:
	jp 6
gfx_FillScreen:
	jp 15
gfx_SetDraw:
	jp 27
gfx_Blit:
	jp 33
gfx_PrintChar:
	jp 42
gfx_PrintString:
	jp 51
gfx_PrintStringXY:
	jp 54
gfx_SetTextXY:
	jp 57
gfx_SetTextBGColor:
	jp 60
gfx_SetTextFGColor:
	jp 63
gfx_SetTextTransparentColor:
	jp 66
gfx_SetFontData:
	jp 69
gfx_SetFontSpacing:
	jp 72
gfx_GetStringWidth:
	jp 78
gfx_HorizLine:
	jp 93
gfx_Rectangle:
	jp 105
gfx_FillRectangle:
	jp 108
gfx_TransparentSprite:
	jp 174
gfx_SetTransparentColor:
	jp 225
gfx_ScaleSprite:
	jp 246
gfx_SetCharData:
	jp 276

	xor   a,a      ; return z (loaded)
	pop   hl      ; pop error return
	ret

libload_name:
	db   "/lib/LibLoad.dll", 0
.len := $ - .

gfx_BlitBuffer:
	ld c,1
	push bc
	call gfx_Blit
	pop bc
	ret

; run_usbrecv_app:
	; ld bc,255
	; push bc
	; call bos.sys_Malloc
	; pop bc
	; ret c
	; push bc,hl
	; ld (hl),b
	; push hl
	; pop de
	; inc de
	; ldir
	; ld hl,input_source_string
	; call bos.gui_DrawConsoleWindow
; usbrecv_input_src:
	; call bos.gui_InputNoClear
	; cp a,2
	; jq nc,usbrecv_input_src
	; pop hl,bc
	; or a,a
	; ret z
	; push hl
	; xor a,a
	; cpir
	; dec hl
	; ld (hl),' '
	; inc hl
	; push bc,hl
	; call bos.gui_NewLine
	; ld hl,input_dest_string
	; call bos.gui_Print
; usbrecv_input_dest:
	; call bos.gui_InputNoClear
	; cp a,2
	; jq nc,usbrecv_input_dest
	; pop bc,bc,hl
	; or a,a
	; ret z
	; ex hl,de
	; ld hl,str_UsbRecvExecutable
	; jq explorer_call_file

; run_fexplore_app:
	; ld bc,255
	; push bc
	; call bos.sys_Malloc
	; pop bc
	; ret c
	; push bc,hl
	; ld (hl),b
	; push hl
	; pop de
	; inc de
	; ldir
	; ld hl,input_dir_string
	; call bos.gui_DrawConsoleWindow
; fexplore_input_dir:
	; call bos.gui_InputNoClear
	; cp a,2
	; jq nc,fexplore_input_dir
	; pop hl,bc
	; or a,a
	; ret z
	; ex hl,de
	; ld hl,str_FExploreExecutable
	; jq explorer_call_file

run_power_app:
	ld hl,str_OffExecutable
	jq explorer_call_file_noargs

explorer_configure_theme:
	call .main
	ld c,1
	push af,de,bc
	call gfx_SetDraw
	pop bc,de,af
	or a,a
	jq z,.custom
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
.custom:
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
	
	ret
.colors:
	db 4 dup 0
.exit:
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
	ret
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
	ld de,0
.smc_themes_ptr:=$-3
	ld bc,0
.smc_themes_len:=$-3
	ld hl,(.smc_selection)
.get_theme_loop:
	ex hl,de
	ld a,$A
	cpir
	ex hl,de
	add hl,bc
	or a,a
	sbc hl,bc
	ret z
	ld a,4
.next_theme_loop_skip_4b_loop:
	cpi
	ret po
	dec a
	jq nz,.next_theme_loop_skip_4b_loop
	ret
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
	pop iy
	ld hl,explorer_config_file
	ld de,512 ; low byte is 0 so we can also use this as the flags argument
	push de,de,hl
	call bos.fs_OpenFile
	call c,bos.fs_CreateFile
	pop bc,bc,bc

	ex hl,de
	ld hl,512
	ex (sp),hl
	push hl,de
	call bos.fs_WriteFile
	pop bc,bc,bc
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

; run_updater_program:
	; ld bc,1
	; push bc,bc
	; ld bc,str_PressEnterConfirm
	; push bc
	; call gfx_PrintStringXY
	; pop bc,bc,bc
	; call bos.sys_WaitKeyCycle
	; cp a,9
	; ret nz
	; ld hl,str_UpdaterExecutable
	; ld de,$FF0000
	; jq explorer_call_file

; run_usbrun_app:
	; ld bc,255
	; push bc
	; call bos.sys_Malloc
	; pop bc
	; ret c
	; push bc,hl
	; ld (hl),b
	; push hl
	; pop de
	; inc de
	; ldir
	; ld hl,input_program_string
	; call bos.gui_DrawConsoleWindow
; usbrun_input_program:
	; call bos.gui_InputNoClear
	; cp a,2
	; jq nc,usbrun_input_program
	; pop hl,bc
	; or a,a
	; ret z
	; ex hl,de
	; ld hl,str_UsbRunExecutable
	; jq explorer_call_file

taskbar_item_strings:
	dl .strings
.strings:
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "recovery",0
.l2:
	db "back",0
.l3:
	db "file",0
.l4:
	db "options",0
.l5:
	db "cmd",0

options_item_strings:
	dl .strings
	jp explorer_configure_theme
	db 12 dup $C9
	jp run_power_app
.strings:
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "power"
.l2:
.l3:
.l4:
	db 0
.l5:
	db "theme",0

quickmenu_item_strings:
	dl .strings
	jp explorer_main.edit_file
	jp explorer_paste_file
	jp explorer_cut_file
	jp explorer_copy_file
	jp explorer_create_new_file
.strings:
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "new",0
.l2:
	db "copy",0
.l3:
	db "cut",0
.l4:
	db "paste",0
.l5:
	db "edit",0

explorer_themes_default:
	db "BOS Blue",0,$08,$11,$FF,$07
	db "BOS Green",0,$0C,$03,$AF,$C7
	db "BOS Red",0,$C0,$A0,$E6,$E2
.len := $-.

; input_dir_string:
	; db "Input path on usb to explore.",$A,0
; input_source_string:
	; db "Input file on usb to recieve.",$A,0
; input_dest_string:
	; db "Input destination file in filesystem.",$A,0
; input_program_string:
	; db "Input path to binary on usb to execute.",$A,0
str_ConfirmDelete:
	db "Press enter to confirm deletion.",0
str_PressEnterConfirm:
	db "Press enter to confirm.",0
str_DestinationFilePrompt:
	db "New name? ",0
str_NewFileNamePrompt:
	db "File name? ",0
str_CustomTheme:
	db "Custom Theme",0
; str_UsbRecvExecutable:
	; db "/bin/usbrecv",0
str_OffExecutable:
	db "off",0
; str_UsbRunExecutable:
	; db "/bin/usbrun",0
; str_UpdaterExecutable:
	; db "/bin/updater",0
str_CmdExecutable:
	db "cmd",0
str_ExplorerExecutable:
	db "explorer",0
explorer_config_dir:
	db "/etc/config/explorer",0
explorer_themes_file:
	db "/etc/config/explorer/themes.lst",0
explorer_config_file:
	db "/etc/config/explorer/explorer.cfg",0
explorer_preload_cmd:
	db "cmd -x "
explorer_preload_file:
	db "/etc/config/explorer/prerun.cfg",0

explorer_default_directory:
	db "/home/user",0
str_memeditexe:
	db "memedit",0
str_ceditexe:
	db "cedit",0
str_MissingIconFile:
	db "/etc/explorer/missing.ico"
explorer_background_image_sprite_default:
	db 0
; explorer_extensions_dir:
	; db "/opt/explorer/",0
explorer_dirlist_buffer:
	dl display_items_num_x * display_items_num_y dup 0


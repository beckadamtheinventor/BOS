
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

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

explorer_dirname_buffer := bos.safeRAM

org ti.userMem
	; jq explorer_init
	; db "REX",0
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
	ld bc,display_items_num_x * display_items_num_y * 3
	push bc
	call bos.sys_Malloc
	pop bc
	jq c,.nodirlistbuffer
	ld (explorer_dirlist_buffer),hl
.nodirlistbuffer:
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
explorer_dirlist:
	ld hl,1
explorer_files_skip:=$-3
	push hl
	ld bc,display_items_num_x * display_items_num_y
	push bc
	ld bc,0
current_working_dir:=$-3
	push bc
	ld hl,0
explorer_dirlist_buffer:=$-3
	add hl,bc
	or a,a
	sbc hl,bc
	push hl
	call nz,bos.fs_DirList
	pop bc,bc,bc,bc
	ld (explorer_max_selection),hl
explorer_main:
	call draw_background

;draw taskbar
	ld hl,taskbar_item_strings
	call draw_taskbar

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

	ld a,(explorer_dirlist_buffer)
	or a,a
	call nz,explorer_display_diritems

	ld hl,(explorer_foreground2_color)
	push hl
	call gfx_SetColor
	ld hl,display_item_height+2
	ex (sp),hl
	ld bc,display_item_width+2
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
	or a,a
	jq z,.key_loop
	cp a,1
	jq z,explorer_cursor_down
	cp a,2
	jq z,explorer_cursor_left
	cp a,3
	jq z,explorer_cursor_right
	cp a,4
	jq z,explorer_cursor_up
	cp a,53
	jq z,_exit_return_1337
	cp a,15
	jq z,explorer_main
	cp a,52
	jq z,.optionsmenu
	cp a,51
	jq z,.quickmenu
	cp a,49
	jq z,open_terminal
	cp a,48
	jq z,.filemenu
	cp a,9
	jq z,.click
	cp a,54
	jq z,.key_loop
.click:
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
	jq nc,explorer_main
	add hl,bc
	add a,a ;multiply result by 3
	add a,l
	ld l,a
	ld bc,(explorer_dirlist_buffer)
	add hl,bc ;index directory list buffer
	push iy
	ld iy,(hl)
	ld bc,explorer_dirname_buffer
	push iy,bc
	call bos.fs_CopyFileName
	pop bc,iy
	bit bos.fd_subdir,(iy+bos.fsentry_fileattr)
	push iy
	jq z,.open_file
	call .path_into
	pop bc,iy
	jq explorer_dirlist
.open_file:
	ld hl,(iy+bos.fsentry_filesector)
	bit bos.fd_subfile,(iy + bos.fsentry_fileattr)
	jq z,.open_file_by_sector
	ex.s hl,de
	lea hl,iy
	ld l,0
	res 0,h
	add hl,de
	jq .check_file_magic
.open_file_by_sector:
	ex (sp),hl
	call bos.fs_GetSectorAddress
.check_file_magic:
	pop bc
	pop iy
	ld a,c
	or a,b
	jq z,.edit_file
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
	ld hl,str_memeditexe
	ld de,explorer_dirname_buffer
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
	jq nz,.edit_file ;if it's neither a Flash Executable nor a Ram Executable, open it in memedit
.exec_file:
	ld hl,explorer_dirname_buffer
	jq explorer_call_file_noargs
.filemenu:
	jq explorer_main
.quickmenu:
;draw background
	call draw_background
;draw quick menu taskbar strings
	ld hl,quickmenu_item_strings
	call draw_taskbar
	call bos.sys_WaitKeyCycle
	; - TODO - actually make quickmenu functionality
	jq explorer_main
.optionsmenu:
;draw background
	call draw_background
;draw options menu taskbar strings
	ld hl,options_item_strings
	call draw_taskbar
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	cp a,53
	jq z,run_power_app
	jq explorer_main
.path_into:
	ld hl,-9
	call ti._frameset
	ld hl,(ix+6)
	ld a,(hl)
	cp a,'.'
	jq nz,.path_into_dir
	inc hl
	cp a,(hl)
	ld a,' '
	jq nz,.path_into_checkspace
	inc hl
	cp a,(hl)
	jq nz,.path_into_dir ;'..something' entry, though idk why you'd do that anyways
	ld hl,(current_working_dir) ;path into '..' entry
	push hl
	call bos.fs_ParentDir ;get parent directory of working directory
	jq c,.path_into_return ;if failed to malloc within fs_ParentDir
	ld (ix-9),hl
	pop bc
	jq .path_into_setcurdir
.path_into_checkspace:
	cp a,(hl)
	jq z,.path_into_return ;return if pathing into '.' entry
.path_into_dir:
	ld hl,explorer_dirname_buffer
	ld bc,(ix+6)
	push bc,hl
	call bos.fs_CopyFileName
	call ti._strlen ;get length of directory we're pathing into
	ld (ix-3),hl
	ex (sp),hl
	ld hl,(current_working_dir)
	push hl
	call ti._strlen ;get length of current working directory
	ld (ix-6),hl
	pop bc,bc
	add hl,bc
	inc hl
	inc hl
	inc hl
	push hl
	call bos.sys_Malloc
	ld (ix-9),hl
	ex hl,de
	pop bc
	jr c,.path_into_return
	ld hl,(current_working_dir)
	ld bc,(ix-6)
	ldir ;copy current working directory
	dec de
	ld a,(de)
	inc de
	ld c,'/'
	cp a,c
	jq z,.path_into_dontaddpathsep
	ld a,c
	ld (de),a
	inc de
.path_into_dontaddpathsep:
	ld hl,explorer_dirname_buffer
	ld bc,(ix-3)
	ldir ;copy directory we're pathing into
	ld a,'/'
	ld (de),a
	inc de
	xor a,a
	ld (de),a
.path_into_setcurdir:
	ld hl,(ix-9)
	push hl
	ld de,(current_working_dir)
	push de,hl
	call ti._strlen
	ex (sp),hl
	pop bc,de
	inc bc
	ldir ;copy new working directory
	call bos.sys_Free ;free temp working directory
	pop bc
	xor a,a
	ld (explorer_cursor_x),a
	ld (explorer_cursor_y),a
.path_into_return:
	ld sp,ix
	pop ix
	ret

explorer_join_file_name:
	ld hl,explorer_dirname_buffer
	push hl
	call ti._strlen
	ld (.tmplen),hl
	ld hl,(current_working_dir)
	ex (sp),hl
	call ti._strlen
	ld (.tmplen2),hl
	pop bc
	ld bc,0
.tmplen:=$-3
	add hl,bc
	inc hl
	push hl
	call bos.sys_Malloc
	pop bc
	ret c
	push hl
	ex hl,de
	ld hl,(current_working_dir)
	ld bc,0
.tmplen2:=$-3
	ldir
	ld hl,explorer_dirname_buffer
	ld bc,(.tmplen)
	ldir
	xor a,a
	ld (de),a
	pop hl
	ret


_exit_return_1337:
	call bos._HomeUp
	ld hl,1337
	jq _exit.loadix
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
	call bos.sys_FreeRunningProcessId
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
	ld bc,(hl)
	ld (ix-3),bc
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	cp a,'='
	jq nz,.next ;fail if invalid statement
	ld a,(hl)
	inc hl
	cp a,'x'
	jq z,.hexbytearg
	cp a,'"'
	jq nz,.next
	pop bc
	push bc
	ld (ix-6),hl
.readstringloop:
	cpir ;find end of string
	dec hl
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
	jq c,.next ;go to next line if failed to malloc
	dec bc
	ld (ix-6),de
	ldir
	xor a,a
	ld (de),a
	ld bc,(ix-3)
	db $21,"DIR"
	or a,a
	sbc hl,bc
	jq z,.setcurdir
	db $21,"FNT"
	or a,a
	sbc hl,bc
	jq nz,.next
.setfont:
	ld hl,(ix-6)
	push hl
	call bos.fs_GetFilePtr
	pop de
	jq c,.next
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	db $21,"FNT"
	or a,a
	sbc hl,bc
	jq nz,.next
	push hl
	call bos.gfx_SetFont
	ld hl,(bos.font_spacing)
	ex (sp),hl
	call gfx_SetFontSpacing
	ld hl,(bos.font_data)
	ex (sp),hl
	call gfx_SetFontData
	pop bc
	jq .next
.setcurdir:
	ld (current_working_dir),de
	jq .next
.hexbytearg:
	push bc
	ld a,(hl)
	inc hl
	call .nibble
	inc a
	jq z,.next_extrapop ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,a
	add a,a
	add a,a
	add a,a
	ld c,a
	ld a,(hl)
	inc hl
	call .nibble
	inc a
	jq z,.next_extrapop ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,c
	pop bc
	db $21, "BGC"
	or a,a
	sbc hl,bc
	jq z,.setbgcolor
	db $21, "FGC"
	or a,a
	sbc hl,bc
	jq z,.setfgcolor
	db $21, "SBC"
	or a,a
	sbc hl,bc
	jq z,.setstatusbarcolor
	db $21, "FG2"
	or a,a
	sbc hl,bc
	jq z,.setfg2color
	db $3E
.next_extrapop:
	pop bc
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
	jq .next

.setfgcolor:
	ld (explorer_foreground_color),a
	jq .next

.setstatusbarcolor:
	ld (explorer_statusbar_color),a
	jq .next

.setfg2color:
	ld (explorer_foreground2_color),a
	jq .next

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


explorer_display_diritems:
	push ix
	ld hl,display_margin_top+2
	ld (.y_pos),hl
	ld ix,(explorer_dirlist_buffer)
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
	push bc
	ld bc,explorer_dirname_buffer
	push bc
	call bos.fs_CopyFileName
	call ti._strlen
	ld a,l
	cp a,9
	jq c,.nameunder9chars ;if name is less than 9 characters there's no need to split the string
	ex (sp),hl
	pop bc
	push hl
	ld a,'.'
	cpir
	dec hl
	ld (hl),0
	inc hl
	push hl
	ld hl,(.y_pos)
	ld bc,9
	add hl,bc
	push hl
	ld hl,(.x_pos)
	ld c,display_item_width-40
	add hl,bc
	push hl
	call gfx_SetTextXY ;set text position a line down for extension
	pop bc
	ld l,a
	ex (sp),hl
	call gfx_PrintChar
	pop bc
	call gfx_PrintString
	ld hl,(.y_pos)
	ex (sp),hl
	ld bc,(.x_pos)
	push bc
	call gfx_SetTextXY
	pop bc,bc
.nameunder9chars:
	call gfx_PrintString
	ld hl,(.y_pos)
	ld bc,18
	add hl,bc
	ld bc,(.x_pos)
	push hl,bc
	call gfx_SetTextXY ;set text position two lines down for file flags
	pop bc,bc

	pop bc,hl

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
	ld bc,display_item_height-17
	add hl,bc
	push hl
	ld hl,(.x_pos)
	ld bc,display_item_width-17
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
	ld hl,.subdir_str
	jq .printflagstr
.system:
	ld hl,.system_str
	jq .printflagstr
.device:
	ld hl,.device_str
	jq .printflagstr
.readonly:
	ld hl,.readonly_str
.printflagstr:
	push af,hl
	call gfx_PrintString
	pop bc,af
	ret
.readonly_str:
	db "R/O ",0
.system_str:
	db "sys ",0
.device_str:
	db "dev ",0
.subdir_str:
	db "dir ",0

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

;draw status bar
	ld l,$11
explorer_statusbar_color:=$-1
	ex (sp),hl
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
	ret

draw_taskbar:
	push hl
	ex (sp),ix
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
	jq explorer_call_file

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
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "recovery",0
.l2:
	db "ctrl",0
.l3:
	db "file",0
.l4:
	db "options",0
.l5:
	db "cmd",0

options_item_strings:
dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "power",0
.l2:
	db 0
.l3:
	db 0
.l4:
	db 0
.l5:
	db 0

quickmenu_item_strings:
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

input_dir_string:
	db "Input path on usb to explore.",$A,0
input_source_string:
	db "Input file on usb to recieve.",$A,0
input_dest_string:
	db "Input destination file in filesystem.",$A,0
input_program_string:
	db "Input path to binary on usb to execute.",$A,0
str_PressEnterConfirm:
	db "Press enter to confirm.",0
str_UsbRecvExecutable:
	db "/bin/usbrecv",0
str_FExploreExecutable:
	db "/bin/fexplore",0
str_OffExecutable:
	db "/bin/off",0
str_UsbRunExecutable:
	db "/bin/usbrun",0
str_UpdaterExecutable:
	db "/bin/updater",0
str_CmdExecutable:
	db "/bin/cmd",0
str_FilesExecutable:
	db "/bin/files",0
str_ExplorerExecutable:
	db "/bin/explorer",0
explorer_config_file:
	db "/etc/config/explorer/explorer.cfg",0
explorer_default_directory:
	db "/home/user",0
str_memeditexe:
	db "/bin/memedit",0
str_MissingIconFile:
	db "/etc/config/explorer/missing.ico",0


include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

explorer_cursor_x := bos.gui_cursor_x
explorer_cursor_y := bos.gui_cursor_y

org ti.userMem
	jq explorer_init
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
	scf
	sbc hl,hl
	ret
explorer_init_2:
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
	ld a,(explorer_cursor_x)
	or a,a
	sbc hl,hl
	ld (explorer_cursor_x),hl
	cp a,160
	jq nc,.no_set_x
	ld (explorer_cursor_x),a
.no_set_x:
	ld a,(explorer_cursor_y)
	or a,a
	sbc hl,hl
	ld (explorer_cursor_y),hl
	cp a,240
	jq nc,.no_set_y
	ld (explorer_cursor_y),a
.no_set_y:
	;ld bc,256
	;push bc
	;call bos.sys_Malloc
	;pop bc
	;jp c,bos._ErrMemory
	;ld (explorer_path_ptr),hl
	;ld de,0
;explorer_args:=$-3
	;ld a,(de)
	;or a,a
	;jq z,.default_path
	;push hl,de
	;call ti._strlen
	;ex (sp),hl
	;pop bc,de
	;ldir
	;xor a,a
	;ld (de),a
	;jq explore_files
;.default_path:
	;db $11,"C:/"
	;ld (hl),de
	;inc hl
	;inc hl
	;inc hl
	;ld (hl),0
explorer_main:
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
	ld hl,explorer_gui_items
.draw_items_loop:
	ld a,(hl)
	or a,a
	jq z,.done_drawing_gui
	ld iy,(hl)
	inc hl
	inc hl
	inc hl
	push hl
	lea hl,iy+8
	call explorer_jump_hl
	pop hl
	jq .draw_items_loop
.done_drawing_gui:
	ld c,0
	push bc
	call gfx_SetDraw
	ld l,1
	ex (sp),hl
	call gfx_Blit
	pop bc
.key_loop:
	ld c,$FF
explorer_cursor_color:=$-1
	push bc
	call gfx_SetColor
	pop bc
	ld de,(explorer_cursor_y)
	ld hl,(explorer_cursor_x)
	add hl,hl
	push de,hl
	ld bc,9
	add hl,bc
	inc de
	inc de
	push de,hl
	call gfx_Line
	pop bc,bc,bc,bc
	ld hl,(explorer_cursor_x)
	add hl,hl
	ld de,(explorer_cursor_y)
	ex hl,de
	push hl,de
	ld bc,9
	add hl,bc
	inc de
	inc de
	push hl,de
	call gfx_Line
	pop bc,bc,bc,bc
.wait_for_key:
	call bos.sys_AnyKey
	jq z,.wait_for_key
	ld hl,$F5001E
	ld a,(hl)
	or a,a
	jq z,.get_key
	push hl
	call gfx_BlitBuffer
	pop hl
	bit 0,(hl)
	call nz,explorer_cursor_down
	bit 1,(hl)
	call nz,explorer_cursor_left
	bit 2,(hl)
	call nz,explorer_cursor_right
	bit 3,(hl)
	call nz,explorer_cursor_up
	call ti.Delay10ms
	jq .key_loop
.get_key:
	call bos.sys_WaitKeyCycle
	or a,a
	jq z,.key_loop
	cp a,53
	jq z,_exit_return_1337
	cp a,15
	jq z,explorer_main
	cp a,48
	jq z,.click
	cp a,9
	jq z,.click
	cp a,54
	jq nz,.key_loop
.click:
	ld (.click_keycode),a
	ld hl,explorer_gui_items
.click_find_next:
	ld a,(hl)
	or a,a
	jq z,explorer_main
	ld iy,(hl)
	inc hl
	inc hl
	inc hl
.click_find_item_loop:
	ld a,(iy)
	cp a,$C3
	jq nz,.click_find_next
	ld a,(explorer_cursor_x)
	cp a,(iy+12)
	jq c,.click_find_next
	cp a,(iy+14)
	jq nc,.click_find_next
	ld a,(explorer_cursor_y)
	cp a,(iy+13)
	jq c,.click_find_next
	cp a,(iy+15)
	jq nc,.click_find_next
.click_found:
	ld bc,explorer_main
	push bc
	ld a,0
.click_keycode:=$-1
	cp a,48
	jq z,.right_click
	cp a,49
	jq z,.right_click
.left_click:
	jp (iy)
.right_click:
	lea hl,iy+4
explorer_jump_hl:
	jp (hl)
_exit:
	call gfx_ZeroScreen
	call bos._HomeUp
	xor a,a
	sbc hl,hl
.loadix:
	ld ix,0
_SaveIX:=$-3
	ret
_exit_return_1337:
	call gfx_ZeroScreen
	call bos._HomeUp
	ld hl,1337
	jq _exit.loadix

explore_files_main:
	ld hl,str_FilesExecutable
	ld de,$FF0000
	jq explorer_call_file

open_terminal:
	ld hl,str_CmdExecutable
	ld de,$FF0000
explorer_call_file:
	ld sp,0
_SaveSP:=$-3
	ld ix,(_SaveIX)
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
	pop bc
	ret
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
	db $21, "CSR"
	or a,a
	sbc hl,bc
	jq z,.setcursorcolor
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

.setcursorcolor:
	ld (explorer_cursor_color),a
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

explorer_cursor_down:
	ld a,(explorer_cursor_y)
	add a,4
	cp a,238
	ret nc
	ld (explorer_cursor_y),a
	ret
explorer_cursor_up:
	ld a,(explorer_cursor_y)
	cp a,4
	ret c
	sub a,4
	ld (explorer_cursor_y),a
	ret
explorer_cursor_left:
	ld a,(explorer_cursor_x)
	sub a,2
	ret c
	ld (explorer_cursor_x),a
	ret
explorer_cursor_right:
	ld a,(explorer_cursor_x)
	cp a,158
	ret nc
	add a,2
	ld (explorer_cursor_x),a
	ret


load_libload:
	ld hl,libload_name
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.notfound
	ld bc,$0C
	add hl,bc
	ld hl,(hl)
	push hl
	call bos.fs_GetSectorAddress
	pop bc
	ld   de,.relocations
	ld   bc,.notfound
	push   bc
;	ld   bc,$aa55aa
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
gfx_BlitArea:
	jp 39
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
gfx_Line:
	jp 90
gfx_FillRectangle:
	jp 108
gfx_ZeroScreen:
	jp 228

	xor   a,a      ; return z (loaded)
	pop   hl      ; pop error return
	ret

libload_name:
	db   "/lib/LibLoad.dll", 0
.len := $ - .

gfx_BlitBuffer:
	ld bc,10
	push bc,bc
	ld bc,(explorer_cursor_y)
	push bc
	ld a,(explorer_cursor_x)
	or a,a
	sbc hl,hl
	ld l,a
	add hl,hl
	push hl
	ld c,1
	push bc
	call gfx_BlitArea
	pop bc,bc,bc,bc,bc
	ret


explorer_gui_items:
	dl .background
	dl .status_bar
	dl .battery_indicator
	dl .icon_files_app
	dl .icon_terminal_app
	dl .icon_updater_app
	dl .icon_usbrun_app
	dl .icon_fexplore_app
	dl .icon_usbrecv_app
	dl .icon_power_app
	db 0

.icon_usbrecv_app:
	jp .run_usbrecv_app
	ret
	dl 0
	jp .draw_usbrecv_app
	db 122,100,160,160
.run_usbrecv_app:
	ld bc,255
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	push bc,hl
	ld (hl),b
	push hl
	pop de
	inc de
	ldir
	ld hl,.input_source_string
	call bos.gui_DrawConsoleWindow
.usbrecv_input_src:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.usbrecv_input_src
	pop hl,bc
	or a,a
	ret z
	push hl
	xor a,a
	cpir
	dec hl
	ld (hl),' '
	inc hl
	push bc,hl
	call bos.gui_NewLine
	ld hl,.input_dest_string
	call bos.gui_Print
.usbrecv_input_dest:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.usbrecv_input_dest
	pop bc,bc,hl
	or a,a
	ret z
	ex hl,de
	ld hl,str_UsbRecvExecutable
	jq explorer_call_file
.draw_usbrecv_app:
	ld bc,101
	push bc
	ld bc,245
	push bc
	ld bc,.usbrecv_app_string
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret
.usbrecv_app_string:
	db "usb recv",0
.input_source_string:
	db "Input file on usb to recieve.",$A,0
.input_dest_string:
	db "Input destination file in filesystem.",$A,0


.icon_fexplore_app:
	jp .run_fexplore_app
	ret
	dl 0
	jp .draw_fexplore_app
	db 82,100,121,160
.run_fexplore_app:
	ld bc,255
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	push bc,hl
	ld (hl),b
	push hl
	pop de
	inc de
	ldir
	ld hl,.input_dir_string
	call bos.gui_DrawConsoleWindow
.fexplore_input_dir:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.fexplore_input_dir
	pop hl,bc
	or a,a
	ret z
	ex hl,de
	ld hl,str_FExploreExecutable
	jq explorer_call_file
.draw_fexplore_app:
	ld bc,101
	push bc
	ld bc,165
	push bc
	ld bc,.fexplore_app_string
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret
.fexplore_app_string:
	db "usb files",0
.input_dir_string:
	db "Input path on usb to explore.",$A,0


.icon_power_app:
	jp .run_power_app
	ret
	dl 0
	jp .draw_power_app
	db 2,200,41,240
.run_power_app:
	ld hl,str_OffExecutable
	jq explorer_call_file
.draw_power_app:
	ld bc,201
	push bc
	ld bc,5
	push bc
	ld bc,.power_app_string
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret
.power_app_string:
	db "power",0

.icon_updater_app:
	jp .run_updater_program
	ret
	dl 0
	jp .draw_updater_app
	db 122,40,160,100
.draw_updater_app:
	ld bc,41
	push bc
	ld bc,244
	push bc
	ld bc,.updater_app_string
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret
.run_updater_program:
	ld bc,1
	push bc,bc
	ld bc,str_PressEnterConfirm
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	call bos.sys_WaitKeyCycle
	cp a,9
	ret nz
	ld hl,str_UpdaterExecutable
	ld de,$FF0000
	jq explorer_call_file
.updater_app_string:
	db "updater",0

.icon_usbrun_app:
	jp .run_usbrun_app
	ret
	dl 0
	jp .draw_usbrun_app
	db 82,40,121,100
.draw_usbrun_app:
	ld bc,41
	push bc
	ld bc,165
	push bc
	ld bc,.usbrun_app_string
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret
.run_usbrun_app:
	ld bc,255
	push bc
	call bos.sys_Malloc
	pop bc
	ret c
	push bc,hl
	ld (hl),b
	push hl
	pop de
	inc de
	ldir
	ld hl,.input_program_string
	call bos.gui_DrawConsoleWindow
.usbrun_input_program:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.usbrun_input_program
	pop hl,bc
	or a,a
	ret z
	ex hl,de
	ld hl,str_UsbRunExecutable
	jq explorer_call_file
.usbrun_app_string:
	db "usbrun",0
.input_program_string:
	db "Input path to binary on usb to execute.",$A,0


.icon_files_app:
	jp explore_files_main
	ret
	dl 0
	jp .draw_files_app
	db 2,40,41,100
.draw_files_app:
	ld bc,41
	push bc
	ld bc,5
	push bc
	ld bc,.files_app_string
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret
.files_app_string:
	db "files",0

.icon_terminal_app:
	jp open_terminal
	ret
	dl 0
	jp .draw_terminal_app
	db 42,40,81,100
.draw_terminal_app:
	ld bc,41
	push bc
	ld bc,85
	push bc
	ld bc,.terminal_app_string
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret
.terminal_app_string:
	db "terminal",0


.background:
	ret
	dl 0
	ret
	dl 0
	jp .draw_background
	db 0,0,160,240
.draw_background:
	ld c,$08
explorer_background_color:=$-1
	push bc
	call gfx_FillScreen
	call gfx_SetTextTransparentColor
	call gfx_SetTextBGColor
	pop bc
	ld c,$FF
explorer_foreground_color:=$-1
	push bc
	call gfx_SetTextFGColor
	pop bc
.no_op:
	ret

.status_bar:
	ret
	dl 0
	ret
	dl 0
	jp .draw_status_bar
	db 0,0,160,20
.draw_status_bar:
	ld c,$11
explorer_statusbar_color:=$-1
	push bc
	call gfx_SetColor
	ld hl,19
	ex (sp),hl
	ld bc,320
	push bc
	or a,a
	sbc hl,hl
	push hl,hl
	call gfx_FillRectangle
	pop bc,bc,bc,bc
	ret

.battery_indicator:
	jp .get_battery_status
	jp .get_battery_status
	jp .draw_battery_indicator
	db 130,2,160,18
.draw_battery_indicator:
	ld a,(.battery_status)
	ld c,$07
	cp a,2
	jq nc,.battery_good
	ld c,$E4
.battery_good:
	push bc
	call gfx_SetColor
	ld hl,14
	ex (sp),hl
	ld hl,0
.battery_status:=$-3
	add hl,hl
	add hl,hl
	add hl,hl
	push hl
	ld bc,2
	push bc
	ld bc,280
	push bc
	call gfx_FillRectangle
	pop bc,bc,bc,bc
	ret
.get_battery_status:
	call ti.GetBatteryStatus
	ld (.battery_status),a
	ret

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
	db "/etc/config/explorer/colors.dat",0


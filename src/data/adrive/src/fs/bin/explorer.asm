
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
taskbar_margin_left   := 5
taskbar_item_y        := 241-taskbar_height
taskbar_item_width    := 62

assert taskbar_height < 231

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
.fail:
	scf
	sbc hl,hl
	ret
explorer_init_2:
	ld bc,16
	push bc
	call bos.sys_Malloc
	pop bc
	jq c,explorer_init.fail
	ld (explorer_dirname_buffer),hl
	ld hl,explorer_default_directory
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
explorer_main:
	ld c,1
	push bc
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
	pop bc,bc,bc

;draw taskbar
	ld hl,taskbar_height
	ex (sp),hl
	ld hl,320
	push hl
	or a,a
	sbc hl,hl
	ld bc,taskbar_y
	push bc,hl
	call gfx_FillRectangle
	pop bc,bc,bc,bc

;draw taskbar items
	push ix
	ld hl,taskbar_margin_left
	ld (.taskbar_x_pos),hl
	ld ix,taskbar_item_strings
	ld b,5
.draw_taskbar_loop:
	push bc
	ld de,(ix)
	lea ix,ix+3
	ld hl,0
.taskbar_x_pos:=$-3
	ld bc,taskbar_item_y
	push bc,hl,de
	ld bc,taskbar_item_width
	add hl,bc
	ld (.taskbar_x_pos),hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	pop bc
	djnz .draw_taskbar_loop
	pop ix

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
	pop bc,bc,bc

	ld l,1
	ex (sp),hl
	call gfx_Blit
	pop bc
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
	jq explorer_main
.filemenu:
	jq explorer_main
.quickmenu:
	jq explorer_main

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

explore_files_main:
	ld hl,str_FilesExecutable
	ld de,$FF0000
	jq explorer_call_file

open_terminal:
	ld hl,str_CmdExecutable
	ld de,$FF0000
explorer_call_file:
	ld sp,(_SaveSP)
	ld ix,(_SaveIX)
	push hl,de
	call bos.sys_FreeRunningProcessId
	call bos.gfx_SetDefaultFont
	pop de,hl
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

explorer_cursor_down:
	ld a,(explorer_cursor_y)
	cp a,4
	jq nc,explorer_main
	inc a
	ld (explorer_cursor_y),a
	jq explorer_main
explorer_cursor_up:
	ld a,(explorer_cursor_y)
	or a,a
	jq z,explorer_main
	dec a
	ld (explorer_cursor_y),a
	jq explorer_main
explorer_cursor_left:
	ld a,(explorer_cursor_x)
	or a,a
	jq z,explorer_main
	dec a
	ld (explorer_cursor_x),a
	jq explorer_main
explorer_cursor_right:
	ld a,(explorer_cursor_x)
	cp a,3
	jq nc,explorer_main
	inc a
	ld (explorer_cursor_x),a
	jq explorer_main

explorer_display_diritems:
	push ix
	ld hl,display_margin_top
	ld (.y_pos),hl
	ld ix,(explorer_dirlist_buffer)
	ld c,display_items_num_y
.outer_loop:
	ld b,display_items_num_x
	ld hl,display_margin_left
	ld (.x_pos),hl
.inner_loop:
	push bc
	ld hl,0
.y_pos:=$-3
	push hl
	ld hl,0
.x_pos:=$-3
	push hl
	call gfx_SetTextXY
	pop bc,bc
	ld bc,(ix)
	ld a,(ix+2)
	or a,c
	or a,b
	jq z,.skip_null_entry
	lea ix,ix+3
	push bc
	ld bc,0
explorer_dirname_buffer:=$-3
	push bc
	call bos.fs_CopyFileName
	call gfx_PrintString
	pop bc,hl

	ld hl,(.y_pos)
	ld bc,9
	add hl,bc
	ld bc,(.x_pos)
	push hl,bc
	ld hl,display_item_width
	add hl,bc
	ld (.x_pos),hl
	call gfx_SetTextXY
	pop bc,bc

	ld bc,bos.fsentry_fileattr
	add hl,bc
	ld a,(hl)
	bit bos.fd_readonly,a
	call nz,.readonly
	bit bos.fd_system,a
	call nz,.system
	bit bos.fd_device,a
	call nz,.device
	bit bos.fd_subdir,a
	call nz,.subdir

.skip_null_entry:
	pop bc
	djnz .inner_loop
	ld hl,(.y_pos)
	ld de,display_item_height
	add hl,de
	ld (.y_pos),hl
	dec c
	jq nz,.outer_loop
	pop ix
	ret

.system:
	ld hl,.system_str
	jq .printflagstr
.subdir:
	ld hl,.subdir_str
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
	ld   bc,$aa5aa5
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
gfx_SetFontData:
	jp 69
gfx_SetFontSpacing:
	jp 72
gfx_Line:
	jp 90
gfx_Rectangle:
	jp 105
gfx_FillRectangle:
	jp 108

	xor   a,a      ; return z (loaded)
	pop   hl      ; pop error return
	ret

libload_name:
	db   "/lib/LibLoad.dll", 0
.len := $ - .




run_usbrecv_app:
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
	ld hl,input_source_string
	call bos.gui_DrawConsoleWindow
usbrecv_input_src:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,usbrecv_input_src
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
	ld hl,input_dest_string
	call bos.gui_Print
usbrecv_input_dest:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,usbrecv_input_dest
	pop bc,bc,hl
	or a,a
	ret z
	ex hl,de
	ld hl,str_UsbRecvExecutable
	jq explorer_call_file

run_fexplore_app:
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
	ld hl,input_dir_string
	call bos.gui_DrawConsoleWindow
fexplore_input_dir:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,fexplore_input_dir
	pop hl,bc
	or a,a
	ret z
	ex hl,de
	ld hl,str_FExploreExecutable
	jq explorer_call_file


run_power_app:
	ld hl,str_OffExecutable
	jq explorer_call_file

run_updater_program:
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

run_usbrun_app:
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
	ld hl,input_program_string
	call bos.gui_DrawConsoleWindow
usbrun_input_program:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,usbrun_input_program
	pop hl,bc
	or a,a
	ret z
	ex hl,de
	ld hl,str_UsbRunExecutable
	jq explorer_call_file

taskbar_item_strings:
	dl .l1, .l2, .l3, .l4, .l5
.l1:
	db "recovry",0
.l2:
	db "ctrl",0
.l3:
	db "file",0
.l4:
	db 0
.l5:
	db "cmd",0

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

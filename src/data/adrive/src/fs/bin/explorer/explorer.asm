
include '../include/ez80.inc'
include '../include/ti84pceg.inc'
include '../include/bos.inc'


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
taskbar_item_y        := 244-taskbar_height
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
	call bos.sys_FreeRunningProcessId
	call bos.gfx_Set8bpp
	ld (_SaveIX),ix
	ld (_SaveSP),sp
	call load_libload
	jq z,explorer_init_2
.fail:
	scf
	sbc hl,hl
	ret
explorer_init_2:
	call gfx_Begin
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

	ld a,(explorer_background_color)
	ld (bos.lcd_bg_color),a
	ld (bos.lcd_text_bg),a

	ld de,explorer_config_file
	push de
	call bos.fs_GetFilePtr
	pop de
	jr c,.dontloadconfig
	ld a,b
	or a,c
	jr z,.dontloadconfig
	push bc,hl
	call explorer_load_config
	pop bc,bc
.dontloadconfig:

	ld de,explorer_hooks_file
	push de
	call bos.fs_GetFilePtr
	pop de
	jr c,.dontloadhooks
	ld a,b
	or a,c
	jr z,.dontloadhooks
	call bos.sys_LoadHookThreads
.dontloadhooks:
	
	xor a,a
	ld (explorer_cursor_x),a
	ld (explorer_cursor_y),a
	; call ti.GetBatteryStatus
	; ld (battery_status),a
	; ld hl,bos.thread_map + 2
	; bit 7,(hl)
	; jq nz,explorer_dont_run_preload
	; ld hl,explorer_preload_file
	; ld bc,0
	; push bc,bc,hl
	; call bos.fs_OpenFile
	; call c,bos.fs_CreateFile
	; ld hl,explorer_preload_cmd
	; ex (sp),hl
	; ld hl,str_CmdExecutable
	; push hl
	; call bos.sys_ExecuteFile
	; pop bc,bc,bc,bc
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
	call ti.GetBatteryStatus
	sbc a,0
	ld (explorer_battery_status),a
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

	ld hl,7
explorer_foreground2_color:=$-3
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
	EnableOSThreading
.key_loop:
	ei
	call bos.sys_WaitKeyCycle
	di
	dec a
	jq z,explorer_cursor_down
	dec a
	jq z,explorer_cursor_left
	dec a
	jq z,explorer_cursor_right
	dec a
	jq z,explorer_cursor_up
	cp a,ti.skYequ - 4
	jp z,bos.sys_OpenRecoveryMenu
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
	jr .jpdirlist
.callpathout:
	call .pathout
.jpdirlist:
	or a,a
	sbc hl,hl
	ld (explorer_files_skip),hl
	jp explorer_dirlist
.open_file:
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.fs_GetFilePtr
	pop de
	ld a,0
.force_editing_file:=$-1
	or a,a
	jr nz,.edit_file
	ld a,c
	or a,b
	jr z,.edit_file_run_cedit
	push de
	call bos.sys_GetExecType
	pop de
	jr nc,.exec_file
.edit_file:
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.fs_GetFilePtr
	pop de
.checkfileloop: ; check whether the file contains only text characters (range 0x01 to 0x7F)
	ld a,(hl)
	or a,a
	jr z,.edit_file_run_memedit
	add a,a
	jr c,.edit_file_run_memedit
.checkfileloop_nextbyte:
	inc hl
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
.exec_file:
	ld hl,(explorer_dirname_buffer)
	jq explorer_call_file_noargs
.quickmenu:
	ld hl,quickmenu_item_strings
	jq .drawmenu
.optionsmenu:
	ld hl,options_item_strings
.drawmenu:
	call explorer_taskbar_menu
	jq explorer_dirlist

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


; --------------------------------------------------------------

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

include 'display.asm'
include 'files.asm'
include 'loadconfig.asm'
include 'config.asm'
include 'libloader.asm'
include 'data.asm'


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
	ld (_SaveIX),ix
	ld (_SaveSP),sp
	call load_libload
	jq z,explorer_init_2
	ld hl,str_FailedToLoadLibload
	call bos.gui_Print
	scf
	sbc hl,hl
	ret
explorer_init_2:
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
	ld l,$08
	ex (sp),hl
	call gfx_FillScreen
	call gfx_SetTextTransparentColor
	call gfx_SetTextBGColor
	pop bc
	ld c,$FF
	push bc
	call gfx_SetTextFGColor
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
	pop bc
.key_loop:
	call gfx_BlitBuffer
	ld c,$FF
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
	bit 0,(hl)
	call nz,explorer_cursor_down
	bit 1,(hl)
	call nz,explorer_cursor_left
	bit 2,(hl)
	call nz,explorer_cursor_right
	bit 3,(hl)
	call nz,explorer_cursor_up
	ld a,(hl)
	or a,a
	jq nz,.key_loop
	call bos.sys_WaitKeyCycle
	or a,a
	jq z,.key_loop
	cp a,56
	jq z,_uninstall_bos
	cp a,53
	jq z,_exit_return_1337
	cp a,15
	jq z,_exit
	cp a,55
	jq z,explore_files_main
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

_uninstall_bos:
	ld bc,str_Uninstall
	push bc
	call bos.sys_ExecuteFile
	pop bc
	ret
str_Uninstall:
	db "/bin/uninstlr.exe",0

explore_files_main:
	ld sp,0
_SaveSP:=$-3
	ld ix,(_SaveIX)
	ld hl,str_FilesExecutable
	ld de,$FF0000
	ld bc,str_ExplorerExecutable
	jp bos.sys_CallExecuteFile
str_FilesExecutable:
	db "/bin/files.exe",0
str_ExplorerExecutable:
	db "/bin/explorer.exe",0

gfx_PrintStrings:
	ld bc,30
	ld (.y_pos),bc
.loop:
	push hl
	ld hl,(hl)
	ld a,(hl)
	or a,a
	jq z,.exit
	ld bc,10
.y_pos:=$-3
	push bc
	ld c,0
	push bc,hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	ld hl,(.y_pos)
	ld bc,10
	add hl,bc
	ld (.y_pos),hl
	pop hl
	inc hl
	inc hl
	inc hl
	jq .loop
.exit:
	pop hl
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
	cp a,2
	ret c
	sub a,2
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
	db   "/lib/LibLoad.LLL", 0
.len := $ - .

gfx_BlitBuffer:
	ld c,1
	push bc
	call gfx_Blit
	pop bc
	ret


explorer_gui_items:
	dl .info_strings
	dl .status_bar
	db 0

.status_bar:
	jp .no_op
	ret
	dl 0
	jp .draw_status_bar
	db 0,0,160,20
.draw_status_bar:
	ld c,$11
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
	db 140,2,160,18
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


.info_strings:
	jp .remove_info_strings
.no_op:
	ret
	dl 0
	jp .draw_info_strings
	db 0,30,160,78
.draw_info_strings:
	ld hl,initial_strings
	jq gfx_PrintStrings
.remove_info_strings:
	ld a,$C9
	ld (.info_strings),a ;smc the first jump into a ret so this item is skipped entirely
	ret

initial_strings:
	dl str_HelloWorld, str_PressToDelete, str_PressForFiles, str_PressToConsole, $FF0000
str_HelloWorld:
	db "Hello World! Welcome to BOS!",0
str_PressToDelete:
	db "Press [del] to uninstall and receive TIOS",0
str_PressForFiles:
	db "Press [mode] to open file explorer",0
str_PressToConsole:
	db "or [clear] to open console",0
str_FailedToLoadLibload:
	db "Failed to load libload.",0
str_FileNameString:
	db 13 dup 0

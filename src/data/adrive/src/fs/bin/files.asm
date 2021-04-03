
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem
	jr files_init
	db "REX",0
files_init:	
	ld (_SaveIX),ix
	ld (_SaveSP),sp
	call libload_load
	jq z,files_init_2
	ld hl,str_FailedToLoadLibload
	call bos.gui_Print
	scf
	sbc hl,hl
	ret
files_init_2:
	ld c,1
	push bc
	call gfx_SetDraw
	ld l,0
	ex (sp),hl
	call gfx_SetTextTransparentColor
	call gfx_SetTextBGColor
	ld l,$FF
	ex (sp),hl
	call gfx_SetTextFGColor
	pop bc
	pop bc,hl
	push hl,bc
	ld a,(hl)
	or a,a
	jq z,.no_args
	ld a,(hl)
	cp a,'$'
	jq nz,.set_path
	ex hl,de
	or a,a
	sbc hl,hl
	ld b,6
.nibble_loop:
	call .nibble
	jq c,.set_path
	djnz .nibble_loop
	jq explorer_set_dir
.nibble:
	ld a,(de)
	inc de
	cp a,'0'
	ret c
	cp a,'F'
	ccf
	ret c
	sub a,'0'
	cp a,10
	jq c,.underA
	sub a,'A'-'9'
	ret c
.underA:
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	push bc
	ld bc,0
	ld c,a
	add hl,bc
	pop bc
	ret
.set_path:
	pop bc,hl
	push hl,bc
	ld (explorer_path_ptr),hl
.no_args:
explore_files:
	ld hl,bos.current_working_dir
explorer_path_ptr:=$-3
	inc hl
	ld a,(hl)
	or a,a
	jq z,.root_dir
	dec hl
	push hl
	call bos.fs_OpenFile
	pop bc
	jq explorer_set_dir
.root_dir:
	ld hl,$040200
explorer_set_dir:
	ld (explorer_curdir_ix),hl
explore_files_main:
	call gfx_ZeroScreen
	ld ix,0
explorer_curdir_ix:=$-3
	ld c,$FF
	push bc
	call gfx_SetTextFGColor
	pop bc
	ld bc,(explorer_path_ptr)
	or a,a
	sbc hl,hl
	push hl,hl,bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	call explorer_draw_files
	ld hl,0
explorer_cursor_y:=$-3
	inc hl
	push hl
	add hl,hl
	add hl,hl
	add hl,hl
	pop de
	add hl,de
	push hl
	ld bc,0
	push bc
	ld bc,str_CursorString
	push bc
	call gfx_PrintStringXY
	pop bc,bc,bc
	call gfx_BlitBuffer
.keyloop:
	call bos.sys_WaitKey
	push af
	ld a,8
	call ti.DelayTenTimesAms
	pop af
	cp a,15
	jq z,_exit
	ld bc,explore_files_main
	push bc
	cp a,2
	jq z,explorer_path_out
	cp a,3
	jq z,explorer_path_into
	cp a,9
	jq z,explorer_path_into
	cp a,1
	jq z,explorer_scroll_down
	cp a,4
	jq z,explorer_scroll_up

	pop bc
	jq .keyloop
_exit:
	call gfx_ZeroScreen
	call bos._HomeUp
	xor a,a
	sbc hl,hl
.loadix:
	ld ix,0
_SaveIX:=$-3
	ld sp,0
_SaveSP:=$-3
	ret

explorer_scroll_down:
	ld hl,(explorer_cursor_y)
	inc hl
	ld bc,23
	or a,a
	sbc hl,bc
	jq nc,explorer_page_down
	add hl,bc
	push hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,(explorer_dir_offset)
	add hl,bc
	ld bc,(explorer_curdir_ix)
	add hl,bc
	ld a,(hl)
	pop hl
	or a,a
	ret z
	inc a
	ret z
	ld (explorer_cursor_y),hl
	ret
explorer_scroll_up:
	ld hl,(explorer_cursor_y)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,explorer_page_up
	dec hl
	ld (explorer_cursor_y),hl
	ret
explorer_page_down:
	ld hl,(explorer_dir_offset)
	ld a,(hl)
	or a,a
	ret z
	ld bc,16
	add hl,bc
	ld (explorer_dir_offset),hl
	ret
explorer_page_up:
	ld hl,(explorer_dir_offset)
	ld bc,16
	or a,a
	sbc hl,bc
	ret c
	ld (explorer_dir_offset),hl
	ret
explorer_path_out:
	ld ix,(explorer_curdir_ix)
.search:
	ld a,(ix)
	or a,a
	ret z
	cp a,'.'
	jq nz,.search_next
	ld a,(ix+1)
	cp a,'.'
	jq z,explorer_path_into.entry
.search_next:
	lea ix,ix+16
	jq .search
explorer_path_into:
	ld hl,(explorer_cursor_y)
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld bc,(explorer_dir_offset)
	add hl,bc
	ex hl,de
	ld ix,(explorer_curdir_ix)
	add ix,de
.entry:
	ld hl,(ix+$C)
	push hl
	call bos.fs_GetSectorAddress
	pop bc
	bit bos.fd_subdir,(ix+$B)
	jq z,.tryrun
	ld (explorer_curdir_ix),hl
	or a,a
	sbc hl,hl
	ld (explorer_dir_offset),hl
	ld (explorer_cursor_y),hl
	ret
.tryrun:
	; push hl
	; ld bc,8
	; push bc
	; call bos.sys_Malloc
	; pop bc
	; pop de
	; ret c
	; push de,hl
	; ld (hl),'$'
	; inc hl
	; ex hl,de
	; ld hl,explorer_curdir_ix
	; ld b,3
; .gethexloop:
	; ld a,(hl)
	; inc hl
	; ld c,a
	; rlca
	; rlca
	; rlca
	; rlca
	; and a,$F
	; call .nibble
	; ld (de),a
	; inc de
	; ld a,c
	; call .nibble
	; ld (de),a
	; inc de
	; djnz .gethexloop
	; pop de,hl ;de points to return arguments, hl points to file data
	ld ix,(_SaveIX)
	ld sp,(_SaveSP)
	ret
.nibble:
	and a,$F
	cp a,10
	jr c,.underA
	add a,'A'-10
	ret
.underA:
	add a,'0'
	ret
explorer_draw_files:
	ld a,5
	ld (.current_row_color),a
	ld bc,10
	ld (.y_pos),bc
	ld bc,0
explorer_dir_offset:=$-3
	add ix,bc
.draw_loop:
	ld c,0
	push bc
	call gfx_SetTextBGColor
	ld l,$FF
	ex (sp),hl
	call gfx_SetTextFGColor
	pop bc
	ld a,(ix)
	or a,a
	ret z
	inc a
	ret z
	call .setxy
	bit bos.fd_subdir,(ix+$B)
	call nz,.draw_dir
	bit bos.fd_subdir,(ix+$B)
	call z,.draw_file
.next_file:
	lea ix,ix+16
	jq .draw_loop
.setxy:
	ld bc,10
.y_pos:=$-3
	push bc
	ld bc,12
.setxy_entry:
	push bc
	call gfx_SetTextXY
	pop bc,bc
	ret
.setxy_2:
	ld bc,(.y_pos)
	push bc
	ld bc,150
	jq .setxy_entry

.draw_file:
	bit bos.fd_system,(ix+$B)
	jq z,.not_system
	ld c,$E1
	push bc
	call gfx_SetTextBGColor
	pop bc
.not_system:
	bit bos.fd_device,(ix+$B)
	jq z,.not_device
	ld c,$75
	jq .draw_file_name
.not_device:
	ld c,$FF
	jq .draw_file_name
.draw_dir:
	ld c,$1F
.draw_file_name:
	push bc
	call gfx_SetTextFGColor
	pop bc
	ld hl,str_FileNameString
	push ix,hl
	call bos.fs_CopyFileName
	call gfx_PrintString
	call .setxy_2
	ld c,$FF
	push bc
	call gfx_SetTextFGColor
	ld a,5
.current_row_color:=$-1
	xor a,5
	ld (.current_row_color),a
	ld l,a
	ex (sp),hl
	call gfx_SetTextBGColor
	pop bc
	pop bc,ix
	bit bos.fd_system,(ix+$B)
	call nz,.system
	bit bos.fd_readonly,(ix+$B)
	call nz,.readonly
	bit bos.fd_device,(ix+$B)
	call nz,.device
	ld de,(ix+$E)
	ex.s hl,de
	call bos.sys_HLToString
	ld bc,(.y_pos)
	push bc
	ld bc,250
	push bc,de
	call gfx_PrintStringXY
	pop bc,bc,bc
.next_line:
	ld hl,(.y_pos)
	ld bc,9
	add hl,bc
	ld (.y_pos),hl
	ret
.device:
	ld hl,str_Device
	jq .print_hl
.readonly:
	ld hl,str_ReadOnly
	jq .print_hl
.system:
	ld hl,str_System
.print_hl:
	push hl
	call gfx_PrintString
	pop bc
	ret

str_System:
	db "SYS ",0
str_ReadOnly:
	db "R/O ",0
str_CursorString:
	db ">",0
str_Device:
	db "DEV",0


gfx_PrintStrings:
	ld bc,10
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

libload_load:
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
gfx_SetDraw:
	jp 27
gfx_Blit:
	jp 33
gfx_PrintInt:
	jp 45
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
gfx_GetTextY:
	jp 87
gfx_ZeroScreen:
	jp 228

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


str_FailedToLoadLibload:
	db "Failed to load libload.",0
str_FileNameString:
	db 13 dup 0

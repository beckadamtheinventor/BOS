
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

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
	call gfx_ZeroScreen
	ld c,0
	push bc
	call gfx_SetTextTransparentColor
	call gfx_SetTextBGColor
	pop bc
	ld c,$FF
	push bc
	call gfx_SetTextFGColor
	pop bc
	ld hl,initial_strings
	call gfx_PrintStrings
	call gfx_BlitBuffer
.key_loop:
	call bos.sys_WaitKeyCycle
	cp a,56
	jq z,_uninstall_bos
	cp a,53
	jq z,_exit_return_1337
	cp a,15
	jq z,_exit
	cp a,9
	jq nz,.key_loop
	jq explore_files_main
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


initial_strings:
	dl str_HelloWorld, str_PressToDelete, str_PressToContinue, str_PressToConsole, $FF0000
str_HelloWorld:
	db "Hello World! Welcome to BOS!",0
str_PressToDelete:
	db "Press [del] to uninstall and receive TIOS",0
str_PressToContinue:
	db "Press [enter] to open file explorer",0
str_PressToConsole:
	db "or [clear] to open console",0
str_FailedToLoadLibload:
	db "Failed to load libload.",0
str_FileNameString:
	db 13 dup 0

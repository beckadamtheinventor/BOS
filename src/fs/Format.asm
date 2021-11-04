


fs_Format:
	ld hl,str_Formatting
	call gui_DrawConsoleWindow

	call sys_FlashUnlock

	ld a,($0401FF) ;stores last sector of TIOS, will be 0xFF otherwise
	ld ($D2FFFF),a
	inc a
	ld a,$04
	jq z,.erase_all_loop
.erase_some_loop:
	call .erase_one
	cp a,$2B ;this is the sector where TIOS gets backed up from the installer
	jq nz,.erase_some_loop
	jq .extract_fs
.erase_all_loop: ;erase all filesystem flash sectors
	call .erase_one
	cp a,end_of_user_archive shr 16
	jr nz,.erase_all_loop

	ld hl,str_ErasedUserMemory
	call gui_PrintLine
.extract_fs:
	ld hl,str_WritingFilesystem
	call gui_PrintLine
	
	ld bc,fs_drive_a_data_compressed_bin
	push bc
	ld bc,$040000
	push bc
	call util_Zx7DecompressToFlash
	pop bc,bc

	call fs_InitClusterMap

.dont_reserve_memory:
	ld hl,flashStatusByte
	res bKeepFlashUnlocked, (hl)
	call sys_FlashLock

	call gui_NewLine
	ld hl,str_PressAnyKey
	call gui_Print
	jp sys_WaitKeyCycle

; ._next_header      := $D3FF00
; ._file_len_header  := $D3FF03
; ._file_len         := $D3FF06
; ._file_data        := $D3FF09
; .convert_tios_vars:
	; ld hl,($D3FFFD)
	; ld l,0
	; ld h,l
	; ld a,(hl)
	; inc a
	; ret z ;return if no files to convert
	; inc hl
	; inc hl
; .convert_loop:
	; ld e,(hl) ;get length of header + data
	; inc hl
	; ld d,(hl)
	; inc hl
	; push hl
	; ex.s hl,de
	; ld (._file_len_header),hl
	; pop hl
	; ld a,(hl)
	; inc hl
	; push hl
	; inc hl
	; inc hl
	; inc hl
	; inc hl
	; inc hl
	; ld b,(hl)
	; inc hl
	; call .copytoOP1
	; ld de,(hl) ;get length of data
	; inc hl
	; inc hl
	; ld (._file_data),hl
	; ex.s hl,de
	; ld (._file_len),hl
	; pop hl
	; ld bc,(._file_len_header)
	; add hl,bc ;file header ptr + file header len + file data len
	; ld (._next_header),hl ;pointer to next var header - 2

	; ld a,(fsOP1)
	; inc a
	; jq z,.dont_restore_var
	; ld hl,string_restoring_var
	; call gui_PrintString
	; ld hl,fsOP1+1
	; call gui_PrintString
	; call gui_NewLine
	; call _OP1ToPath ;convert var name in OP1 into a path
	; ld bc,(._file_len)
	; ld de,(._file_data)
	; push bc,de
	; ld c,0
	; push bc,hl
	; call fs_WriteNewFile ;create and write the file
	; pop bc,bc,bc,bc
; .dont_restore_var:
	; ld hl,(._next_header)
	; ld a,(hl)
	; inc a
	; jq nz,.convert_loop
	; ex hl,de
	; ld hl,$010000
	; ld e,l
	; ld d,h
	; add hl,de
	; ld a,(hl)
	; dec hl
	; dec hl
	; dec hl
	; ld (._next_header),hl
	; inc a
	; push af
	; call .convert_erase_sector
	; pop af
	; jq nz,.convert_loop
	; ld hl,(._next_header)
	; inc hl
	; inc hl
	; inc hl
	; ld a,(hl)
	; inc hl
	; inc hl
	; inc a
	; jq nz,.convert_loop
; if no more variables to convert, erase remaining flash sectors
	; ld a,(._file_data+2)
	; inc a
; .final_erase_loop:
	; call .erase_one
	; cp a,end_of_user_archive shr 16
	; jq nz,.final_erase_loop
	; ret
; .convert_erase_sector:
	; ld a,(._file_data+2)
	; jp sys_EraseFlashSector


; .copytoOP1:
	; push de
	; ld de,fsOP1
	; ld (de),a
	; inc de
; .copytoOP1_loop:
	; ld a,(hl)
	; inc hl
	; ld (de),a
	; inc de
	; djnz .copytoOP1_loop
; No need to check if we're at the end of OP1 due to BOS's OP registers being 16 bytes whereas
; this routine should never write more than 11 bytes.
	; xor a,a
	; ld (de),a
	; pop de
	; ret

.erase_one:
	push af
	call sys_EraseFlashSector
	xor a,a
	ld (curcol),a
	ld hl,str_ErasingSector
	call gui_Print
	pop af
	push af
	call gfx_PrintHexA
	call gfx_BlitBuffer
	pop af
	inc a
	ret

string_restoring_var:
	db "Restoring file: ",0

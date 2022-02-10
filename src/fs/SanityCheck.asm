;@DOES Sanity check the filesystem and initialize it as needed
;@DESTROYS All
fs_SanityCheck:
	call gfx_SetDefaultFont
	call gfx_Set8bpp
	ld a,1
	call gfx_SetDraw
	xor a,a
	ld (lcd_text_bg),a
	dec a
	ld (lcd_text_fg),a
	ld hl,start_of_user_archive
	ld a,(hl)
assert ~start_of_user_archive and $FF
	ld b,l
	ld c,2
.check_fs_descriptor:
	inc hl
	and a,(hl)
	djnz .check_fs_descriptor
	dec c
	jr nz,.check_fs_descriptor
	inc a
	jq z,.run_init ; re-init the filesystem descriptor if no descriptors found
	ld iy,start_of_user_archive+fsentry_filesector
	ld b,512/16
.check_for_valid_fs_descriptor:
	ld a,(iy)
	or a,a
	jr z,.check_next_fs_descriptor
	ld a,(iy+fsentry_filelen)
	and a,(iy+fsentry_filelen+1)
	inc a
	jr z,.check_next_fs_descriptor
	ld a,(iy+fsentry_filesector)
	and a,(iy+fsentry_filesector+1)
	inc a
	jr z,.check_next_fs_descriptor
	ld a,(iy+fsentry_filelen)
	or a,(iy+fsentry_filelen+1)
	jr nz,.has_valid_fs_descriptor
.check_next_fs_descriptor:
	lea iy,iy+16 ; check for next descriptor
	djnz .check_for_valid_fs_descriptor
; initialize a filesystem descriptor if no valid fs descriptors found
	jr .run_init
.has_valid_fs_descriptor:
	call .check_root ; check if root directory begins with the right directories
	ret z
.run_init:
	call os_GetOSInfo
	call gui_DrawConsoleWindow
; splash screen credit to LogicalJoe: https://github.com/LogicalJoe
	ld hl,str_SplashCredit
	call gui_PrintLine

	ld	de,BOS_B_compressed
	ld	hl,BOS_B
	push	de,hl
	call	util_Zx7Decompress
	pop	bc,bc

	ld	de,BOS_O_compressed
	push	de,hl
	call	util_Zx7Decompress
	pop	bc,bc

	ld	de,BOS_S_compressed
	push	de,hl
	call	util_Zx7Decompress
	pop	bc,bc

;	ld	hl,BOS_B
;	ld	bc, (97 shl 8) + 53
;	call	gfx_Sprite

	ld	hl,BOS_O
	ld	bc, (139 shl 8) + 99
	call	gfx_Sprite

;	ld	hl,BOS_S
;	ld	bc, (187 shl 8) + 145
;	call	gfx_Sprite


	ld	b,48			; distance to move
.loop:
	push	bc

	call	ti.Delay10ms

	pop	hl			; I hate this code
	push	hl
	ld	l,h			; because b not c
	ld	h,0
	ld	bc,(97 shl 8) + 52
	add	hl,bc
	push	hl
	pop	bc
	ld	hl,BOS_B
	call	gfx_Sprite

	pop	bc			; I still hate this code
	push	bc
	ld	c,b
	ld	b,0
	ld	hl,(187 shl 8) + 146
	sbc	hl,bc
	push	hl
	pop	bc
	ld	hl,BOS_S
	call	gfx_Sprite

	call	gfx_BlitBuffer

	pop	bc			; delay if on first frame
	ld	a,b
	cp	a,48
	jq	nz,.notfirst

	push	bc
	ld	b,30
.Delay1:
	call	ti.Delay10ms
	djnz	.Delay1
	pop	bc

.notfirst:
	call sys_AnyKey ; doesn't modify BC
	jq nz,.skip_splash
	djnz	.loop

	ld	a,228
	ld	(lcd_text_fg),a
	xor	a,a
	ld	(lcd_text_bg),a

	ld	hl,140
	ld	a,86
	call	gfx_SetTextXY
	ld	hl,str_ecks
	call	gfx_PrintString

	ld a,187
	ld (lcd_x),a
	ld a,134
	ld (lcd_y),a
	ld	hl,str_perate
	call	gfx_PrintString
	ld	a,220
	ld (lcd_x),a
	ld	a,181
	ld (lcd_y),a
	ld	hl,str_ystem
	call	gfx_PrintString

	call	gfx_BlitBuffer

	ld	b,100
.Delay2:
	call sys_AnyKey ; doesn't modify BC
	jq nz,.skip_splash
	call	ti.Delay10ms
	djnz	.Delay2

.skip_splash:
	ld a,24
	ld (currow),a
	ld a,255
	ld (lcd_text_fg),a

	call fs_ExtractOSBinaries
	call fs_ExtractRootDir
	call fs_InitClusterMap
	; call .check_root_dirs
	jq fs_ExtractOSOptBinaries

.check_root:
	ld hl,fs_root_dir_address
	ld de,fs_root_dir_data
	ld bc,fs_root_dir_data.len
	push bc,de,hl
	call ti._memcmp
	pop bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret

; .check_root_dirs:
	; ld hl,current_working_dir
	; ld (hl),'/'
	; inc hl
	; ld (hl),0
	; ld hl,str_bin_dir
	; ld de,fs_root_dir_data
	; call .check_file_fd
	; ld hl,str_lib_dir
	; ld de,fs_root_dir_data+16
	; call .check_file_fd
	; ld hl,str_sbin_dir
	; ld de,fs_root_dir_data+32

; .check_file_fd:
	; push de,hl
	; call fs_OpenFile
	; pop bc,de
	; jq c,.create_missing_entry ; create if dir couldn't be located
	; ld bc,16
	; push bc,de,hl
	; call ti._memcmp
	; pop bc,de,bc
	; add hl,bc
	; or a,a
	; sbc hl,bc
	; ret z
; .create_missing_entry:
	; push de
	; ld hl,start_of_user_archive
	; call fs_AllocDescriptor.entryfd
	; pop de
	; ret c
	; ex hl,de
	; ld bc,16
	; call sys_FlashUnlock
	; call sys_WriteFlash
	; jq sys_FlashLock

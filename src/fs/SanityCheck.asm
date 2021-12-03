;@DOES Sanity check the filesystem and initialize it as needed
;@DESTROYS All
fs_SanityCheck:
	ld a,(fs_filesystem_address)
	inc a
	jq z,.run_first_init
	ld a,(fs_root_dir_address)
	inc a
	ret nz
	; jq z,.run_first_init

.run_first_init:
	ld a,24
	ld (currow),a
; splash screen credit to LogicalJoe: https://github.com/LogicalJoe
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
	ld a,255
	ld (lcd_text_fg),a

	call fs_Format

	ld hl,current_working_dir
	ld (hl),'/'
	inc hl
	ld (hl),0
	ld hl,str_bin_dir
	ld de,fs_root_dir_data
	call .check_file_fd
	call nz,.create_missing_entry
	ld hl,str_lib_dir
	ld de,fs_root_dir_data+16
	call .check_file_fd
	ld hl,str_sbin_dir
	ld de,fs_root_dir_data+32
	; call .check_file_fd

	
	; ret

.check_file_fd:
	push de,hl
	call fs_OpenFile
	pop bc,de
	jq c,.create_missing_entry ; fail if file couldn't be located
	ld bc,16
	push bc,de,hl
	call ti._memcmp
	pop bc,de,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret z
.create_missing_entry:
	push de
	ld hl,fs_filesystem_address
	call fs_AllocDescriptor.entryfd
	pop de
	ret c
	ex hl,de
	ld bc,16
	call sys_FlashUnlock
	call sys_WriteFlash
	jq sys_FlashLock

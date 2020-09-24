


fs_Format:
	ld hl,str_Formatting
	call gui_DrawConsoleWindow

	call flash_unlock

	ld a,$04
.erase_loop: ;erase all system and user flash sectors
	push af
	call sys_EraseFlashSector
	ld hl,str_ErasingSector
	call gui_Print
	pop af
	push af
	call gfx_PrintHexA
	call gfx_BlitBuffer
	pop af
	inc a
	cp a,$40
	jr nz,.erase_loop

	ld hl,str_ErasedUserMemory
	call gui_Print

	ld hl,str_WritingDriveA
	call gui_Print

	push ix

	ld ix,fs_drive_a_data
	ld b,fs_drive_a_data.len
.write_loop:
	push bc
	ld hl,(ix)
	ld bc,(ix+3)
	ld de,(ix+6)
	lea ix,ix+9
	call sys_WriteFlash
	pop bc
	djnz .write_loop
	ld hl,str_WritingDriveC
	call gui_Print

	ld ix,fs_drive_c_data
	ld b,fs_drive_c_data.len
.write_loop2:
	push bc
	ld hl,(ix)
	ld bc,(ix+3)
	ld de,(ix+6)
	lea ix,ix+9
	call sys_WriteFlash
	pop bc
	djnz .write_loop2

	pop ix

	call flash_lock
	ld hl,str_PressAnyKey
	call gui_Print
	jp sys_WaitKeyCycle

fs_drive_a_data:
	dl fs_drive_a_format_data
	dl fs_drive_a_format_data.len
	dl $040000
	dl fs_partition_table_data
	dl fs_partition_table_data.len
	dl $0401BE
	dl fs_magic_bytes
	dl fs_magic_bytes.len
	dl $0401FC
	dl fs_drive_a_volume_data
	dl fs_drive_a_volume_data.len
	dl $040200
	dl fs_magic_bytes
	dl fs_magic_bytes.len
	dl $0403FC
	dl fs_drive_a_bin
.len:=($-fs_drive_a_data) / 9


fs_drive_c_data:
	dl fs_drive_a_format_data
	dl fs_drive_a_format_data.len
	dl $0A0000
	dl fs_magic_bytes
	dl fs_magic_bytes.len
	dl $0A01FC
	dl fs_drive_c_volume_data
	dl fs_drive_c_volume_data.len
	dl $0A0200
	dl fs_magic_bytes
	dl fs_magic_bytes.len
	dl $0A03FC
.len:=($-fs_drive_c_data) / 9


fs_drive_a_format_data:
	jp boot_os
	db "BOSos",0
.len:=$-fs_drive_a_format_data

fs_partition_table_data:
	db $00,$FF,$FF,$FF ;partition 1 (system partition "A")
	db $0B,$FF,$FF,$FF
	db $01,$02,$00,$00 ;start LBA = 0x201
	db $00,$04,$00,$00 ;end LBA = 0x400
	
	db $00,$FF,$FF,$FF ;partition 2 (swap partition "B")
	db $00,$FF,$FF,$FF
	db $00,$04,$00,$00 ;start LBA = 0x400
	db $00,$05,$00,$00 ;end LBA = 0x500
	
	db $00,$FF,$FF,$FF ;partition 3 (user partition "C")
	db $0B,$FF,$FF,$FF
	db $00,$05,$00,$00 ;start LBA = 0x500
	db $00,$20,$00,$00 ;end LBA = 0x2000

	db $00,$FF,$FF,$FF ;partition 4 (unused by default, might become mounted partition "D" at some point)
	db $00,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF ;start LBA = -1
	db $FF,$FF,$FF,$FF ;end LBA = -1
.len:=$-fs_partition_table_data

fs_drive_a_volume_data:
	db $00,$02   ;sector size. always 512
	db $02       ;sectors per cluster
	db $08,$00   ;reserved sector count
	db $02       ;number of FATs. always 2
	db $1B dup 0
	db $08,0,0,0 ;sectors per FAT
	db $04,0,0,0 ;root directory first cluster
.len:=$-fs_drive_a_volume_data

fs_drive_a_bin_dir:
	db "bin     ","  "
	db $11     ; read-only directory
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $00,$00 ; starting cluster high
	db $00,$00,$00,$00
	db $00,$00 ; starting cluster low
	db $00,$00,$00,$00 ;file size
.len:=$-fs_drive_a_bin_dir

fs_drive_c_volume_data:
	db $00,$02   ;sector size. always 512
	db $02       ;sectors per cluster
	db $08,$00   ;reserved sector count
	db $02       ;number of FATs. always 2
	db $1B dup 0
	db $08,0,0,0 ;sectors per FAT
	db $04,0,0,0 ;root directory first cluster
.len:=$-fs_drive_c_volume_data

fs_drive_c_home_dir:
	db "home    ","   "
	db $10     ; directory
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $00,$00 ;starting cluster high
	db $00,$00,$00,$00
	db $00,$00 ;starting cluster low
	db $00,$00,$00,$00 ;file size
.len:=$-fs_drive_c_home_dir

fs_drive_a_root:
	db $04,$02,$00,$00
.len:=$-fs_drive_a_root

fs_drive_c_root:
	db $04,$05,$00,$00
.len:=$-fs_drive_c_root

fs_magic_bytes:
	db $00,$00,$55,$AA
.len:=$-fs_magic_bytes

fs_fat_id:
	db $F0,$FF,$FF,$F0
.len:=$-fs_fat_id

fs_fat_end_of_chain:
	db $FF,$FF,$FF,$F0
.len:=$-fs_fat_end_of_chain



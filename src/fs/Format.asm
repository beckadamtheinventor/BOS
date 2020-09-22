


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

	ld de,fs_drive_a
	ld hl,fs_drive_a_format_data
	ld bc,fs_drive_a_format_data.len
	call sys_WriteFlash
	ld de,fs_drive_a + fs_partition_1
	ld hl,fs_partition_table_data
	ld bc,fs_partition_table_data.len
	call sys_WriteFlash
	ld de,fs_drive_a + fs_boot_magic_1
	ld hl,fs_magic_bytes
	ld bc,fs_magic_bytes.len
	call sys_WriteFlash
	ld de,fs_drive_a + $20B
	ld hl,fs_drive_a_volume_data
	ld bc,fs_drive_a_volume_data.len
	call sys_WriteFlash
	ld de,fs_drive_a + $20B + fs_drive_a_volume_data.len
	ld hl,fs_drive_a_root
	ld bc,fs_drive_a_root.len
	call sys_WriteFlash
	ld de,fs_drive_a + $1000
	ld hl,fs_fat_id
	ld bc,fs_fat_id.len + fs_fat_end_of_chain.len
	call sys_WriteFlash
	ld de,fs_drive_a + $1008
	ld hl,fs_fat_end_of_chain
	ld bc,fs_fat_end_of_chain.len
	call sys_WriteFlash
	ld de,fs_drive_a + $2000
	ld hl,fs_fat_id
	ld bc,fs_fat_id.len + fs_fat_end_of_chain.len
	call sys_WriteFlash
	ld de,fs_drive_a + $2008
	ld hl,fs_fat_end_of_chain
	ld bc,fs_fat_end_of_chain.len
	call sys_WriteFlash

	ld de,fs_drive_a + $5000 ;assume there are two 8-sector FATs and 8 reserved sectors per volume for now, adding 2 clusters to get root cluster
	ld hl,fs_drive_a_root_data
	ld bc,fs_drive_a_root_data.len
	call sys_WriteFlash

	ld hl,str_WritingDriveC
	call gui_Print

	ld de,fs_drive_c + fs_boot_magic_1
	ld hl,fs_magic_bytes
	ld bc,fs_magic_bytes.len
	call sys_WriteFlash
	ld de,fs_drive_c + $B
	ld hl,fs_drive_c_volume_data
	ld bc,fs_drive_c_volume_data.len
	call sys_WriteFlash
	ld de,fs_drive_c + $B + fs_drive_c_volume_data.len
	ld hl,fs_drive_c_root
	ld bc,fs_drive_c_root.len
	call sys_WriteFlash
	ld de,fs_drive_c + $1000
	ld hl,fs_fat_id
	ld bc,fs_fat_id.len + fs_fat_end_of_chain.len
	call sys_WriteFlash
	ld de,fs_drive_c + $1008
	ld hl,fs_fat_end_of_chain
	ld bc,fs_fat_end_of_chain.len
	call sys_WriteFlash
	ld de,fs_drive_c + $2000
	ld hl,fs_fat_id
	ld bc,fs_fat_id.len + fs_fat_end_of_chain.len
	call sys_WriteFlash
	ld de,fs_drive_c + $2008
	ld hl,fs_fat_end_of_chain
	ld bc,fs_fat_end_of_chain.len
	call sys_WriteFlash

	ld de,fs_drive_c + $5000 ;assume there are two 8-sector FATs and 8 reserved sectors per volume for now, adding 2 clusters to get root cluster
	ld hl,fs_drive_c_root_data
	ld bc,fs_drive_c_root_data.len
	call sys_WriteFlash

	call flash_lock

	ld hl,str_PressAnyKey
	call gui_Print
	jp sys_WaitKeyCycle

fs_drive_a_format_data:
	jp boot_os
	db "BOSos"
.len:=$-fs_drive_a_format_data

fs_partition_table_data:
	db $00,$FF,$FF,$FF ;partition 1 (system partition "A")
	db $0B,$FF,$FF,$FF
	db $00,$02,$00,$00 ;start LBA = 0x200
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
	db $02,0,0,0 ;root directory first cluster
.len:=$-fs_drive_a_volume_data

fs_drive_c_volume_data:
	db $00,$02   ;sector size. always 512
	db $02       ;sectors per cluster
	db $08,$00   ;reserved sector count
	db $02       ;number of FATs. always 2
	db $1B dup 0
	db $08,0,0,0 ;sectors per FAT
	db $02,0,0,0 ;root directory first cluster
.len:=$-fs_drive_c_volume_data

fs_magic_bytes:
	db $55,$AA
.len:=$-fs_magic_bytes

fs_drive_a_root:
	db $04,$02,$00,$00
.len:=$-fs_drive_a_root

fs_drive_c_root:
	db $04,$05,$00,$00
.len:=$-fs_drive_c_root

fs_fat_id:
	db $F0,$FF,$FF,$F0
.len:=$-fs_fat_id

fs_fat_end_of_chain:
	db $FF,$FF,$FF,$F0
.len:=$-fs_fat_end_of_chain

fs_drive_a_root_data:
	db "A:      ","   "
	db $01
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $00,$00 ;starting cluster high
	db $00,$00,$00,$00
	db $00,$00 ;starting cluster low
	db $00,$00,$00,$00 ;file size
.len:=$-fs_drive_a_root_data

fs_drive_c_root_data:
	db "C:      ","   "
	db $01
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $00,$00 ;starting cluster high
	db $00,$00,$00,$00
	db $00,$00 ;starting cluster low
	db $00,$00,$00,$00 ;file size
.len:=$-fs_drive_c_root_data

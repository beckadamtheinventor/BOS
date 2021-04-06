
	db $C9, 1
	jp dev_mnt_init
	jp dev_mnt_deinit
	jp dev_mnt_get_address
	jp dev_mnt_read
	jp dev_mnt_write
	; jp dev_mnt_command

dev_mnt_get_address:
	ld hl,bos.usb_sector_buffer
	ret

dev_mnt_command:
	; ld hl,.data
	; jp (hl)
; .data:
	; file '../../../obj/dev_mnt/command.bin'

dev_mnt_init:
	; ld hl,.data
; .data:
	; file '../../../obj/dev_mnt/init.bin'

dev_mnt_deinit:
	; ld hl,.data
; .data:
	; file '../../../obj/dev_mnt/deinit.bin'

dev_mnt_read:
	; ld hl,.data
; .data:
	; file '../../../obj/dev_mnt/read.bin'

dev_mnt_write:
	; ld hl,.data
; .data:
	; file '../../../obj/dev_mnt/write.bin'
	ret

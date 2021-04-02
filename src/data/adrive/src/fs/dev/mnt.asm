
	db $C9, 1
	jp dev_mnt_init
	jp dev_mnt_deinit
	jp dev_mnt_get_address
	jp dev_mnt_read
	jp dev_mnt_write

dev_mnt_get_address:
	ld hl,bos.usb_sector_buffer
	ret

dev_mnt_init:
	ld hl,.data
	ld bc,.data_len
dev_mnt_run_in_ram:
	ld de,bos.driverExecRAM
	push de
	ldir
	ret
dev_mnt_init.data:
	file '../../../obj/dev_mnt/init.bin'
dev_mnt_init.data_len:=$-dev_mnt_init.data

dev_mnt_deinit:
	ld hl,.data
	ld bc,.data_len
	jq dev_mnt_run_in_ram
.data:
	file '../../../obj/dev_mnt/deinit.bin'
.data_len:=$-.data

dev_mnt_read:
	ld hl,.data
	ld bc,.data_len
	jq dev_mnt_run_in_ram
.data:
	file '../../../obj/dev_mnt/read.bin'
.data_len:=$-.data

dev_mnt_write:
	ld hl,.data
	ld bc,.data_len
	jq dev_mnt_run_in_ram
.data:
	file '../../../obj/dev_mnt/write.bin'
.data_len:=$-.data

